namespace EstoqueApp.Api.Models
{
    public enum EstadoConvite
    {
        Pendente,
        Aceite,
        Recusado
    }

    public class ConviteDespensa
    {
        public int Id { get; set; }
        
        public int DespensaId { get; set; }
        public Despensa Despensa { get; set; } = null!;

        // Quem enviou o convite
        public int RemetenteId { get; set; }
        public Usuario Remetente { get; set; } = null!;

        // Quem recebeu o convite
        public int DestinatarioId { get; set; }
        public Usuario Destinatario { get; set; } = null!;

        public EstadoConvite Estado { get; set; } = EstadoConvite.Pendente;
        public DateTime DataEnvio { get; set; } = DateTime.Now;
        public DateTime? DataResposta { get; set; } // Quando foi aceito/recusado
        
        // Mensagem opcional do convite
        public string? Mensagem { get; set; }
    }
} 