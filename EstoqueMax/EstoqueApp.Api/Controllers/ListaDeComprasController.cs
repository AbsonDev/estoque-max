using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using EstoqueApp.Api.Data;
using EstoqueApp.Api.Models;
using EstoqueApp.Api.Services;

namespace EstoqueApp.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ListaDeComprasController : ControllerBase
    {
        private readonly EstoqueContext _context;
        private readonly IPermissionService _permissionService;

        public ListaDeComprasController(EstoqueContext context, IPermissionService permissionService)
        {
            _context = context;
            _permissionService = permissionService;
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
                    dataCriacao = l.DataCriacao
                })
                .ToListAsync();

            var resumo = new {
                totalItens = listaDeCompras.Count,
                itensAutomaticos = listaDeCompras.Count(l => l.produto != null),
                itensManuais = listaDeCompras.Count(l => l.produto == null),
                listaDeCompras = listaDeCompras
            };

            return Ok(resumo);
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
                DescricaoManual = request.DescricaoManual,
                QuantidadeDesejada = request.QuantidadeDesejada > 0 ? request.QuantidadeDesejada : 1,
                DataCriacao = DateTime.Now
            };

            _context.ListaDeComprasItens.Add(novoItem);
            await _context.SaveChangesAsync();

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
            
            // Se foi fornecida uma despensa para adicionar ao estoque
            if (request.DespensaId.HasValue && item.ProdutoId.HasValue)
            {
                // Verificar se o usuário tem permissão para acessar a despensa
                if (!await _permissionService.PodeAcederDespensa(int.Parse(userId), request.DespensaId.Value))
                {
                    return Forbid("Você não tem permissão para acessar a despensa especificada.");
                }

                // Procurar se já existe um item do mesmo produto na despensa
                var estoqueExistente = await _context.EstoqueItens
                    .FirstOrDefaultAsync(e => e.DespensaId == request.DespensaId.Value && e.ProdutoId == item.ProdutoId.Value);

                if (estoqueExistente != null)
                {
                    // Atualizar quantidade existente
                    estoqueExistente.Quantidade += request.QuantidadeComprada > 0 ? request.QuantidadeComprada : item.QuantidadeDesejada;
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
                }
            }

            await _context.SaveChangesAsync();

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

            _context.ListaDeComprasItens.Remove(item);
            await _context.SaveChangesAsync();

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

    // DTOs
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