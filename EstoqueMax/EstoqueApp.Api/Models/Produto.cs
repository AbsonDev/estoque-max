using System.ComponentModel.DataAnnotations;

namespace EstoqueApp.Api.Models
{
    public class Produto
    {
        public int Id { get; set; }
        
        [Required]
        [StringLength(200)]
        public string Nome { get; set; } = string.Empty;
        
        [StringLength(100)]
        public string? Marca { get; set; }
        
        [StringLength(50)]
        public string? CodigoBarras { get; set; }
        
        // **NOVO CAMPO: Para análises do dashboard**
        [StringLength(50)]
        public string? Categoria { get; set; } // Ex: "Laticínios", "Limpeza", "Higiene", "Cereais"
    }
} 