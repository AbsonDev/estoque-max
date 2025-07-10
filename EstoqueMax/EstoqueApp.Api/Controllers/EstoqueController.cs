using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using EstoqueApp.Api.Data;
using EstoqueApp.Api.Models;
using EstoqueApp.Api.Services;
using Microsoft.AspNetCore.SignalR;
using EstoqueApp.Api.Hubs;
using EstoqueApp.Api.Services.AI;

namespace EstoqueApp.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class EstoqueController : ControllerBase
    {
        private readonly EstoqueContext _context;
        private readonly IPermissionService _permissionService;
        private readonly ISubscriptionService _subscriptionService;
        private readonly IHubContext<EstoqueHub> _hubContext;
        private readonly PredictionService _predictionService;

        public EstoqueController(
            EstoqueContext context, 
            IPermissionService permissionService, 
            ISubscriptionService subscriptionService,
            IHubContext<EstoqueHub> hubContext, 
            PredictionService predictionService)
        {
            _context = context;
            _permissionService = permissionService;
            _subscriptionService = subscriptionService;
            _hubContext = hubContext;
            _predictionService = predictionService;
        }

        // GET: api/estoque - Lista todos os itens de todas as despensas do usuário
        [HttpGet]
        public async Task<IActionResult> GetEstoque([FromQuery] int? despensaId = null)
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            var userName = User.FindFirst(ClaimTypes.Name)?.Value;

            if (userId == null)
            {
                return Unauthorized();
            }

            IQueryable<EstoqueItem> query;

            if (despensaId.HasValue)
            {
                // Verificar permissão para a despensa específica
                if (!await _permissionService.PodeAcederDespensa(int.Parse(userId), despensaId.Value))
                {
                    return Forbid();
                }

                query = _context.EstoqueItens
                    .Include(e => e.Produto)
                    .Include(e => e.Despensa)
                    .Where(e => e.DespensaId == despensaId.Value);
            }
            else
            {
                // Buscar todas as despensas que o usuário tem acesso
                var despensasIds = await _permissionService.GetDespensasDoUsuario(int.Parse(userId));

                query = _context.EstoqueItens
                .Include(e => e.Produto)
                    .Include(e => e.Despensa)
                    .Where(e => despensasIds.Contains(e.DespensaId));
            }

            var estoque = await query.ToListAsync();

            return Ok(new { 
                usuario = userName,
                despensaId = despensaId,
                totalItens = estoque.Count,
                estoque = estoque.Select(e => new {
                    id = e.Id,
                    produto = e.Produto.Nome,
                    marca = e.Produto.Marca,
                    codigoBarras = e.Produto.CodigoBarras,
                    quantidade = e.Quantidade,
                    quantidadeMinima = e.QuantidadeMinima,
                    estoqueAbaixoDoMinimo = e.Quantidade <= e.QuantidadeMinima,
                    dataValidade = e.DataValidade,
                    despensa = new {
                        id = e.Despensa.Id,
                        nome = e.Despensa.Nome
                    }
                })
            });
        }

        // GET: api/estoque/{id} - Busca detalhes de um item específico do estoque
        [HttpGet("{id}")]
        public async Task<IActionResult> GetEstoqueItem(int id)
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userId == null)
            {
                return Unauthorized();
            }

            var item = await _context.EstoqueItens
                .Include(e => e.Produto)
                .Include(e => e.Despensa)
                .ThenInclude(d => d.Membros)
                .FirstOrDefaultAsync(e => e.Id == id);

            if (item == null)
            {
                return NotFound("Item não encontrado.");
            }

            // Verificar permissão para acessar a despensa
            if (!await _permissionService.PodeAcederDespensa(int.Parse(userId), item.DespensaId))
            {
                return Forbid();
            }

            // Buscar histórico de consumo para análises
            var historicoConsumo = await _context.HistoricosDeConsumo
                .Where(h => h.EstoqueItemId == id)
                .OrderByDescending(h => h.DataDoConsumo)
                .Take(10) // Últimos 10 registros
                .Select(h => new {
                    id = h.Id,
                    quantidadeConsumida = h.QuantidadeConsumida,
                    dataConsumo = h.DataDoConsumo,
                    quantidadeRestante = h.QuantidadeRestanteAposConsumo
                })
                .ToListAsync();

            // Calcular estatísticas
            var totalConsumoUltimos30Dias = await _context.HistoricosDeConsumo
                .Where(h => h.EstoqueItemId == id && h.DataDoConsumo >= DateTime.UtcNow.AddDays(-30))
                .SumAsync(h => h.QuantidadeConsumida);

            var consumoMedioDiario = totalConsumoUltimos30Dias / 30.0;

            // Verificar status do item
            var diasParaVencer = item.DataValidade?.Subtract(DateTime.UtcNow).Days;
            var statusVencimento = diasParaVencer switch
            {
                null => "sem_data_validade",
                < 0 => "vencido",
                <= 3 => "vence_em_breve",
                <= 7 => "vence_em_uma_semana",
                _ => "dentro_da_validade"
            };

            var response = new {
                // Dados básicos do item
                id = item.Id,
                produto = new {
                    id = item.Produto.Id,
                    nome = item.Produto.Nome,
                    marca = item.Produto.Marca,
                    codigoBarras = item.Produto.CodigoBarras,
                    categoria = item.Produto.Categoria,
                    visibilidade = item.Produto.Visibilidade.ToString().ToLower()
                },
                despensa = new {
                    id = item.Despensa.Id,
                    nome = item.Despensa.Nome,
                    totalMembros = item.Despensa.Membros.Count
                },
                
                // Quantidades
                quantidade = item.Quantidade,
                quantidadeMinima = item.QuantidadeMinima,
                estoqueAbaixoDoMinimo = item.Quantidade <= item.QuantidadeMinima,
                
                // Datas
                dataValidade = item.DataValidade,
                dataAdicao = item.DataAdicao,
                diasParaVencer = diasParaVencer,
                statusVencimento = statusVencimento,
                
                // Preço (se disponível)
                preco = item.Preco,
                
                // Estatísticas de consumo
                estatisticas = new {
                    totalConsumoUltimos30Dias = totalConsumoUltimos30Dias,
                    consumoMedioDiario = Math.Round(consumoMedioDiario, 2),
                    totalRegistrosHistorico = historicoConsumo.Count,
                    ultimoConsumo = historicoConsumo.FirstOrDefault()?.dataConsumo
                },
                
                // Histórico recente
                historicoConsumo = historicoConsumo,
                
                // Alertas e recomendações
                alertas = GerarAlertasDetalhados(item, diasParaVencer, consumoMedioDiario),
                recomendacoes = GerarRecomendacoesDetalhadas(item, diasParaVencer, consumoMedioDiario),
                
                // Metadados
                dataConsulta = DateTime.UtcNow
            };

            return Ok(response);
        }

        // POST: api/estoque - Adiciona item a uma despensa específica
        [HttpPost]
        public async Task<IActionResult> AdicionarAoEstoque([FromBody] AdicionarEstoqueDto request)
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userId == null)
            {
                return Unauthorized();
            }

            // Verificar permissão para acessar a despensa
            if (!await _permissionService.PodeAcederDespensa(int.Parse(userId), request.DespensaId))
            {
                return Forbid();
            }

            // **NOVA LÓGICA: Tratamento inteligente de produtos**
            int produtoId;
            Produto? produto = null;

            if (request.ProdutoId.HasValue)
            {
                // Caso 1: ProdutoId foi fornecido - usar produto existente
                produto = await _context.Produtos.FindAsync(request.ProdutoId.Value);
                if (produto == null)
                {
                    return NotFound("Produto não encontrado.");
                }
                produtoId = produto.Id;
            }
            else if (!string.IsNullOrWhiteSpace(request.NomeProduto))
            {
                // Caso 2: Nome do produto foi fornecido - buscar ou criar
                var nomeNormalizado = request.NomeProduto.Trim().ToLower();
                
                // Buscar produto existente (público ou privado do usuário)
                produto = await _context.Produtos
                    .Where(p => p.Nome.ToLower() == nomeNormalizado &&
                               (p.Visibilidade == TipoVisibilidadeProduto.Publico ||
                                (p.Visibilidade == TipoVisibilidadeProduto.Privado && p.UsuarioCriadorId == int.Parse(userId))))
                    .FirstOrDefaultAsync();

                if (produto != null)
                {
                    // Produto encontrado - usar existente
                    produtoId = produto.Id;
                }
                else
                {
                    // Produto não encontrado - criar novo como privado
                    produto = new Produto
                    {
                        Nome = request.NomeProduto.Trim(),
                        Visibilidade = TipoVisibilidadeProduto.Privado,
                        UsuarioCriadorId = int.Parse(userId),
                        DataCriacao = DateTime.UtcNow
                    };

                    _context.Produtos.Add(produto);
                    await _context.SaveChangesAsync();
                    produtoId = produto.Id;
                }
            }
            else
            {
                return BadRequest("É necessário fornecer ProdutoId ou NomeProduto.");
            }

            // **VALIDAÇÕES MELHORADAS**
            if (request.Quantidade <= 0)
            {
                return BadRequest("Quantidade deve ser maior que zero.");
            }

            if (request.QuantidadeMinima <= 0)
            {
                return BadRequest("Quantidade mínima deve ser maior que zero.");
            }

            if (request.DataValidade.HasValue && request.DataValidade.Value <= DateTime.UtcNow)
            {
                return BadRequest("Data de validade deve ser futura.");
            }

            // **VERIFICAÇÃO DE DUPLICATAS MELHORADA**
            var itemExistente = await _context.EstoqueItens
                .FirstOrDefaultAsync(e => e.DespensaId == request.DespensaId && e.ProdutoId == produtoId);

            if (itemExistente != null)
            {
                // Atualizar quantidade existente
                itemExistente.Quantidade += request.Quantidade;
                itemExistente.QuantidadeMinima = request.QuantidadeMinima;
                itemExistente.DataValidade = request.DataValidade;

                await _context.SaveChangesAsync();

                // Recarregar o item com as relações para envio via SignalR
                var itemAtualizado = await _context.EstoqueItens
                    .Include(e => e.Produto)
                    .Include(e => e.Despensa)
                    .FirstOrDefaultAsync(e => e.Id == itemExistente.Id);

                // **NOTIFICAÇÃO EM TEMPO REAL**: Item atualizado
                if (itemAtualizado != null)
                {
                    await _hubContext.Clients.Group($"Despensa-{request.DespensaId}")
                        .SendAsync("EstoqueItemAtualizado", new {
                            id = itemAtualizado.Id,
                            produto = itemAtualizado.Produto.Nome,
                            marca = itemAtualizado.Produto.Marca,
                            codigoBarras = itemAtualizado.Produto.CodigoBarras,
                            quantidade = itemAtualizado.Quantidade,
                            quantidadeMinima = itemAtualizado.QuantidadeMinima,
                            estoqueAbaixoDoMinimo = itemAtualizado.Quantidade <= itemAtualizado.QuantidadeMinima,
                            dataValidade = itemAtualizado.DataValidade,
                            despensaId = itemAtualizado.DespensaId,
                            despensaNome = itemAtualizado.Despensa.Nome,
                            acao = "quantidade_atualizada"
                        });
                }

                return Ok(new { 
                    message = "Quantidade atualizada no estoque existente!",
                    produtoCriado = false,
                    produtoId = produtoId,
                    produtoNome = produto.Nome
                });
            }

            // **CRIAR NOVO ITEM NO ESTOQUE**
            var novoItem = new EstoqueItem
            {
                DespensaId = request.DespensaId,
                ProdutoId = produtoId,
                Quantidade = request.Quantidade,
                QuantidadeMinima = request.QuantidadeMinima,
                DataValidade = request.DataValidade
            };

            _context.EstoqueItens.Add(novoItem);
            await _context.SaveChangesAsync();

            // Recarregar o item com as relações para envio via SignalR
            var itemCompleto = await _context.EstoqueItens
                .Include(e => e.Produto)
                .Include(e => e.Despensa)
                .FirstOrDefaultAsync(e => e.Id == novoItem.Id);

            // **NOTIFICAÇÃO EM TEMPO REAL**: Novo item adicionado
            if (itemCompleto != null)
            {
                await _hubContext.Clients.Group($"Despensa-{request.DespensaId}")
                    .SendAsync("EstoqueItemAdicionado", new {
                        id = itemCompleto.Id,
                        produto = itemCompleto.Produto.Nome,
                        marca = itemCompleto.Produto.Marca,
                        codigoBarras = itemCompleto.Produto.CodigoBarras,
                        quantidade = itemCompleto.Quantidade,
                        quantidadeMinima = itemCompleto.QuantidadeMinima,
                        estoqueAbaixoDoMinimo = itemCompleto.Quantidade <= itemCompleto.QuantidadeMinima,
                        dataValidade = itemCompleto.DataValidade,
                        despensaId = itemCompleto.DespensaId,
                        despensaNome = itemCompleto.Despensa.Nome
                    });
            }

            return Ok(new { 
                message = "Item adicionado ao estoque com sucesso!",
                produtoCriado = produto.Visibilidade == TipoVisibilidadeProduto.Privado && produto.UsuarioCriadorId == int.Parse(userId),
                produtoId = produtoId,
                produtoNome = produto.Nome
            });
        }

        // PUT: api/estoque/{id} - Atualiza um item do estoque
        [HttpPut("{id}")]
        public async Task<IActionResult> AtualizarEstoque(int id, [FromBody] AtualizarEstoqueDto request)
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userId == null)
            {
                return Unauthorized();
            }

            var item = await _context.EstoqueItens
                .Include(e => e.Despensa)
                .Include(e => e.Produto)
                .FirstOrDefaultAsync(e => e.Id == id);

            if (item == null)
            {
                return NotFound("Item não encontrado.");
            }

            // Verificar permissão para acessar a despensa
            if (!await _permissionService.PodeAcederDespensa(int.Parse(userId), item.DespensaId))
            {
                return Forbid();
            }

            // Atualizar os dados do item
            item.Quantidade = request.Quantidade;
            item.QuantidadeMinima = request.QuantidadeMinima > 0 ? request.QuantidadeMinima : item.QuantidadeMinima;
            item.DataValidade = request.DataValidade;

            await _context.SaveChangesAsync();

            // **NOTIFICAÇÃO EM TEMPO REAL**: Item atualizado
            await _hubContext.Clients.Group($"Despensa-{item.DespensaId}")
                .SendAsync("EstoqueItemAtualizado", new {
                    id = item.Id,
                    produto = item.Produto.Nome,
                    marca = item.Produto.Marca,
                    codigoBarras = item.Produto.CodigoBarras,
                    quantidade = item.Quantidade,
                    quantidadeMinima = item.QuantidadeMinima,
                    estoqueAbaixoDoMinimo = item.Quantidade <= item.QuantidadeMinima,
                    dataValidade = item.DataValidade,
                    despensaId = item.DespensaId,
                    despensaNome = item.Despensa.Nome
                });

            // **LÓGICA INTELIGENTE: Verificar se precisa adicionar à lista de compras**
            var mudancaNaLista = await VerificarEGerenciarListaDeCompras(int.Parse(userId), item);
            
            // Se houve mudança na lista, notificar todos os membros
            if (mudancaNaLista)
            {
                await NotificarMembrosListaDeComprasAtualizada(item.DespensaId);
            }

            return Ok(new { 
                message = "Item atualizado com sucesso!",
                estoqueAbaixoDoMinimo = item.Quantidade <= item.QuantidadeMinima,
                mudancaNaListaDeCompras = mudancaNaLista
            });
        }

        // POST: api/estoque/{id}/consumir - Consome quantidade do estoque
        [HttpPost("{id}/consumir")]
        public async Task<IActionResult> ConsumirEstoque(int id, [FromBody] ConsumirEstoqueDto request)
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userId == null)
            {
                return Unauthorized();
            }

            var item = await _context.EstoqueItens
                .Include(e => e.Despensa)
                .Include(e => e.Produto)
                .FirstOrDefaultAsync(e => e.Id == id);

            if (item == null)
            {
                return NotFound("Item não encontrado.");
            }

            // Verificar permissão para acessar a despensa
            if (!await _permissionService.PodeAcederDespensa(int.Parse(userId), item.DespensaId))
            {
                return Forbid();
            }

            if (request.QuantidadeConsumida <= 0)
            {
                return BadRequest("Quantidade consumida deve ser maior que zero.");
            }

            if (request.QuantidadeConsumida > item.Quantidade)
            {
                return BadRequest("Quantidade consumida não pode ser maior que o estoque disponível.");
            }

            var agora = DateTime.UtcNow;

            // **NOVO: Registar histórico de consumo para IA**
            var historicoConsumo = new HistoricoConsumo
            {
                EstoqueItemId = item.Id,
                QuantidadeConsumida = request.QuantidadeConsumida,
                DataDoConsumo = agora,
                UsuarioId = int.Parse(userId),
                QuantidadeRestanteAposConsumo = item.Quantidade - request.QuantidadeConsumida,
                DiaSemanaDaConsumo = agora.DayOfWeek,
                HoraDaConsumo = agora.Hour
            };

            _context.HistoricosDeConsumo.Add(historicoConsumo);

            // Consumir o estoque
            item.Quantidade -= request.QuantidadeConsumida;
            await _context.SaveChangesAsync();

            // **NOTIFICAÇÃO EM TEMPO REAL**: Estoque consumido
            await _hubContext.Clients.Group($"Despensa-{item.DespensaId}")
                .SendAsync("EstoqueItemAtualizado", new {
                    id = item.Id,
                    produto = item.Produto.Nome,
                    marca = item.Produto.Marca,
                    codigoBarras = item.Produto.CodigoBarras,
                    quantidade = item.Quantidade,
                    quantidadeMinima = item.QuantidadeMinima,
                    estoqueAbaixoDoMinimo = item.Quantidade <= item.QuantidadeMinima,
                    dataValidade = item.DataValidade,
                    despensaId = item.DespensaId,
                    despensaNome = item.Despensa.Nome,
                    acao = "consumido",
                    quantidadeConsumida = request.QuantidadeConsumida
                });

            // **LÓGICA INTELIGENTE: Verificar se precisa adicionar à lista de compras**
            var mudancaNaLista = await VerificarEGerenciarListaDeCompras(int.Parse(userId), item);

            // Se foi adicionado à lista, notificar todos os membros
            if (mudancaNaLista)
            {
                await NotificarMembrosListaDeComprasAtualizada(item.DespensaId);
            }

            return Ok(new { 
                message = "Estoque consumido com sucesso!",
                quantidadeRestante = item.Quantidade,
                estoqueAbaixoDoMinimo = item.Quantidade <= item.QuantidadeMinima,
                adicionadoAListaDeCompras = mudancaNaLista,
                historicoRegistrado = true // Novo campo para confirmar que o histórico foi salvo
            });
        }

        // DELETE: api/estoque/{id} - Remove um item do estoque
        [HttpDelete("{id}")]
        public async Task<IActionResult> RemoverDoEstoque(int id)
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userId == null)
            {
                return Unauthorized();
            }

            var item = await _context.EstoqueItens
                .Include(e => e.Despensa)
                .Include(e => e.Produto)
                .FirstOrDefaultAsync(e => e.Id == id);

            if (item == null)
            {
                return NotFound("Item não encontrado.");
            }

            // Verificar permissão para acessar a despensa
            if (!await _permissionService.PodeAcederDespensa(int.Parse(userId), item.DespensaId))
            {
                return Forbid();
            }

            var despensaId = item.DespensaId;
            var itemInfo = new {
                id = item.Id,
                produto = item.Produto.Nome,
                marca = item.Produto.Marca,
                quantidade = item.Quantidade,
                despensaId = despensaId
            };

            _context.EstoqueItens.Remove(item);
            await _context.SaveChangesAsync();

            // **NOTIFICAÇÃO EM TEMPO REAL**: Item removido
            await _hubContext.Clients.Group($"Despensa-{despensaId}")
                .SendAsync("EstoqueItemRemovido", itemInfo);

            return Ok(new { message = "Item removido do estoque com sucesso!" });
        }

        [HttpGet("usuario-info")]
        public IActionResult GetUsuarioInfo()
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            var userName = User.FindFirst(ClaimTypes.Name)?.Value;
            var userEmail = User.FindFirst(ClaimTypes.Email)?.Value;

            return Ok(new {
                id = userId,
                nome = userName,
                email = userEmail,
                message = "Usuário autenticado com sucesso!"
            });
        }

        // **MÉTODO PRIVADO CORRIGIDO: Lógica completa para lista de compras inteligente**
        private async Task<bool> VerificarEGerenciarListaDeCompras(int userId, EstoqueItem item)
        {
            bool mudancaRealizada = false;
            
            // É preciso obter o ID do "dono" ou de uma referência de utilizador da despensa para a lista de compras
            var despensa = await _context.Despensas.Include(d => d.Membros).FirstOrDefaultAsync(d => d.Id == item.DespensaId);
            if (despensa == null) return false;

            var donoDaDespensa = despensa.Membros.FirstOrDefault(m => m.Papel == PapelDespensa.Dono);
            if (donoDaDespensa == null) return false; // Toda despensa deve ter um dono
            
            int proprietarioListaId = donoDaDespensa.UsuarioId;

            // **CENÁRIO 1: Estoque ABAIXO do mínimo - ADICIONAR à lista**
            if (item.Quantidade <= item.QuantidadeMinima)
            {
                // Verificar se o item já não está na lista de compras do proprietário
                var itemJaNaLista = await _context.ListaDeComprasItens
                    .AnyAsync(l => l.UsuarioId == proprietarioListaId && l.ProdutoId == item.ProdutoId && !l.Comprado);

                if (!itemJaNaLista)
                {
                    var novoItemLista = new ListaDeComprasItem
                    {
                        UsuarioId = proprietarioListaId,
                        ProdutoId = item.ProdutoId,
                        QuantidadeDesejada = Math.Max(item.QuantidadeMinima * 2, 1), // Sugerir comprar o dobro do mínimo
                        DataCriacao = DateTime.UtcNow
                    };

                    _context.ListaDeComprasItens.Add(novoItemLista);
                    await _context.SaveChangesAsync();
                    
                    mudancaRealizada = true;
                    Console.WriteLine($"✅ Item {item.Produto.Nome} ADICIONADO à lista de compras");
                }
            }
            // **CENÁRIO 2: Estoque ACIMA do mínimo - REMOVER da lista (se estiver)**
            else if (item.Quantidade > item.QuantidadeMinima)
            {
                // Buscar item não comprado na lista de compras
                var itemNaLista = await _context.ListaDeComprasItens
                    .FirstOrDefaultAsync(l => l.UsuarioId == proprietarioListaId && l.ProdutoId == item.ProdutoId && !l.Comprado);

                if (itemNaLista != null)
                {
                    _context.ListaDeComprasItens.Remove(itemNaLista);
                    await _context.SaveChangesAsync();
                    
                    mudancaRealizada = true;
                    Console.WriteLine($"🗑️ Item {item.Produto.Nome} REMOVIDO da lista de compras");
                }
            }
            
            return mudancaRealizada;
        }

        // **MÉTODO PRIVADO: Notificar membros sobre mudanças na lista de compras**
        private async Task NotificarMembrosListaDeComprasAtualizada(int despensaId)
        {
            // Buscar todos os membros da despensa
            var membros = await _context.MembrosDespensa
                .Where(md => md.DespensaId == despensaId)
                .Select(md => md.UsuarioId.ToString())
                .ToListAsync();

            // Notificar todos os membros sobre a mudança na lista de compras
            foreach (var membroId in membros)
            {
                await _hubContext.Clients.Group($"User-{membroId}")
                    .SendAsync("ListaDeComprasAtualizada", new { despensaId = despensaId });
            }
        }

        // GET: api/estoque/{id}/previsao - **NOVO ENDPOINT DE IA**
        [HttpGet("{id}/previsao")]
        public async Task<IActionResult> GetPrevisaoConsumo(int id)
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userId == null)
            {
                return Unauthorized();
            }

            var item = await _context.EstoqueItens
                .Include(e => e.Despensa)
                .Include(e => e.Produto)
                .FirstOrDefaultAsync(e => e.Id == id);

            if (item == null)
            {
                return NotFound("Item não encontrado.");
            }

            // Verificar permissão para acessar a despensa
            if (!await _permissionService.PodeAcederDespensa(int.Parse(userId), item.DespensaId))
            {
                return Forbid();
            }

            // **VERIFICAÇÃO DE PLANO: Funcionalidades de IA são apenas para Premium**
            if (!await _subscriptionService.UsuarioTemAcessoAIAsync(int.Parse(userId)))
            {
                return new ObjectResult(new {
                    error = "Funcionalidade Premium necessária",
                    message = "As previsões de IA são uma funcionalidade Premium. Faça upgrade para obter análises inteligentes sobre o consumo dos seus produtos.",
                    upgradeRequired = true,
                    currentPlan = "Free",
                    feature = "Previsões de IA"
                }) { StatusCode = 402 }; // Payment Required
            }

            try
            {
                // Obter previsão usando IA
                var previsao = await _predictionService.ObterPrevisaoConsumoAsync(id);

                var response = new {
                    estoqueItemId = id,
                    produto = new {
                        nome = item.Produto.Nome,
                        marca = item.Produto.Marca
                    },
                    quantidadeAtual = item.Quantidade,
                    quantidadeMinima = item.QuantidadeMinima,
                    diasRestantesEstimados = previsao.DiasRestantesEstimados,
                    consumoMedioDiario = Math.Round(previsao.ConsumoMedioDiario, 2),
                    statusConfianca = previsao.StatusConfianca,
                    previsaoProximos7Dias = previsao.PrevisaoProximos7Dias.Select(p => Math.Round(p, 2)).ToArray(),
                    totalRegistrosHistorico = previsao.TotalRegistrosUtilizados,
                    alertas = GerarAlertas(previsao, item),
                    recomendacoes = GerarRecomendacoes(previsao, item),
                    dataUltimaAtualizacao = DateTime.UtcNow
                };

                return Ok(response);
            }
            catch (Exception ex)
            {
                return BadRequest(new { 
                    error = "Erro ao calcular previsão",
                    message = ex.Message 
                });
            }
        }

        // **MÉTODO PRIVADO: Gerar alertas baseados na previsão**
        private List<string> GerarAlertas(PredictionService.PrevisaoResultado previsao, EstoqueItem item)
        {
            var alertas = new List<string>();

            if (previsao.DiasRestantesEstimados <= 0)
            {
                alertas.Add("⚠️ Produto esgotado");
            }
            else if (previsao.DiasRestantesEstimados <= 2)
            {
                alertas.Add("🚨 Crítico: Acabará em 2 dias ou menos");
            }
            else if (previsao.DiasRestantesEstimados <= 5)
            {
                alertas.Add("⚡ Atenção: Acabará em breve");
            }

            if (previsao.StatusConfianca == "Baixa" || previsao.StatusConfianca == "Dados Insuficientes")
            {
                alertas.Add("📊 Previsão baseada em poucos dados");
            }

            if (item.Quantidade <= item.QuantidadeMinima)
            {
                alertas.Add("📦 Estoque abaixo do mínimo");
            }

            return alertas;
        }

        // **MÉTODO PRIVADO: Gerar recomendações baseadas na previsão**
        private List<string> GerarRecomendacoes(PredictionService.PrevisaoResultado previsao, EstoqueItem item)
        {
            var recomendacoes = new List<string>();

            if (previsao.DiasRestantesEstimados <= 3 && previsao.DiasRestantesEstimados > 0)
            {
                recomendacoes.Add($"🛒 Comprar nos próximos 2 dias");
            }
            else if (previsao.DiasRestantesEstimados <= 7 && previsao.DiasRestantesEstimados > 3)
            {
                recomendacoes.Add($"📝 Adicionar à lista de compras da próxima semana");
            }

            if (previsao.ConsumoMedioDiario > 0)
            {
                var quantidadeSugerida = Math.Ceiling(previsao.ConsumoMedioDiario * 14); // 2 semanas
                recomendacoes.Add($"💡 Sugestão: Comprar {quantidadeSugerida} unidades (2 semanas)");
            }

            if (previsao.StatusConfianca == "Baixa")
            {
                recomendacoes.Add("📈 Continue usando para melhorar a precisão das previsões");
            }

            return recomendacoes;
        }

        // **MÉTODO PRIVADO: Gerar alertas detalhados para tela de detalhes**
        private List<object> GerarAlertasDetalhados(EstoqueItem item, int? diasParaVencer, double consumoMedioDiario)
        {
            var alertas = new List<object>();

            // Alertas de vencimento
            if (diasParaVencer.HasValue)
            {
                if (diasParaVencer.Value < 0)
                {
                    alertas.Add(new {
                        tipo = "vencimento",
                        nivel = "critico",
                        icone = "🚨",
                        titulo = "Produto Vencido",
                        mensagem = $"Venceu há {Math.Abs(diasParaVencer.Value)} dias",
                        acao = "Verificar se ainda está bom para consumo"
                    });
                }
                else if (diasParaVencer.Value <= 3)
                {
                    alertas.Add(new {
                        tipo = "vencimento",
                        nivel = "alto",
                        icone = "⚠️",
                        titulo = "Vence Muito Em Breve",
                        mensagem = $"Vence em {diasParaVencer.Value} dias",
                        acao = "Consumir prioritariamente"
                    });
                }
                else if (diasParaVencer.Value <= 7)
                {
                    alertas.Add(new {
                        tipo = "vencimento",
                        nivel = "medio",
                        icone = "⏰",
                        titulo = "Vence Em Breve",
                        mensagem = $"Vence em {diasParaVencer.Value} dias",
                        acao = "Planejar o consumo"
                    });
                }
            }

            // Alertas de estoque
            if (item.Quantidade <= 0)
            {
                alertas.Add(new {
                    tipo = "estoque",
                    nivel = "critico",
                    icone = "📦",
                    titulo = "Estoque Zerado",
                    mensagem = "Produto em falta",
                    acao = "Repor urgentemente"
                });
            }
            else if (item.Quantidade <= item.QuantidadeMinima)
            {
                alertas.Add(new {
                    tipo = "estoque",
                    nivel = "alto",
                    icone = "📉",
                    titulo = "Estoque Baixo",
                    mensagem = $"Apenas {item.Quantidade} unidades restantes",
                    acao = "Adicionar à lista de compras"
                });
            }

            // Alertas de consumo
            if (consumoMedioDiario > 0)
            {
                var diasRestantesEstimados = item.Quantidade / consumoMedioDiario;
                if (diasRestantesEstimados <= 3)
                {
                    alertas.Add(new {
                        tipo = "consumo",
                        nivel = "medio",
                        icone = "📊",
                        titulo = "Acabará Em Breve",
                        mensagem = $"Com base no consumo atual, durará apenas {Math.Round(diasRestantesEstimados, 1)} dias",
                        acao = "Considerar comprar mais"
                    });
                }
            }

            return alertas;
        }

        // **MÉTODO PRIVADO: Gerar recomendações detalhadas para tela de detalhes**
        private List<object> GerarRecomendacoesDetalhadas(EstoqueItem item, int? diasParaVencer, double consumoMedioDiario)
        {
            var recomendacoes = new List<object>();

            // Recomendações de compra
            if (item.Quantidade <= item.QuantidadeMinima)
            {
                var quantidadeSugerida = Math.Max(item.QuantidadeMinima * 2, 5);
                recomendacoes.Add(new {
                    tipo = "compra",
                    icone = "🛒",
                    titulo = "Repor Estoque",
                    descricao = $"Sugerimos comprar {quantidadeSugerida} unidades",
                    prioridade = "alta"
                });
            }

            // Recomendações de consumo baseadas no vencimento
            if (diasParaVencer.HasValue && diasParaVencer.Value <= 7 && diasParaVencer.Value > 0)
            {
                recomendacoes.Add(new {
                    tipo = "consumo",
                    icone = "🍽️",
                    titulo = "Consumo Prioritário",
                    descricao = "Use este produto primeiro devido ao vencimento próximo",
                    prioridade = "alta"
                });
            }

            // Recomendações de organização
            if (consumoMedioDiario > 0)
            {
                var quantidadeIdeal = Math.Ceiling(consumoMedioDiario * 14); // 2 semanas
                recomendacoes.Add(new {
                    tipo = "organizacao",
                    icone = "📋",
                    titulo = "Quantidade Ideal",
                    descricao = $"Para 2 semanas de consumo: {quantidadeIdeal} unidades",
                    prioridade = "baixa"
                });
            }

            // Recomendação de preço (se não tem preço cadastrado)
            if (item.Preco == null)
            {
                recomendacoes.Add(new {
                    tipo = "dados",
                    icone = "💰",
                    titulo = "Cadastrar Preço",
                    descricao = "Adicione o preço para análises financeiras",
                    prioridade = "baixa"
                });
            }

            return recomendacoes;
        }
    }

    // DTOs atualizados
    public class AdicionarEstoqueDto
    {
        public int DespensaId { get; set; } // Obrigatório especificar a despensa
        public int? ProdutoId { get; set; } // Agora pode ser null
        public string? NomeProduto { get; set; } // Novo campo para nome do produto
        public int Quantidade { get; set; }
        public int QuantidadeMinima { get; set; } = 1;
        public DateTime? DataValidade { get; set; }
    }

    public class AtualizarEstoqueDto
    {
        public int Quantidade { get; set; }
        public int QuantidadeMinima { get; set; } = 1;
        public DateTime? DataValidade { get; set; }
    }

    public class ConsumirEstoqueDto
    {
        public int QuantidadeConsumida { get; set; }
    }
} 