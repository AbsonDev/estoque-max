using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using EstoqueApp.Api.Data;
using EstoqueApp.Api.Models;

namespace EstoqueApp.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class EstoqueController : ControllerBase
    {
        private readonly EstoqueContext _context;

        public EstoqueController(EstoqueContext context)
        {
            _context = context;
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

            var query = _context.EstoqueItens
                .Include(e => e.Produto)
                .Include(e => e.Despensa)
                .Where(e => e.Despensa.UsuarioId == int.Parse(userId));

            // Se foi especificada uma despensa, filtrar por ela
            if (despensaId.HasValue)
            {
                query = query.Where(e => e.DespensaId == despensaId.Value);
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

            // Verificar se a despensa existe e pertence ao usuário
            var despensa = await _context.Despensas
                .FirstOrDefaultAsync(d => d.Id == request.DespensaId && d.UsuarioId == int.Parse(userId));

            if (despensa == null)
            {
                return NotFound("Despensa não encontrada ou não pertence ao usuário.");
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
                DataValidade = request.DataValidade
            };

            _context.EstoqueItens.Add(novoItem);
            await _context.SaveChangesAsync();

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
                .FirstOrDefaultAsync(e => e.Id == id && e.Despensa.UsuarioId == int.Parse(userId));

            if (item == null)
            {
                return NotFound("Item não encontrado ou não pertence ao usuário.");
            }

            item.Quantidade = request.Quantidade;
            item.DataValidade = request.DataValidade;

            await _context.SaveChangesAsync();

            return Ok(new { message = "Item atualizado com sucesso!" });
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
                .FirstOrDefaultAsync(e => e.Id == id && e.Despensa.UsuarioId == int.Parse(userId));

            if (item == null)
            {
                return NotFound("Item não encontrado ou não pertence ao usuário.");
            }

            _context.EstoqueItens.Remove(item);
            await _context.SaveChangesAsync();

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
    }

    // DTOs atualizados
    public class AdicionarEstoqueDto
    {
        public int DespensaId { get; set; } // Agora é obrigatório especificar a despensa
        public int ProdutoId { get; set; }
        public int Quantidade { get; set; }
        public DateTime? DataValidade { get; set; }
    }

    public class AtualizarEstoqueDto
    {
        public int Quantidade { get; set; }
        public DateTime? DataValidade { get; set; }
    }
} 