using System.ComponentModel.DataAnnotations;

namespace EstoqueApp.Api.Models
{
    public enum StatusPagamento
    {
        Pago,           // paid
        Falhado,        // failed
        Pendente,       // pending
        Processando,    // processing
        Cancelado,      // canceled
        Estornado       // refunded
    }

    public class PagamentoHistorico
    {
        public int Id { get; set; }
        
        [Required]
        public int SubscricaoStripeId { get; set; }
        
        [Required]
        [MaxLength(255)]
        public string StripeInvoiceId { get; set; } = string.Empty;
        
        [MaxLength(255)]
        public string? StripePaymentIntentId { get; set; }
        
        [Required]
        [Range(0, double.MaxValue)]
        public decimal Valor { get; set; }
        
        [Required]
        [MaxLength(3)]
        public string Moeda { get; set; } = "EUR";
        
        [Required]
        public StatusPagamento Status { get; set; }
        
        [Required]
        public DateTime DataPagamento { get; set; }
        
        public DateTime? DataProcessamento { get; set; }
        
        [MaxLength(500)]
        public string? MotivoFalha { get; set; }
        
        [MaxLength(100)]
        public string? CodigoFalha { get; set; }
        
        public int TentativasRetry { get; set; } = 0;
        
        public DateTime? ProximaTentativa { get; set; }
        
        // Campos para período coberto
        public DateTime InicioPeriodo { get; set; }
        public DateTime FimPeriodo { get; set; }
        
        public DateTime DataCriacao { get; set; } = DateTime.UtcNow;
        
        // Relacionamentos
        public SubscricaoStripe SubscricaoStripe { get; set; } = null!;
    }
} 