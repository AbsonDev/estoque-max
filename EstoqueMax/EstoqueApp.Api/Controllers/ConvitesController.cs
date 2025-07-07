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
    public class ConvitesController : ControllerBase
    {
        private readonly EstoqueContext _context;

        public ConvitesController(EstoqueContext context)
        {
            _context = context;
        }

        // GET: api/convites - Lista convites recebidos
        [HttpGet]
        public async Task<IActionResult> GetConvites()
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userId == null)
            {
                return Unauthorized();
            }

            var convites = await _context.ConvitesDespensa
                .Include(c => c.Despensa)
                .Include(c => c.Remetente)
                .Where(c => c.DestinatarioId == int.Parse(userId))
                .OrderByDescending(c => c.DataEnvio)
                .Select(c => new {
                    id = c.Id,
                    despensa = new {
                        id = c.Despensa.Id,
                        nome = c.Despensa.Nome
                    },
                    remetente = new {
                        id = c.Remetente.Id,
                        nome = c.Remetente.Nome,
                        email = c.Remetente.Email
                    },
                    mensagem = c.Mensagem,
                    estado = c.Estado.ToString(),
                    dataEnvio = c.DataEnvio,
                    dataResposta = c.DataResposta
                })
                .ToListAsync();

            var resumo = new {
                totalConvites = convites.Count,
                convitesPendentes = convites.Count(c => c.estado == "Pendente"),
                convitesAceites = convites.Count(c => c.estado == "Aceite"),
                convitesRecusados = convites.Count(c => c.estado == "Recusado"),
                convites = convites
            };

            return Ok(resumo);
        }

        // PUT: api/convites/{id}/aceitar
        [HttpPut("{id}/aceitar")]
        public async Task<IActionResult> AceitarConvite(int id)
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userId == null)
            {
                return Unauthorized();
            }

            var convite = await _context.ConvitesDespensa
                .Include(c => c.Despensa)
                .Include(c => c.Remetente)
                .FirstOrDefaultAsync(c => c.Id == id && c.DestinatarioId == int.Parse(userId));

            if (convite == null)
            {
                return NotFound("Convite não encontrado.");
            }

            if (convite.Estado != EstadoConvite.Pendente)
            {
                return BadRequest("Este convite já foi respondido.");
            }

            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                // Atualizar o convite
                convite.Estado = EstadoConvite.Aceite;
                convite.DataResposta = DateTime.Now;

                // Adicionar o usuário como membro da despensa
                var novoMembro = new MembroDespensa
                {
                    UsuarioId = int.Parse(userId),
                    DespensaId = convite.DespensaId,
                    Papel = PapelDespensa.Membro,
                    DataAcesso = DateTime.Now
                };

                _context.MembrosDespensa.Add(novoMembro);
                await _context.SaveChangesAsync();

                await transaction.CommitAsync();

                return Ok(new {
                    message = "Convite aceito com sucesso!",
                    despensa = new {
                        id = convite.Despensa.Id,
                        nome = convite.Despensa.Nome
                    },
                    remetente = new {
                        nome = convite.Remetente.Nome,
                        email = convite.Remetente.Email
                    }
                });
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }
        }

        // PUT: api/convites/{id}/recusar
        [HttpPut("{id}/recusar")]
        public async Task<IActionResult> RecusarConvite(int id)
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userId == null)
            {
                return Unauthorized();
            }

            var convite = await _context.ConvitesDespensa
                .Include(c => c.Despensa)
                .Include(c => c.Remetente)
                .FirstOrDefaultAsync(c => c.Id == id && c.DestinatarioId == int.Parse(userId));

            if (convite == null)
            {
                return NotFound("Convite não encontrado.");
            }

            if (convite.Estado != EstadoConvite.Pendente)
            {
                return BadRequest("Este convite já foi respondido.");
            }

            // Atualizar o convite
            convite.Estado = EstadoConvite.Recusado;
            convite.DataResposta = DateTime.Now;

            await _context.SaveChangesAsync();

            return Ok(new {
                message = "Convite recusado.",
                despensa = new {
                    id = convite.Despensa.Id,
                    nome = convite.Despensa.Nome
                },
                remetente = new {
                    nome = convite.Remetente.Nome,
                    email = convite.Remetente.Email
                }
            });
        }

        // DELETE: api/convites/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeletarConvite(int id)
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userId == null)
            {
                return Unauthorized();
            }

            var convite = await _context.ConvitesDespensa
                .FirstOrDefaultAsync(c => c.Id == id && c.DestinatarioId == int.Parse(userId));

            if (convite == null)
            {
                return NotFound("Convite não encontrado.");
            }

            _context.ConvitesDespensa.Remove(convite);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Convite deletado com sucesso!" });
        }

        // GET: api/convites/enviados - Lista convites enviados
        [HttpGet("enviados")]
        public async Task<IActionResult> GetConvitesEnviados()
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userId == null)
            {
                return Unauthorized();
            }

            var convitesEnviados = await _context.ConvitesDespensa
                .Include(c => c.Despensa)
                .Include(c => c.Destinatario)
                .Where(c => c.RemetenteId == int.Parse(userId))
                .OrderByDescending(c => c.DataEnvio)
                .Select(c => new {
                    id = c.Id,
                    despensa = new {
                        id = c.Despensa.Id,
                        nome = c.Despensa.Nome
                    },
                    destinatario = new {
                        id = c.Destinatario.Id,
                        nome = c.Destinatario.Nome,
                        email = c.Destinatario.Email
                    },
                    mensagem = c.Mensagem,
                    estado = c.Estado.ToString(),
                    dataEnvio = c.DataEnvio,
                    dataResposta = c.DataResposta
                })
                .ToListAsync();

            return Ok(new {
                totalConvitesEnviados = convitesEnviados.Count,
                convitesPendentes = convitesEnviados.Count(c => c.estado == "Pendente"),
                convitesAceites = convitesEnviados.Count(c => c.estado == "Aceite"),
                convitesRecusados = convitesEnviados.Count(c => c.estado == "Recusado"),
                convites = convitesEnviados
            });
        }
    }
} 