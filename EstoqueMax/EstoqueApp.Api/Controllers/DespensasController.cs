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
    public class DespensasController : ControllerBase
    {
        private readonly EstoqueContext _context;

        public DespensasController(EstoqueContext context)
        {
            _context = context;
        }

        // GET: api/despensas
        [HttpGet]
        public async Task<IActionResult> GetDespensas()
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userId == null)
            {
                return Unauthorized();
            }

            var despensas = await _context.Despensas
                .Where(d => d.UsuarioId == int.Parse(userId))
                .Select(d => new {
                    id = d.Id,
                    nome = d.Nome,
                    dataCriacao = d.DataCriacao,
                    totalItens = d.EstoqueItens.Count()
                })
                .ToListAsync();

            return Ok(despensas);
        }

        // GET: api/despensas/{id}
        [HttpGet("{id}")]
        public async Task<IActionResult> GetDespensa(int id)
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userId == null)
            {
                return Unauthorized();
            }

            var despensa = await _context.Despensas
                .Include(d => d.EstoqueItens)
                .ThenInclude(e => e.Produto)
                .FirstOrDefaultAsync(d => d.Id == id && d.UsuarioId == int.Parse(userId));

            if (despensa == null)
            {
                return NotFound();
            }

            return Ok(new {
                id = despensa.Id,
                nome = despensa.Nome,
                dataCriacao = despensa.DataCriacao,
                totalItens = despensa.EstoqueItens.Count,
                itens = despensa.EstoqueItens.Select(e => new {
                    id = e.Id,
                    produto = e.Produto.Nome,
                    marca = e.Produto.Marca,
                    quantidade = e.Quantidade,
                    dataValidade = e.DataValidade
                })
            });
        }

        // POST: api/despensas
        [HttpPost]
        public async Task<IActionResult> CriarDespensa([FromBody] CriarDespensaDto request)
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userId == null)
            {
                return Unauthorized();
            }

            var despensa = new Despensa
            {
                Nome = request.Nome,
                UsuarioId = int.Parse(userId),
                DataCriacao = DateTime.Now
            };

            _context.Despensas.Add(despensa);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetDespensa), new { id = despensa.Id }, new {
                id = despensa.Id,
                nome = despensa.Nome,
                dataCriacao = despensa.DataCriacao,
                totalItens = 0
            });
        }

        // PUT: api/despensas/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> AtualizarDespensa(int id, [FromBody] CriarDespensaDto request)
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userId == null)
            {
                return Unauthorized();
            }

            var despensa = await _context.Despensas
                .FirstOrDefaultAsync(d => d.Id == id && d.UsuarioId == int.Parse(userId));

            if (despensa == null)
            {
                return NotFound();
            }

            despensa.Nome = request.Nome;
            await _context.SaveChangesAsync();

            return Ok(new {
                id = despensa.Id,
                nome = despensa.Nome,
                dataCriacao = despensa.DataCriacao,
                message = "Despensa atualizada com sucesso!"
            });
        }

        // DELETE: api/despensas/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeletarDespensa(int id)
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userId == null)
            {
                return Unauthorized();
            }

            var despensa = await _context.Despensas
                .Include(d => d.EstoqueItens)
                .FirstOrDefaultAsync(d => d.Id == id && d.UsuarioId == int.Parse(userId));

            if (despensa == null)
            {
                return NotFound();
            }

            // Verificar se a despensa tem itens
            if (despensa.EstoqueItens.Any())
            {
                return BadRequest("Não é possível deletar uma despensa que contém itens. Remova todos os itens primeiro.");
            }

            _context.Despensas.Remove(despensa);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Despensa deletada com sucesso!" });
        }
    }

    // DTOs
    public class CriarDespensaDto
    {
        public string Nome { get; set; } = string.Empty;
    }
} 