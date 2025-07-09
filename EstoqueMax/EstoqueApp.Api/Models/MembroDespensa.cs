using System.ComponentModel.DataAnnotations;

namespace EstoqueApp.Api.Models
{
    public enum PapelDespensa
    {
        Dono,
        Membro
    }

    public class MembroDespensa
    {
        public int UsuarioId { get; set; }
        public Usuario Usuario { get; set; } = null!;

        public int DespensaId { get; set; }
        public Despensa Despensa { get; set; } = null!;

        [Required]
        public PapelDespensa Papel { get; set; } // Define se é Dono ou Membro
        
        public DateTime DataAcesso { get; set; } = DateTime.UtcNow; // Quando o usuário ganhou acesso
    }
} 