namespace EstoqueApp.Api.Models
{
    public class Despensa
    {
        public int Id { get; set; }
        public string Nome { get; set; } = string.Empty;
        public DateTime DataCriacao { get; set; } = DateTime.UtcNow;
        
        // Relacionamento com EstoqueItens
        public ICollection<EstoqueItem> EstoqueItens { get; set; } = new List<EstoqueItem>();
        
        // NOVO: Relacionamento com Usuarios via tabela de junção
        public ICollection<MembroDespensa> Membros { get; set; } = new List<MembroDespensa>();
        
        // NOVO: Convites relacionados a esta despensa
        public ICollection<ConviteDespensa> Convites { get; set; } = new List<ConviteDespensa>();
    }
} 