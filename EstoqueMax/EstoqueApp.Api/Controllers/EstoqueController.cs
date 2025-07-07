using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using EstoqueApp.Api.Data;
using EstoqueApp.Api.Models;
using EstoqueApp.Api.Services;
using Microsoft.AspNetCore.SignalR;
using EstoqueApp.Api.Hubs;

namespace EstoqueApp.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class EstoqueController : ControllerBase
    {
        private readonly EstoqueContext _context;
        private readonly IPermissionService _permissionService;
        private readonly IHubContext<EstoqueHub> _hubContext;

        public EstoqueController(EstoqueContext context, IPermissionService permissionService, IHubContext<EstoqueHub> hubContext)
        {
            _context = context;
            _permissionService = permissionService;
            _hubContext = hubContext;
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
                    return Forbid("Você não tem permissão para acessar esta despensa.");
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
                return Forbid("Você não tem permissão para acessar esta despensa.");
            }

            // Verificar se o produto existe
            var produto = await _context.Produtos.FindAsync(request.ProdutoId);
            if (produto == null)
            {
                return NotFound("Produto não encontrado.");
            }

            var novoItem = new EstoqueItem
            {
                DespensaId = request.DespensaId,
                ProdutoId = request.ProdutoId,
                Quantidade = request.Quantidade,
                QuantidadeMinima = request.QuantidadeMinima > 0 ? request.QuantidadeMinima : 1,
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

            return Ok(new { message = "Item adicionado ao estoque com sucesso!" });
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
                return Forbid("Você não tem permissão para acessar esta despensa.");
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
            await VerificarEAdicionarAListaDeCompras(int.Parse(userId), item);

            return Ok(new { 
                message = "Item atualizado com sucesso!",
                estoqueAbaixoDoMinimo = item.Quantidade <= item.QuantidadeMinima
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
                return Forbid("Você não tem permissão para acessar esta despensa.");
            }

            if (request.QuantidadeConsumida <= 0)
            {
                return BadRequest("Quantidade consumida deve ser maior que zero.");
            }

            if (request.QuantidadeConsumida > item.Quantidade)
            {
                return BadRequest("Quantidade consumida não pode ser maior que o estoque disponível.");
            }

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
            var adicionadoALista = await VerificarEAdicionarAListaDeCompras(int.Parse(userId), item);

            // Se foi adicionado à lista, notificar todos os membros
            if (adicionadoALista)
            {
                await NotificarMembrosListaDeComprasAtualizada(item.DespensaId);
            }

            return Ok(new { 
                message = "Estoque consumido com sucesso!",
                quantidadeRestante = item.Quantidade,
                estoqueAbaixoDoMinimo = item.Quantidade <= item.QuantidadeMinima,
                adicionadoAListaDeCompras = adicionadoALista
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
                return Forbid("Você não tem permissão para acessar esta despensa.");
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

        // **MÉTODO PRIVADO: Lógica de negócio para lista de compras inteligente**
        private async Task<bool> VerificarEAdicionarAListaDeCompras(int userId, EstoqueItem item)
        {
            // Só adiciona se o estoque estiver abaixo do mínimo
            if (item.Quantidade <= item.QuantidadeMinima)
            {
                // Verificar se o item já não está na lista de compras do usuário
                var itemJaNaLista = await _context.ListaDeComprasItens
                    .AnyAsync(l => l.UsuarioId == userId && l.ProdutoId == item.ProdutoId && !l.Comprado);

                if (!itemJaNaLista)
                {
                    var novoItemLista = new ListaDeComprasItem
                    {
                        UsuarioId = userId,
                        ProdutoId = item.ProdutoId,
                        QuantidadeDesejada = item.QuantidadeMinima,
                        DataCriacao = DateTime.Now
                    };

                    _context.ListaDeComprasItens.Add(novoItemLista);
                    await _context.SaveChangesAsync();
                    
                    return true; // Foi adicionado à lista
                }
            }
            
            return false; // Não foi adicionado à lista
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
    }

    // DTOs atualizados
    public class AdicionarEstoqueDto
    {
        public int DespensaId { get; set; } // Agora é obrigatório especificar a despensa
        public int ProdutoId { get; set; }
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