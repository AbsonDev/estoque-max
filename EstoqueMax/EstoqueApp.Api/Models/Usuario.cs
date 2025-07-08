namespace EstoqueApp.Api.Models
{
    public enum TipoDePlano
    {
        Free,
        Premium
    }

    public class Usuario
    {
        public int Id { get; set; }
        public string Nome { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string? SenhaHash { get; set; } = string.Empty;
        
        // **NOVO: Para identificar o tipo de autenticação**
        public string? Provider { get; set; } = "Email"; // "Google", "Email", etc.
        
        // **NOVO: Campos de assinatura para modelo Freemium**
        public TipoDePlano Plano { get; set; } = TipoDePlano.Free;
        public DateTime? DataExpiracaoAssinatura { get; set; }
        
        // Relacionamento com Lista de Compras
        public ICollection<ListaDeComprasItem> ListaDeCompras { get; set; } = new List<ListaDeComprasItem>();
        
        // NOVO: Relacionamento com Despensas via tabela de junção
        public ICollection<MembroDespensa> AcessosDespensa { get; set; } = new List<MembroDespensa>();
        
        // NOVO: Convites enviados
        public ICollection<ConviteDespensa> ConvitesEnviados { get; set; } = new List<ConviteDespensa>();
        
        // NOVO: Convites recebidos
        public ICollection<ConviteDespensa> ConvitesRecebidos { get; set; } = new List<ConviteDespensa>();
        
        // NOVO: Relacionamento com assinaturas Stripe
        public ICollection<SubscricaoStripe> Assinaturas { get; set; } = new List<SubscricaoStripe>();
    }
} 