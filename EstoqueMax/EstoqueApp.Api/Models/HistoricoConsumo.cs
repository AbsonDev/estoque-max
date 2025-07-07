using System.ComponentModel.DataAnnotations;

namespace EstoqueApp.Api.Models
{
    public class HistoricoConsumo
    {
        public int Id { get; set; }
        
        [Required]
        public int EstoqueItemId { get; set; }
        public EstoqueItem EstoqueItem { get; set; } = null!;
        
        [Required]
        public int QuantidadeConsumida { get; set; }
        
        [Required]
        public DateTime DataDoConsumo { get; set; } = DateTime.UtcNow;
        
        [Required]
        public int UsuarioId { get; set; }
        public Usuario Usuario { get; set; } = null!;
        
        // Campos adicionais para contexto da IA
        public int QuantidadeRestanteAposConsumo { get; set; } // Quantidade que sobrou no estoque
        public DayOfWeek DiaSemanaDaConsumo { get; set; } // Para detectar padrões semanais
        public int HoraDaConsumo { get; set; } // Para detectar padrões diários
    }
} 