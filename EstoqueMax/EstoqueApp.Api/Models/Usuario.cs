namespace EstoqueApp.Api.Models
{
    public class Usuario
    {
        public int Id { get; set; }
        public string Nome { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string SenhaHash { get; set; } = string.Empty;
        
        // Relacionamento com Despensas
        public ICollection<Despensa> Despensas { get; set; } = new List<Despensa>();
        
        // Relacionamento com Lista de Compras
        public ICollection<ListaDeComprasItem> ListaDeCompras { get; set; } = new List<ListaDeComprasItem>();
    }
} 