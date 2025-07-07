namespace EstoqueApp.Api.Models
{
    public class EstoqueItem
    {
        public int Id { get; set; }
        public int UsuarioId { get; set; } // Chave estrangeira
        public Usuario Usuario { get; set; } = null!; // Propriedade de navegação
        public int ProdutoId { get; set; } // Chave estrangeira
        public Produto Produto { get; set; } = null!; // Propriedade de navegação
        public int Quantidade { get; set; }
        public DateTime? DataValidade { get; set; }
    }
} 