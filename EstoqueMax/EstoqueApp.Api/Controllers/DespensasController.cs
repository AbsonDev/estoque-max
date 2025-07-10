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
    public class DespensasController : ControllerBase
    {
        private readonly EstoqueContext _context;
        private readonly IPermissionService _permissionService;
        private readonly ISubscriptionService _subscriptionService;
        private readonly IHubContext<EstoqueHub> _hubContext;

        public DespensasController(
            EstoqueContext context, 
            IPermissionService permissionService, 
            ISubscriptionService subscriptionService,
            IHubContext<EstoqueHub> hubContext)
        {
            _context = context;
            _permissionService = permissionService;
            _subscriptionService = subscriptionService;
            _hubContext = hubContext;
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

            var despensasIds = await _permissionService.GetDespensasDoUsuario(int.Parse(userId));

            var despensas = await _context.Despensas
                .Include(d => d.Membros)
                .ThenInclude(m => m.Usuario)
                .Where(d => despensasIds.Contains(d.Id))
                .Select(d => new {
                    id = d.Id,
                    nome = d.Nome,
                    dataCriacao = d.DataCriacao,
                    totalItens = d.EstoqueItens.Count(),
                    meuPapel = d.Membros.First(m => m.UsuarioId == int.Parse(userId)).Papel.ToString(),
                    totalMembros = d.Membros.Count(),
                    membros = d.Membros.Select(m => new {
                        usuarioId = m.UsuarioId,
                        nome = m.Usuario.Nome,
                        email = m.Usuario.Email,
                        papel = m.Papel.ToString(),
                        dataAcesso = m.DataAcesso
                    })
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

            // Verificar permissão
            if (!await _permissionService.PodeAcederDespensa(int.Parse(userId), id))
            {
                return Forbid();
            }

            var despensa = await _context.Despensas
                .Include(d => d.EstoqueItens)
                .ThenInclude(e => e.Produto)
                .Include(d => d.Membros)
                .ThenInclude(m => m.Usuario)
                .FirstOrDefaultAsync(d => d.Id == id);

            if (despensa == null)
            {
                return NotFound();
            }

            var meuPapel = despensa.Membros.First(m => m.UsuarioId == int.Parse(userId)).Papel;

            return Ok(new {
                id = despensa.Id,
                nome = despensa.Nome,
                dataCriacao = despensa.DataCriacao,
                totalItens = despensa.EstoqueItens.Count,
                meuPapel = meuPapel.ToString(),
                sounDono = meuPapel == PapelDespensa.Dono,
                membros = despensa.Membros.Select(m => new {
                    usuarioId = m.UsuarioId,
                    nome = m.Usuario.Nome,
                    email = m.Usuario.Email,
                    papel = m.Papel.ToString(),
                    dataAcesso = m.DataAcesso
                }),
                itens = despensa.EstoqueItens.Select(e => new {
                    id = e.Id,
                    produto = e.Produto.Nome,
                    marca = e.Produto.Marca,
                    quantidade = e.Quantidade,
                    quantidadeMinima = e.QuantidadeMinima,
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

            // **VERIFICAÇÃO DE PLANO: Usuários Free têm limite de 3 despensas**
            if (!await _subscriptionService.UsuarioPodeCriarMaisDespensasAsync(int.Parse(userId)))
            {
                return new ObjectResult(new {
                    error = "Limite de despensas atingido",
                    message = "Você atingiu o limite de 3 despensas do plano gratuito. Faça upgrade para Premium para criar despensas ilimitadas.",
                    upgradeRequired = true,
                    currentPlan = "Free",
                    limit = 3
                }) { StatusCode = 402 }; // Payment Required
            }

            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                // Criar a despensa
                var despensa = new Despensa
                {
                    Nome = request.Nome,
                    DataCriacao = DateTime.UtcNow
                };

                _context.Despensas.Add(despensa);
                await _context.SaveChangesAsync();

                // Adicionar o criador como dono
                var membroDono = new MembroDespensa
                {
                    UsuarioId = int.Parse(userId),
                    DespensaId = despensa.Id,
                    Papel = PapelDespensa.Dono,
                    DataAcesso = DateTime.UtcNow
                };

                _context.MembrosDespensa.Add(membroDono);
                await _context.SaveChangesAsync();

                await transaction.CommitAsync();

                // **NOTIFICAÇÃO EM TEMPO REAL**: Nova despensa criada (para o próprio usuário)
                await _hubContext.Clients.Group($"User-{userId}")
                    .SendAsync("DespensaCriada", new {
                        id = despensa.Id,
                        nome = despensa.Nome,
                        dataCriacao = despensa.DataCriacao,
                        meuPapel = "Dono"
                    });

                return CreatedAtAction(nameof(GetDespensa), new { id = despensa.Id }, new {
                    id = despensa.Id,
                    nome = despensa.Nome,
                    dataCriacao = despensa.DataCriacao,
                    totalItens = 0,
                    meuPapel = "Dono",
                    totalMembros = 1
                });
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }
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

            // Verificar se é dono (apenas dono pode alterar o nome)
            if (!await _permissionService.IsDonoDespensa(int.Parse(userId), id))
            {
                return Forbid();
            }

            var despensa = await _context.Despensas.FindAsync(id);

            if (despensa == null)
            {
                return NotFound();
            }

            despensa.Nome = request.Nome;
            await _context.SaveChangesAsync();

            // **NOTIFICAÇÃO EM TEMPO REAL**: Despensa atualizada para todos os membros
            await _hubContext.Clients.Group($"Despensa-{id}")
                .SendAsync("DespensaAtualizada", new {
                    id = despensa.Id,
                    nome = despensa.Nome,
                    dataCriacao = despensa.DataCriacao
                });

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

            // Verificar se é dono (apenas dono pode deletar)
            if (!await _permissionService.IsDonoDespensa(int.Parse(userId), id))
            {
                return Forbid();
            }

            var despensa = await _context.Despensas
                .Include(d => d.EstoqueItens)
                .Include(d => d.Membros)
                .FirstOrDefaultAsync(d => d.Id == id);

            if (despensa == null)
            {
                return NotFound();
            }

            // Verificar se a despensa tem itens
            if (despensa.EstoqueItens.Any())
            {
                return BadRequest("Não é possível deletar uma despensa que contém itens. Remova todos os itens primeiro.");
            }

            // Buscar IDs dos membros antes de deletar
            var membrosIds = despensa.Membros.Select(m => m.UsuarioId.ToString()).ToList();

            _context.Despensas.Remove(despensa);
            await _context.SaveChangesAsync();

            // **NOTIFICAÇÃO EM TEMPO REAL**: Despensa deletada para todos os membros
            foreach (var membroId in membrosIds)
            {
                await _hubContext.Clients.Group($"User-{membroId}")
                    .SendAsync("DespensaDeletada", new { 
                        despensaId = id,
                        despensaNome = despensa.Nome
                    });
            }

            return Ok(new { message = "Despensa deletada com sucesso!" });
        }

        // POST: api/despensas/{id}/convidar
        [HttpPost("{id}/convidar")]
        public async Task<IActionResult> ConvidarMembro(int id, [FromBody] ConvidarMembroDto request)
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userId == null)
            {
                return Unauthorized();
            }

            // **VERIFICAÇÃO DE PLANO: Apenas usuários Premium podem enviar convites**
            if (!await _subscriptionService.UsuarioPodeEnviarConvitesAsync(int.Parse(userId)))
            {
                return new ObjectResult(new {
                    error = "Funcionalidade Premium necessária",
                    message = "A partilha familiar é uma funcionalidade Premium. Faça upgrade para convidar membros para as suas despensas.",
                    upgradeRequired = true,
                    currentPlan = "Free",
                    feature = "Partilha Familiar"
                }) { StatusCode = 402 }; // Payment Required
            }

            // Verificar se pode convidar (apenas dono)
            if (!await _permissionService.PodeConvidarParaDespensa(int.Parse(userId), id))
            {
                return Forbid();
            }

            // Verificar se o destinatário existe
            var destinatario = await _context.Usuarios
                .FirstOrDefaultAsync(u => u.Email == request.EmailDestinatario);

            if (destinatario == null)
            {
                return NotFound("Usuário com este email não encontrado.");
            }

            // Verificar se o usuário já é membro
            var jaMembro = await _context.MembrosDespensa
                .AnyAsync(md => md.UsuarioId == destinatario.Id && md.DespensaId == id);

            if (jaMembro)
            {
                return BadRequest("Este usuário já é membro desta despensa.");
            }

            // Verificar se já existe convite pendente
            var convitePendente = await _context.ConvitesDespensa
                .AnyAsync(c => c.DespensaId == id && 
                              c.DestinatarioId == destinatario.Id && 
                              c.Estado == EstadoConvite.Pendente);

            if (convitePendente)
            {
                return BadRequest("Já existe um convite pendente para este usuário.");
            }

            // Buscar informações da despensa para o convite
            var despensa = await _context.Despensas.FindAsync(id);
            var remetente = await _context.Usuarios.FindAsync(int.Parse(userId));

            // Criar convite
            var convite = new ConviteDespensa
            {
                DespensaId = id,
                RemetenteId = int.Parse(userId),
                DestinatarioId = destinatario.Id,
                Mensagem = request.Mensagem,
                DataEnvio = DateTime.UtcNow
            };

            _context.ConvitesDespensa.Add(convite);
            await _context.SaveChangesAsync();

            // **NOTIFICAÇÃO EM TEMPO REAL**: Novo convite recebido
            await _hubContext.Clients.Group($"User-{destinatario.Id}")
                .SendAsync("NovoConviteRecebido", new {
                    conviteId = convite.Id,
                    despensa = new {
                        id = despensa?.Id,
                        nome = despensa?.Nome
                    },
                    remetente = new {
                        id = remetente?.Id,
                        nome = remetente?.Nome,
                        email = remetente?.Email
                    },
                    mensagem = convite.Mensagem,
                    dataEnvio = convite.DataEnvio
                });

            return Ok(new { 
                message = "Convite enviado com sucesso!",
                conviteId = convite.Id,
                destinatario = new {
                    nome = destinatario.Nome,
                    email = destinatario.Email
                }
            });
        }

        // DELETE: api/despensas/{id}/membros/{membroId}
        [HttpDelete("{id}/membros/{membroId}")]
        public async Task<IActionResult> RemoverMembro(int id, int membroId)
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userId == null)
            {
                return Unauthorized();
            }

            // Verificar se pode remover
            if (!await _permissionService.PodeRemoverMembroDespensa(int.Parse(userId), id, membroId))
            {
                return Forbid();
            }

            var membro = await _context.MembrosDespensa
                .Include(md => md.Usuario)
                .Include(md => md.Despensa)
                .FirstOrDefaultAsync(md => md.UsuarioId == membroId && md.DespensaId == id);

            if (membro == null)
            {
                return NotFound("Membro não encontrado nesta despensa.");
            }

            var membroInfo = new {
                usuarioId = membro.UsuarioId,
                nome = membro.Usuario.Nome,
                email = membro.Usuario.Email
            };

            var despensaInfo = new {
                id = membro.Despensa.Id,
                nome = membro.Despensa.Nome
            };

            _context.MembrosDespensa.Remove(membro);
            await _context.SaveChangesAsync();

            // **NOTIFICAÇÃO EM TEMPO REAL**: Membro removido
            // Para o membro removido
            await _hubContext.Clients.Group($"User-{membroId}")
                .SendAsync("RemovidoDaDespensa", new {
                    despensa = despensaInfo,
                    removidoPor = userId
                });

            // Para todos os outros membros restantes
            await _hubContext.Clients.Group($"Despensa-{id}")
                .SendAsync("MembroRemovido", new {
                    membro = membroInfo,
                    despensa = despensaInfo
                });

            return Ok(new { message = "Membro removido da despensa com sucesso!" });
        }
    }

    // DTOs
    public class CriarDespensaDto
    {
        public string Nome { get; set; } = string.Empty;
    }

    public class ConvidarMembroDto
    {
        public string EmailDestinatario { get; set; } = string.Empty;
        public string? Mensagem { get; set; }
    }
} 