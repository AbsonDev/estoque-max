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
    public class ListaDeComprasController : ControllerBase
    {
        private readonly EstoqueContext _context;
        private readonly IPermissionService _permissionService;
        private readonly IHubContext<EstoqueHub> _hubContext;
        private readonly PredictionService _predictionService;

        public ListaDeComprasController(EstoqueContext context, IPermissionService permissionService, IHubContext<EstoqueHub> hubContext, PredictionService predictionService)
        {
            _context = context;
            _permissionService = permissionService;
            _hubContext = hubContext;
            _predictionService = predictionService;
        }

        // GET: api/listadecompras
        [HttpGet]
        public async Task<IActionResult> GetListaDeCompras()
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userId == null)
            {
                return Unauthorized();
            }

            // Lista tradicional (itens já adicionados)
            var listaDeCompras = await _context.ListaDeComprasItens
                .Include(l => l.Produto)
                .Where(l => l.UsuarioId == int.Parse(userId) && !l.Comprado)
                .OrderBy(l => l.DataCriacao)
                .Select(l => new {
                    id = l.Id,
                    produto = l.Produto != null ? new {
                        id = l.Produto.Id,
                        nome = l.Produto.Nome,
                        marca = l.Produto.Marca,
                        codigoBarras = l.Produto.CodigoBarras
                    } : null,
                    descricaoManual = l.DescricaoManual,
                    quantidadeDesejada = l.QuantidadeDesejada,
                    comprado = l.Comprado,
                    dataCriacao = l.DataCriacao,
                    tipo = "tradicional" // Distinguir de sugestões IA
                })
                .ToListAsync();

            // **NOVO: Sugestões preditivas usando IA**
            var sugestoesPreditivas = await GerarSugestoesPreditivasAsync(int.Parse(userId));

            var resumo = new {
                totalItens = listaDeCompras.Count,
                itensAutomaticos = listaDeCompras.Count(l => l.produto != null),
                itensManuais = listaDeCompras.Count(l => l.produto == null),
                listaDeCompras = listaDeCompras,
                
                // **NOVO: Seção de IA**
                sugestoesPreditivas = new {
                    totalSugestoes = sugestoesPreditivas.Count,
                    sugestoesUrgentes = sugestoesPreditivas.Count(s => s.DiasRestantes <= 3),
                    sugestoesModeradas = sugestoesPreditivas.Count(s => s.DiasRestantes > 3 && s.DiasRestantes <= 7),
                    itens = sugestoesPreditivas
                },
                
                dataUltimaAtualizacao = DateTime.UtcNow,
                versaoIA = "v1.0"
            };

            return Ok(resumo);
        }

        // **NOVO MÉTODO: Gerar sugestões preditivas usando IA**
        private async Task<List<SugestaoPreditiva>> GerarSugestoesPreditivasAsync(int userId)
        {
            try
            {
                // Buscar todas as despensas que o usuário tem acesso
                var despensasIds = await _permissionService.GetDespensasDoUsuario(userId);

                // Buscar itens de estoque dessas despensas
                var itensEstoque = await _context.EstoqueItens
                    .Include(e => e.Produto)
                    .Include(e => e.Despensa)
                    .Where(e => despensasIds.Contains(e.DespensaId) && e.Quantidade > 0)
                    .ToListAsync();

                var sugestoes = new List<SugestaoPreditiva>();

                foreach (var item in itensEstoque)
                {
                    try
                    {
                        // Verificar se já está na lista de compras manual
                        var jaAdicionado = await _context.ListaDeComprasItens
                            .AnyAsync(l => l.UsuarioId == userId && l.ProdutoId == item.ProdutoId && !l.Comprado);

                        if (jaAdicionado) continue; // Pular se já foi adicionado manualmente

                        // Obter previsão da IA
                        var previsao = await _predictionService.ObterPrevisaoConsumoAsync(item.Id);

                        // Incluir apenas itens que a IA prevê que acabarão em breve (próximos 7 dias)
                        if (previsao.DiasRestantesEstimados > 0 && previsao.DiasRestantesEstimados <= 7)
                        {
                            sugestoes.Add(new SugestaoPreditiva
                            {
                                EstoqueItemId = item.Id,
                                Produto = new {
                                    Id = item.Produto.Id,
                                    Nome = item.Produto.Nome,
                                    Marca = item.Produto.Marca,
                                    CodigoBarras = item.Produto.CodigoBarras
                                },
                                Despensa = new {
                                    Id = item.Despensa.Id,
                                    Nome = item.Despensa.Nome
                                },
                                QuantidadeAtual = item.Quantidade,
                                DiasRestantes = previsao.DiasRestantesEstimados,
                                ConsumoMedioDiario = Math.Round(previsao.ConsumoMedioDiario, 2),
                                QuantidadeSugerida = CalcularQuantidadeSugerida(previsao.ConsumoMedioDiario),
                                Prioridade = DeterminarPrioridade(previsao.DiasRestantesEstimados),
                                Confianca = previsao.StatusConfianca,
                                Tipo = "preditiva",
                                MotivoSugestao = GerarMotivoSugestao(previsao.DiasRestantesEstimados, previsao.ConsumoMedioDiario),
                                DataPrevisao = DateTime.UtcNow
                            });
                        }
                    }
                    catch (Exception)
                    {
                        // Log do erro mas continue processando outros itens
                        // _logger.LogWarning(ex, "Erro ao processar previsão para item {ItemId}", item.Id);
                    }
                }

                // Ordenar por prioridade (mais urgente primeiro)
                return sugestoes.OrderBy(s => s.DiasRestantes).ToList();
            }
            catch (Exception)
            {
                // Em caso de erro, retornar lista vazia para não quebrar a funcionalidade principal
                return new List<SugestaoPreditiva>();
            }
        }

        private int CalcularQuantidadeSugerida(float consumoMedioDiario)
        {
            if (consumoMedioDiario <= 0) return 1;
            
            // Sugerir quantidade para 2 semanas
            return (int)Math.Ceiling(consumoMedioDiario * 14);
        }

        private string DeterminarPrioridade(int diasRestantes)
        {
            return diasRestantes switch
            {
                <= 2 => "Crítica",
                <= 5 => "Alta",
                <= 7 => "Moderada",
                _ => "Baixa"
            };
        }

        private string GerarMotivoSugestao(int diasRestantes, float consumoMedio)
        {
            if (diasRestantes <= 2)
                return $"🚨 Produto acabará em {diasRestantes} dia(s)";
            else if (diasRestantes <= 5)
                return $"⚡ Produto acabará em {diasRestantes} dias - planeje a compra";
            else
                return $"📅 Produto acabará em {diasRestantes} dias - adicione à próxima lista";
        }

        // **NOVO ENDPOINT: Aceitar sugestão preditiva**
        [HttpPost("aceitar-sugestao/{estoqueItemId}")]
        public async Task<IActionResult> AceitarSugestaoPreditiva(int estoqueItemId, [FromBody] AceitarSugestaoDto request)
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userId == null)
            {
                return Unauthorized();
            }

            // Verificar se o item existe e se o usuário tem permissão
            var estoqueItem = await _context.EstoqueItens
                .Include(e => e.Produto)
                .FirstOrDefaultAsync(e => e.Id == estoqueItemId);

            if (estoqueItem == null)
            {
                return NotFound("Item de estoque não encontrado.");
            }

            if (!await _permissionService.PodeAcederDespensa(int.Parse(userId), estoqueItem.DespensaId))
            {
                return Forbid();
            }

            // Verificar se já foi adicionado
            var jaExiste = await _context.ListaDeComprasItens
                .AnyAsync(l => l.UsuarioId == int.Parse(userId) && l.ProdutoId == estoqueItem.ProdutoId && !l.Comprado);

            if (jaExiste)
            {
                return BadRequest("Este produto já está na sua lista de compras.");
            }

            // Adicionar à lista de compras
            var novoItem = new ListaDeComprasItem
            {
                UsuarioId = int.Parse(userId),
                ProdutoId = estoqueItem.ProdutoId,
                QuantidadeDesejada = request.QuantidadeDesejada > 0 ? request.QuantidadeDesejada : 1,
                DataCriacao = DateTime.UtcNow
            };

            _context.ListaDeComprasItens.Add(novoItem);
            await _context.SaveChangesAsync();

            // Notificar via SignalR
            await _hubContext.Clients.Group($"User-{userId}")
                .SendAsync("SugestaoPreditivaAceita", new {
                    estoqueItemId = estoqueItemId,
                    produto = estoqueItem.Produto.Nome,
                    quantidadeAdicionada = novoItem.QuantidadeDesejada,
                    novoItemId = novoItem.Id
                });

            return Ok(new {
                message = "Sugestão aceita e adicionada à lista de compras!",
                itemId = novoItem.Id,
                produto = estoqueItem.Produto.Nome,
                quantidadeDesejada = novoItem.QuantidadeDesejada
            });
        }

        // POST: api/listadecompras/produto
        [HttpPost("produto")]
        public async Task<IActionResult> AdicionarProduto([FromBody] AdicionarProdutoDto request)
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userId == null)
            {
                return Unauthorized();
            }

            // Verificar se o produto existe
            var produto = await _context.Produtos.FindAsync(request.ProdutoId);
            if (produto == null)
            {
                return NotFound("Produto não encontrado.");
            }

            // Verificar se já foi adicionado
            var jaExiste = await _context.ListaDeComprasItens
                .AnyAsync(l => l.UsuarioId == int.Parse(userId) && l.ProdutoId == request.ProdutoId && !l.Comprado);

            if (jaExiste)
            {
                return BadRequest("Este produto já está na sua lista de compras.");
            }

            var novoItem = new ListaDeComprasItem
            {
                UsuarioId = int.Parse(userId),
                ProdutoId = request.ProdutoId,
                DescricaoManual = null, // Produto tem descrição no cadastro
                QuantidadeDesejada = request.QuantidadeDesejada > 0 ? request.QuantidadeDesejada : 1,
                DataCriacao = DateTime.UtcNow
            };

            _context.ListaDeComprasItens.Add(novoItem);
            await _context.SaveChangesAsync();

            // Recarregar com informações do produto
            var itemCompleto = await _context.ListaDeComprasItens
                .Include(l => l.Produto)
                .FirstOrDefaultAsync(l => l.Id == novoItem.Id);

            // **NOTIFICAÇÃO EM TEMPO REAL**: Produto adicionado à lista
            await _hubContext.Clients.Group($"User-{userId}")
                .SendAsync("ListaDeComprasAtualizada", new { 
                    acao = "produtoAdicionado",
                    item = new {
                        id = itemCompleto!.Id,
                        produto = new {
                            id = itemCompleto.Produto!.Id,
                            nome = itemCompleto.Produto.Nome,
                            marca = itemCompleto.Produto.Marca
                        },
                        quantidadeDesejada = itemCompleto.QuantidadeDesejada,
                        dataCriacao = itemCompleto.DataCriacao
                    }
                });

            return Ok(new {
                id = itemCompleto.Id,
                produto = new {
                    id = itemCompleto.Produto.Id,
                    nome = itemCompleto.Produto.Nome,
                    marca = itemCompleto.Produto.Marca
                },
                quantidadeDesejada = itemCompleto.QuantidadeDesejada,
                message = "Produto adicionado à lista de compras com sucesso!"
            });
        }

        // POST: api/listadecompras/manual
        [HttpPost("manual")]
        public async Task<IActionResult> AdicionarItemManual([FromBody] AdicionarItemManualDto request)
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userId == null)
            {
                return Unauthorized();
            }

            var novoItem = new ListaDeComprasItem
            {
                UsuarioId = int.Parse(userId),
                ProdutoId = null, // Item manual não tem produto associado
                DescricaoManual = request.DescricaoManual,
                QuantidadeDesejada = request.QuantidadeDesejada > 0 ? request.QuantidadeDesejada : 1,
                DataCriacao = DateTime.UtcNow
            };

            _context.ListaDeComprasItens.Add(novoItem);
            await _context.SaveChangesAsync();

            // **NOTIFICAÇÃO EM TEMPO REAL**: Item manual adicionado à lista
            await _hubContext.Clients.Group($"User-{userId}")
                .SendAsync("ListaDeComprasAtualizada", new { 
                    acao = "itemManualAdicionado",
                    item = new {
                        id = novoItem.Id,
                        descricaoManual = novoItem.DescricaoManual,
                        quantidadeDesejada = novoItem.QuantidadeDesejada,
                        dataCriacao = novoItem.DataCriacao
                    }
                });

            return Ok(new {
                id = novoItem.Id,
                descricaoManual = novoItem.DescricaoManual,
                quantidadeDesejada = novoItem.QuantidadeDesejada,
                message = "Item adicionado à lista de compras com sucesso!"
            });
        }

        // PUT: api/listadecompras/{id}/marcar-comprado
        [HttpPut("{id}/marcar-comprado")]
        public async Task<IActionResult> MarcarComoComprado(int id, [FromBody] MarcarCompradoDto request)
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userId == null)
            {
                return Unauthorized();
            }

            var item = await _context.ListaDeComprasItens
                .Include(l => l.Produto)
                .FirstOrDefaultAsync(l => l.Id == id && l.UsuarioId == int.Parse(userId));

            if (item == null)
            {
                return NotFound("Item não encontrado na lista de compras.");
            }

            // Marcar como comprado
            item.Comprado = true;
            
            EstoqueItem? estoqueAtualizado = null;
            
            // Se foi fornecida uma despensa para adicionar ao estoque
            if (request.DespensaId.HasValue && item.ProdutoId.HasValue)
            {
                // Verificar se o usuário tem permissão para acessar a despensa
                if (!await _permissionService.PodeAcederDespensa(int.Parse(userId), request.DespensaId.Value))
                {
                    return Forbid();
                }

                // Procurar se já existe um item do mesmo produto na despensa
                var estoqueExistente = await _context.EstoqueItens
                    .Include(e => e.Produto)
                    .Include(e => e.Despensa)
                    .FirstOrDefaultAsync(e => e.DespensaId == request.DespensaId.Value && e.ProdutoId == item.ProdutoId.Value);

                if (estoqueExistente != null)
                {
                    // Atualizar quantidade existente
                    estoqueExistente.Quantidade += request.QuantidadeComprada > 0 ? request.QuantidadeComprada : item.QuantidadeDesejada;
                    estoqueAtualizado = estoqueExistente;
                }
                else
                {
                    // Criar novo item no estoque
                    var novoEstoqueItem = new EstoqueItem
                    {
                        DespensaId = request.DespensaId.Value,
                        ProdutoId = item.ProdutoId.Value,
                        Quantidade = request.QuantidadeComprada > 0 ? request.QuantidadeComprada : item.QuantidadeDesejada,
                        DataValidade = request.DataValidade
                    };
                    
                    _context.EstoqueItens.Add(novoEstoqueItem);
                    await _context.SaveChangesAsync(); // Salvar para gerar o ID
                    
                    // Recarregar com relações
                    estoqueAtualizado = await _context.EstoqueItens
                        .Include(e => e.Produto)
                        .Include(e => e.Despensa)
                        .FirstOrDefaultAsync(e => e.Id == novoEstoqueItem.Id);
                }
            }

            await _context.SaveChangesAsync();

            // **NOTIFICAÇÃO EM TEMPO REAL**: Item marcado como comprado
            await _hubContext.Clients.Group($"User-{userId}")
                .SendAsync("ListaDeComprasAtualizada", new { 
                    acao = "itemComprado",
                    itemId = item.Id
                });

            // **NOTIFICAÇÃO EM TEMPO REAL**: Estoque atualizado (se aplicável)
            if (estoqueAtualizado != null && request.DespensaId.HasValue)
            {
                await _hubContext.Clients.Group($"Despensa-{request.DespensaId.Value}")
                    .SendAsync("EstoqueItemAtualizado", new {
                        id = estoqueAtualizado.Id,
                        produto = estoqueAtualizado.Produto.Nome,
                        marca = estoqueAtualizado.Produto.Marca,
                        codigoBarras = estoqueAtualizado.Produto.CodigoBarras,
                        quantidade = estoqueAtualizado.Quantidade,
                        quantidadeMinima = estoqueAtualizado.QuantidadeMinima,
                        estoqueAbaixoDoMinimo = estoqueAtualizado.Quantidade <= estoqueAtualizado.QuantidadeMinima,
                        dataValidade = estoqueAtualizado.DataValidade,
                        despensaId = estoqueAtualizado.DespensaId,
                        despensaNome = estoqueAtualizado.Despensa.Nome,
                        acao = "compraFinalizada"
                    });
            }

            return Ok(new {
                id = item.Id,
                comprado = item.Comprado,
                estoqueAtualizado = request.DespensaId.HasValue && item.ProdutoId.HasValue,
                message = "Item marcado como comprado com sucesso!"
            });
        }

        // DELETE: api/listadecompras/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> RemoverItem(int id)
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userId == null)
            {
                return Unauthorized();
            }

            var item = await _context.ListaDeComprasItens
                .FirstOrDefaultAsync(l => l.Id == id && l.UsuarioId == int.Parse(userId));

            if (item == null)
            {
                return NotFound("Item não encontrado na lista de compras.");
            }

            var itemInfo = new {
                id = item.Id,
                descricao = item.DescricaoManual,
                produto = item.ProdutoId.HasValue ? "Produto" : "Manual"
            };

            _context.ListaDeComprasItens.Remove(item);
            await _context.SaveChangesAsync();

            // **NOTIFICAÇÃO EM TEMPO REAL**: Item removido da lista
            await _hubContext.Clients.Group($"User-{userId}")
                .SendAsync("ListaDeComprasAtualizada", new { 
                    acao = "itemRemovido",
                    itemId = item.Id,
                    itemInfo = itemInfo
                });

            return Ok(new { message = "Item removido da lista de compras com sucesso!" });
        }

        // GET: api/listadecompras/historico
        [HttpGet("historico")]
        public async Task<IActionResult> GetHistorico()
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userId == null)
            {
                return Unauthorized();
            }

            var historico = await _context.ListaDeComprasItens
                .Include(l => l.Produto)
                .Where(l => l.UsuarioId == int.Parse(userId) && l.Comprado)
                .OrderByDescending(l => l.DataCriacao)
                .Take(50) // Limitar aos últimos 50 itens comprados
                .Select(l => new {
                    id = l.Id,
                    produto = l.Produto != null ? new {
                        id = l.Produto.Id,
                        nome = l.Produto.Nome,
                        marca = l.Produto.Marca
                    } : null,
                    descricaoManual = l.DescricaoManual,
                    quantidadeDesejada = l.QuantidadeDesejada,
                    dataCriacao = l.DataCriacao
                })
                .ToListAsync();

            return Ok(new {
                totalItens = historico.Count,
                historico = historico
            });
        }
    }

    // **NOVO DTO**
    public class AceitarSugestaoDto
    {
        public int QuantidadeDesejada { get; set; } = 1;
    }

    // **NOVO DTO**
    public class AdicionarProdutoDto
    {
        public int ProdutoId { get; set; }
        public int QuantidadeDesejada { get; set; } = 1;
    }

    // **NOVA CLASSE: Para sugestões preditivas**
    public class SugestaoPreditiva
    {
        public int EstoqueItemId { get; set; }
        public object Produto { get; set; } = new object();
        public object Despensa { get; set; } = new object();
        public int QuantidadeAtual { get; set; }
        public int DiasRestantes { get; set; }
        public double ConsumoMedioDiario { get; set; }
        public int QuantidadeSugerida { get; set; }
        public string Prioridade { get; set; } = string.Empty;
        public string Confianca { get; set; } = string.Empty;
        public string Tipo { get; set; } = string.Empty;
        public string MotivoSugestao { get; set; } = string.Empty;
        public DateTime DataPrevisao { get; set; }
    }

    // DTOs existentes
    public class AdicionarItemManualDto
    {
        public string DescricaoManual { get; set; } = string.Empty;
        public int QuantidadeDesejada { get; set; } = 1;
    }

    public class MarcarCompradoDto
    {
        public int? DespensaId { get; set; }
        public int QuantidadeComprada { get; set; } = 0;
        public DateTime? DataValidade { get; set; }
    }
} 