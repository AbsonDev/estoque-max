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
        
        // NOVA PROPRIEDADE - Funcionalidade de Lista de Compras Inteligente
        public int QuantidadeMinima { get; set; } = 1; // Padrão de 1
        
        public DateTime? DataValidade { get; set; }
    }
} 