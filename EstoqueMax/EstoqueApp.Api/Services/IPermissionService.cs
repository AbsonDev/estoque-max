namespace EstoqueApp.Api.Services
{
    public interface IPermissionService
    {
        Task<bool> PodeAcederDespensa(int usuarioId, int despensaId);
        Task<bool> IsDonoDespensa(int usuarioId, int despensaId);
        Task<int[]> GetDespensasDoUsuario(int usuarioId);
        Task<bool> PodeConvidarParaDespensa(int usuarioId, int despensaId);
        Task<bool> PodeRemoverMembroDespensa(int usuarioId, int despensaId, int membroId);
    }
} 