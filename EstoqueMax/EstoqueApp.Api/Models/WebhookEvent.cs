using System.ComponentModel.DataAnnotations;

namespace EstoqueApp.Api.Models
{
    public class WebhookEvent
    {
        public int Id { get; set; }
        
        [Required]
        [MaxLength(255)]
        public string StripeEventId { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(100)]
        public string EventType { get; set; } = string.Empty;
        
        [Required]
        public DateTime ProcessadoEm { get; set; }
        
        public bool ProcessadoComSucesso { get; set; } = true;
        
        [MaxLength(1000)]
        public string? ErroProcessamento { get; set; }
        
        // Para debug e auditoria
        public string? PayloadCompleto { get; set; }
        
        public DateTime DataCriacao { get; set; } = DateTime.UtcNow;
    }
} 