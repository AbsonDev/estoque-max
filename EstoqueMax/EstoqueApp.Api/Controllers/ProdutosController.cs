using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using EstoqueApp.Api.Data;
using EstoqueApp.Api.Models;
using System.Security.Claims;

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
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userId == null)
            {
                return Unauthorized();
            }

            // Buscar produtos públicos + privados do usuário
            var produtos = await _context.Produtos
                .Where(p => p.Visibilidade == TipoVisibilidadeProduto.Publico ||
                           (p.Visibilidade == TipoVisibilidadeProduto.Privado && p.UsuarioCriadorId == int.Parse(userId)))
                .OrderBy(p => p.Nome)
                .Select(p => new {
                    id = p.Id,
                    nome = p.Nome,
                    marca = p.Marca,
                    codigoBarras = p.CodigoBarras,
                    categoria = p.Categoria,
                    visibilidade = p.Visibilidade.ToString().ToLower(),
                    dataCriacao = p.DataCriacao
                })
                .ToListAsync();

            return Ok(produtos);
        }

        // GET: api/produtos/buscar?query={nome}
        [HttpGet("buscar")]
        public async Task<IActionResult> BuscarProdutos([FromQuery] string? query = null)
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userId == null)
            {
                return Unauthorized();
            }

            var queryBuilder = _context.Produtos.AsQueryable();

            // Filtrar por visibilidade: públicos + privados do usuário
            queryBuilder = queryBuilder.Where(p => 
                p.Visibilidade == TipoVisibilidadeProduto.Publico ||
                (p.Visibilidade == TipoVisibilidadeProduto.Privado && p.UsuarioCriadorId == int.Parse(userId))
            );

            // Aplicar filtro de busca se fornecido
            if (!string.IsNullOrWhiteSpace(query))
            {
                var queryNormalizada = query.ToLower();
                queryBuilder = queryBuilder.Where(p => 
                    p.Nome.ToLower().Contains(queryNormalizada) ||
                    (p.Marca != null && p.Marca.ToLower().Contains(queryNormalizada))
                );
            }

            // Ordenar por nome e limitar resultados
            var produtos = await queryBuilder
                .OrderBy(p => p.Nome)
                .Take(50) // Limitar a 50 resultados
                .Select(p => new {
                    id = p.Id,
                    nome = p.Nome,
                    marca = p.Marca,
                    categoria = p.Categoria,
                    visibilidade = p.Visibilidade.ToString().ToLower(),
                    dataCriacao = p.DataCriacao
                })
                .ToListAsync();

            return Ok(new {
                total = produtos.Count,
                produtos = produtos
            });
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
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userId == null)
            {
                return Unauthorized();
            }

            // Verificar se já existe um produto com o mesmo código de barras
            if (!string.IsNullOrWhiteSpace(request.CodigoBarras) && 
                await _context.Produtos.AnyAsync(p => p.CodigoBarras == request.CodigoBarras))
            {
                return BadRequest("Já existe um produto com este código de barras.");
            }

            var produto = new Produto
            {
                Nome = request.Nome,
                CodigoBarras = request.CodigoBarras,
                Marca = request.Marca,
                Categoria = request.Categoria,
                Visibilidade = TipoVisibilidadeProduto.Privado, // Produtos criados manualmente são privados
                UsuarioCriadorId = int.Parse(userId),
                DataCriacao = DateTime.UtcNow
            };

            _context.Produtos.Add(produto);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetProduto), new { id = produto.Id }, new {
                id = produto.Id,
                nome = produto.Nome,
                marca = produto.Marca,
                codigoBarras = produto.CodigoBarras,
                categoria = produto.Categoria,
                visibilidade = produto.Visibilidade.ToString().ToLower(),
                dataCriacao = produto.DataCriacao
            });
        }

        // POST: api/produtos/tornar-publico/{id} - Endpoint para admin tornar produto público
        [HttpPost("tornar-publico/{id}")]
        [Authorize(Roles = "Admin")] // Requer role de admin
        public async Task<IActionResult> TornarProdutoPublico(int id)
        {
            var produto = await _context.Produtos.FindAsync(id);
            if (produto == null)
            {
                return NotFound("Produto não encontrado.");
            }

            produto.Visibilidade = TipoVisibilidadeProduto.Publico;
            produto.UsuarioCriadorId = null; // Remove referência ao criador
            await _context.SaveChangesAsync();

            return Ok(new { 
                message = "Produto tornado público com sucesso!",
                produtoId = produto.Id,
                produtoNome = produto.Nome
            });
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
        public string? CodigoBarras { get; set; }
        public string? Marca { get; set; }
        public string? Categoria { get; set; }
    }
} 