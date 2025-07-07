namespace EstoqueApp.Api.Models
{
    public class ListaDeComprasItem
    {
        public int Id { get; set; }
        
        // Relacionamento com Usuario - cada item pertence a um usuário
        public int UsuarioId { get; set; }
        public Usuario Usuario { get; set; } = null!;

        // Relacionamento com Produto - pode ser null para itens manuais
        public int? ProdutoId { get; set; }
        public Produto? Produto { get; set; }

        // Estado do item na lista
        public bool Comprado { get; set; } = false;
        
        // Campo para itens adicionados manualmente que não estão no estoque
        public string? DescricaoManual { get; set; }
        
        // Quantidade desejada para compra
        public int QuantidadeDesejada { get; set; } = 1;
        
        // Data de criação para ordenação
        public DateTime DataCriacao { get; set; } = DateTime.Now;
    }
} 