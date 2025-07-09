using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace EstoqueApp.Api.Models
{
    public class ListaDeComprasItem
    {
        public int Id { get; set; }
        
        // Relacionamento com Usuario
        public int UsuarioId { get; set; }
        public Usuario Usuario { get; set; } = null!;
        
        // Relacionamento com Produto (nullable para itens manuais)
        public int? ProdutoId { get; set; }
        public Produto? Produto { get; set; }
        
        // Para itens adicionados manualmente (sem produto no catálogo)
        public string? DescricaoManual { get; set; }
        
        public int QuantidadeDesejada { get; set; } = 1;
        
        public bool Comprado { get; set; } = false;
        public DateTime? DataCompra { get; set; }
        
        // Metadados
        public DateTime DataCriacao { get; set; } = DateTime.UtcNow;
        
        // **NOVO CAMPO**: Preço estimado para análises financeiras
        [Column(TypeName = "decimal(10,2)")]
        public decimal? PrecoEstimado { get; set; }
        
        // **NOVO CAMPO**: Loja onde pretende comprar 
        public string? Loja { get; set; }
        
        // **NOVO CAMPO**: Notas do usuário sobre o item
        public string? Notas { get; set; }
    }
} 