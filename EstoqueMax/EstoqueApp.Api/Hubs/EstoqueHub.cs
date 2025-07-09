using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using System.Security.Claims;
using EstoqueApp.Api.Services;

namespace EstoqueApp.Api.Hubs
{
    [Authorize] // Protege o Hub para que só utilizadores autenticados se possam conectar
    public class EstoqueHub : Hub
    {
        private readonly IPermissionService _permissionService;

        public EstoqueHub(IPermissionService permissionService)
        {
            _permissionService = permissionService;
        }

        // O frontend irá chamar este método após a conexão
        // para cada despensa a que o utilizador tem acesso.
        public async Task JuntarAoGrupoDespensa(string despensaId)
        {
            var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userId != null && int.TryParse(despensaId, out int despensaIdInt))
            {
                // Verificar se o usuário tem permissão para acessar esta despensa
                var podeAcessar = await _permissionService.PodeAcederDespensa(int.Parse(userId), despensaIdInt);
                
                if (podeAcessar)
                {
                    // O nome do grupo será "Despensa-1", "Despensa-2", etc.
                    await Groups.AddToGroupAsync(Context.ConnectionId, $"Despensa-{despensaId}");
                    
                    // Notificar o cliente que foi aceito no grupo
                    await Clients.Caller.SendAsync("JuntouAoGrupo", despensaId);
                }
                else
                {
                    // Notificar erro de permissão
                    await Clients.Caller.SendAsync("ErroPermissao", $"Sem permissão para acessar despensa {despensaId}");
                }
            }
        }

        public async Task SairDoGrupoDespensa(string despensaId)
        {
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"Despensa-{despensaId}");
            await Clients.Caller.SendAsync("SaiuDoGrupo", despensaId);
        }

        // Método chamado automaticamente quando um cliente se conecta
        public override async Task OnConnectedAsync()
        {
            var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            var userName = Context.User?.FindFirst(ClaimTypes.Name)?.Value;
            
            if (userId != null)
            {
                // Adicionar a um grupo baseado no ID do usuário para notificações diretas
                await Groups.AddToGroupAsync(Context.ConnectionId, $"User-{userId}");
                
                // Log da conexão (opcional)
                await Clients.Caller.SendAsync("ConexaoEstabelecida", new { 
                    userId = userId, 
                    userName = userName,
                    connectionId = Context.ConnectionId 
                });
            }
            
            await base.OnConnectedAsync();
        }

        // Método chamado automaticamente quando um cliente se desconecta
        public override async Task OnDisconnectedAsync(Exception? exception)
        {
            var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userId != null)
            {
                await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"User-{userId}");
            }
            
            await base.OnDisconnectedAsync(exception);
        }

        // Método para o frontend testar a conexão
        public async Task Ping()
        {
            await Clients.Caller.SendAsync("Pong", DateTime.UtcNow);
        }
    }
} 