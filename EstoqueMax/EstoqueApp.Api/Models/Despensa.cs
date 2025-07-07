namespace EstoqueApp.Api.Models
{
    public class Despensa
    {
        public int Id { get; set; }
        public string Nome { get; set; } = string.Empty;
        public DateTime DataCriacao { get; set; } = DateTime.Now;
        
        // Relacionamento com Usuario
        public int UsuarioId { get; set; }
        public Usuario Usuario { get; set; } = null!;
        
        // Relacionamento com EstoqueItens
        public ICollection<EstoqueItem> EstoqueItens { get; set; } = new List<EstoqueItem>();
    }
} 