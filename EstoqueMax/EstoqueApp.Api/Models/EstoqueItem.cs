namespace EstoqueApp.Api.Models
{
    public class EstoqueItem
    {
        public int Id { get; set; }
        
        // Relacionamento com Despensa (substituindo a referência direta ao Usuario)
        public int DespensaId { get; set; }
        public Despensa Despensa { get; set; } = null!;
        
        // Relacionamento com Produto
        public int ProdutoId { get; set; }
        public Produto Produto { get; set; } = null!;
        
        public int Quantidade { get; set; }
        public DateTime? DataValidade { get; set; }
    }
} 