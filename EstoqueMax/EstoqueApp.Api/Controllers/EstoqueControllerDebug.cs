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
    [Route("api/[controller]/debug")]
    [Authorize]
    public class EstoqueControllerDebug : ControllerBase
    {
        private readonly EstoqueContext _context;
        private readonly IPermissionService _permissionService;

        public EstoqueControllerDebug(
            EstoqueContext context, 
            IPermissionService permissionService)
        {
            _context = context;
            _permissionService = permissionService;
        }

        [HttpPost("test")]
        public async Task<IActionResult> TestarAdicionarEstoque([FromBody] AdicionarEstoqueDto request)
        {
            try
            {
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                
                if (userId == null)
                {
                    return Unauthorized();
                }

                // Log dos dados recebidos
                Console.WriteLine($"DEBUG: UserId={userId}, DespensaId={request.DespensaId}, ProdutoId={request.ProdutoId}, NomeProduto={request.NomeProduto}");

                // Verificar permissão
                if (!await _permissionService.PodeAcederDespensa(int.Parse(userId), request.DespensaId))
                {
                    return Forbid();
                }

                // Teste simples: criar produto básico
                if (!string.IsNullOrWhiteSpace(request.NomeProduto))
                {
                    var produto = new Produto
                    {
                        Nome = request.NomeProduto.Trim(),
                        Visibilidade = TipoVisibilidadeProduto.Privado,
                        UsuarioCriadorId = int.Parse(userId),
                        DataCriacao = DateTime.UtcNow
                    };

                    Console.WriteLine($"DEBUG: Criando produto - Nome={produto.Nome}, Visibilidade={produto.Visibilidade}, UsuarioCriadorId={produto.UsuarioCriadorId}");

                    _context.Produtos.Add(produto);
                    await _context.SaveChangesAsync();

                    Console.WriteLine($"DEBUG: Produto criado com ID={produto.Id}");

                    return Ok(new { 
                        success = true,
                        message = "Produto criado com sucesso!",
                        produtoId = produto.Id,
                        produtoNome = produto.Nome
                    });
                }

                return BadRequest("NomeProduto é obrigatório para teste");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"ERRO DEBUG: {ex.Message}");
                Console.WriteLine($"STACK TRACE: {ex.StackTrace}");
                
                return StatusCode(500, new {
                    error = "Erro interno do servidor",
                    message = ex.Message,
                    stackTrace = ex.StackTrace
                });
            }
        }
    }
}

