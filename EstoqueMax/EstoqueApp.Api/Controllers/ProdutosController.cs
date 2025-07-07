using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using EstoqueApp.Api.Data;
using EstoqueApp.Api.Models;

namespace EstoqueApp.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ProdutosController : ControllerBase
    {
        private readonly EstoqueContext _context;

        public ProdutosController(EstoqueContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetProdutos()
        {
            var produtos = await _context.Produtos.ToListAsync();
            return Ok(produtos);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetProduto(int id)
        {
            var produto = await _context.Produtos.FindAsync(id);
            if (produto == null)
            {
                return NotFound();
            }
            return Ok(produto);
        }

        [HttpPost]
        public async Task<IActionResult> CriarProduto([FromBody] CriarProdutoDto request)
        {
            // Verificar se já existe um produto com o mesmo código de barras
            if (await _context.Produtos.AnyAsync(p => p.CodigoBarras == request.CodigoBarras))
            {
                return BadRequest("Já existe um produto com este código de barras.");
            }

            var produto = new Produto
            {
                Nome = request.Nome,
                CodigoBarras = request.CodigoBarras,
                Marca = request.Marca
            };

            _context.Produtos.Add(produto);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetProduto), new { id = produto.Id }, produto);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> AtualizarProduto(int id, [FromBody] CriarProdutoDto request)
        {
            var produto = await _context.Produtos.FindAsync(id);
            if (produto == null)
            {
                return NotFound();
            }

            // Verificar se o novo código de barras não está sendo usado por outro produto
            if (await _context.Produtos.AnyAsync(p => p.CodigoBarras == request.CodigoBarras && p.Id != id))
            {
                return BadRequest("Já existe outro produto com este código de barras.");
            }

            produto.Nome = request.Nome;
            produto.CodigoBarras = request.CodigoBarras;
            produto.Marca = request.Marca;

            await _context.SaveChangesAsync();

            return Ok(produto);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeletarProduto(int id)
        {
            var produto = await _context.Produtos.FindAsync(id);
            if (produto == null)
            {
                return NotFound();
            }

            _context.Produtos.Remove(produto);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Produto deletado com sucesso!" });
        }
    }

    // DTO para criar/atualizar produto
    public class CriarProdutoDto
    {
        public string Nome { get; set; } = string.Empty;
        public string CodigoBarras { get; set; } = string.Empty;
        public string? Marca { get; set; }
    }
} 