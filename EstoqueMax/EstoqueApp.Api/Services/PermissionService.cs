using Microsoft.EntityFrameworkCore;
using EstoqueApp.Api.Data;
using EstoqueApp.Api.Models;

namespace EstoqueApp.Api.Services
{
    public class PermissionService : IPermissionService
    {
        private readonly EstoqueContext _context;

        public PermissionService(EstoqueContext context)
        {
            _context = context;
        }

        public async Task<bool> PodeAcederDespensa(int usuarioId, int despensaId)
        {
            // Verifica se o usuário é membro (dono ou membro convidado) da despensa
            return await _context.MembrosDespensa
                .AnyAsync(md => md.UsuarioId == usuarioId && md.DespensaId == despensaId);
        }

        public async Task<bool> IsDonoDespensa(int usuarioId, int despensaId)
        {
            // Verifica se o usuário é especificamente o dono da despensa
            return await _context.MembrosDespensa
                .AnyAsync(md => md.UsuarioId == usuarioId && 
                               md.DespensaId == despensaId && 
                               md.Papel == PapelDespensa.Dono);
        }

        public async Task<int[]> GetDespensasDoUsuario(int usuarioId)
        {
            // Retorna todas as despensas que o usuário tem acesso
            return await _context.MembrosDespensa
                .Where(md => md.UsuarioId == usuarioId)
                .Select(md => md.DespensaId)
                .ToArrayAsync();
        }

        public async Task<bool> PodeConvidarParaDespensa(int usuarioId, int despensaId)
        {
            // Apenas o dono pode convidar novos membros
            return await IsDonoDespensa(usuarioId, despensaId);
        }

        public async Task<bool> PodeRemoverMembroDespensa(int usuarioId, int despensaId, int membroId)
        {
            // Apenas o dono pode remover membros
            var isDono = await IsDonoDespensa(usuarioId, despensaId);
            
            // Não pode remover a si mesmo se for o dono
            if (isDono && membroId == usuarioId)
            {
                return false;
            }

            return isDono;
        }
    }
} 