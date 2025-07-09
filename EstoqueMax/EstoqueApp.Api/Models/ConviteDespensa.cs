using System.ComponentModel.DataAnnotations;

namespace EstoqueApp.Api.Models
{
    public enum EstadoConvite
    {
        Pendente,
        Aceito,
        Rejeitado
    }

    public class ConviteDespensa
    {
        public int Id { get; set; }
        
        public int DespensaId { get; set; }
        public Despensa Despensa { get; set; } = null!;
        
        public int RemetenteId { get; set; }
        public Usuario Remetente { get; set; } = null!;
        
        public int DestinatarioId { get; set; }
        public Usuario Destinatario { get; set; } = null!;
        
        public string? Mensagem { get; set; }
        
        public DateTime DataEnvio { get; set; } = DateTime.UtcNow;
        public DateTime? DataResposta { get; set; }
        
        [Required]
        public EstadoConvite Estado { get; set; } = EstadoConvite.Pendente;
    }
} 