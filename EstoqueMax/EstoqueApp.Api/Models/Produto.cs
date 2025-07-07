namespace EstoqueApp.Api.Models
{
    public class Produto
    {
        public int Id { get; set; }
        public string CodigoBarras { get; set; } = string.Empty;
        public string Nome { get; set; } = string.Empty;
        public string? Marca { get; set; } // ? indica que pode ser nulo
    }
} 