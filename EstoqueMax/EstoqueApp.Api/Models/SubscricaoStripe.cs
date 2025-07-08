using System.ComponentModel.DataAnnotations;

namespace EstoqueApp.Api.Models
{
    public enum StatusAssinatura
    {
        Ativa,              // active
        Cancelada,          // canceled
        Expirada,           // expired
        PagamentoPendente,  // past_due
        EmTeste,            // trialing
        Pausada,            // paused
        Inadimplente,       // unpaid
        Incompleta          // incomplete
    }

    public class SubscricaoStripe
    {
        public int Id { get; set; }
        
        [Required]
        public int UsuarioId { get; set; }
        
        [Required]
        [MaxLength(255)]
        public string StripeSubscriptionId { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(255)]
        public string StripeCustomerId { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(100)]
        public string PlanId { get; set; } = string.Empty;
        
        [Required]
        public StatusAssinatura Status { get; set; }
        
        [Required]
        public DateTime DataInicio { get; set; }
        
        public DateTime? DataCancelamento { get; set; }
        
        [Required]
        public DateTime ProximaCobranca { get; set; }
        
        [Required]
        public DateTime FimPeriodoAtual { get; set; }
        
        [Required]
        [Range(0, double.MaxValue)]
        public decimal Valor { get; set; }
        
        [Required]
        [MaxLength(3)]
        public string Moeda { get; set; } = "EUR";
        
        [MaxLength(50)]
        public string? Intervalo { get; set; } // month, year
        
        public bool CanceladaFimPeriodo { get; set; } = false;
        
        public DateTime DataCriacao { get; set; } = DateTime.UtcNow;
        public DateTime DataAtualizacao { get; set; } = DateTime.UtcNow;
        
        // Relacionamentos
        public Usuario Usuario { get; set; } = null!;
        public ICollection<PagamentoHistorico> Pagamentos { get; set; } = new List<PagamentoHistorico>();
    }
} 