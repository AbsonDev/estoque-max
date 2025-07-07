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
    [Authorize] // <-- MÁGICA ACONTECE AQUI
    public class EstoqueController : ControllerBase
    {
        private readonly EstoqueContext _context;

        public EstoqueController(EstoqueContext context)
        {
            _context = context;
        }

        // Este endpoint só pode ser acessado por usuários autenticados
        [HttpGet]
        public async Task<IActionResult> GetEstoque()
        {
            // Como pegar o ID do usuário logado a partir do token:
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            var userName = User.FindFirst(ClaimTypes.Name)?.Value;

            if (userId == null)
            {
                return Unauthorized();
            }

            // Buscar o estoque para este usuário
            var estoque = await _context.EstoqueItens
                .Include(e => e.Produto)
                .Include(e => e.Usuario)
                .Where(e => e.UsuarioId == int.Parse(userId))
                .ToListAsync();

            return Ok(new { 
                usuario = userName,
                totalItens = estoque.Count,
                estoque = estoque.Select(e => new {
                    id = e.Id,
                    produto = e.Produto.Nome,
                    marca = e.Produto.Marca,
                    codigoBarras = e.Produto.CodigoBarras,
                    quantidade = e.Quantidade,
                    dataValidade = e.DataValidade
                })
            });
        }

        [HttpPost]
        public async Task<IActionResult> AdicionarAoEstoque([FromBody] AdicionarEstoqueDto request)
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

            var novoItem = new EstoqueItem
            {
                UsuarioId = int.Parse(userId),
                ProdutoId = request.ProdutoId,
                Quantidade = request.Quantidade,
                DataValidade = request.DataValidade
            };

            _context.EstoqueItens.Add(novoItem);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Item adicionado ao estoque com sucesso!" });
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

    // DTO para adicionar item ao estoque
    public class AdicionarEstoqueDto
    {
        public int ProdutoId { get; set; }
        public int Quantidade { get; set; }
        public DateTime? DataValidade { get; set; }
    }
} 