using Microsoft.EntityFrameworkCore;
using EstoqueApp.Api.Models;

namespace EstoqueApp.Api.Data
{
    public class EstoqueContext : DbContext
    {
        public EstoqueContext(DbContextOptions<EstoqueContext> options) : base(options)
        {
        }

        public DbSet<Usuario> Usuarios { get; set; }
        public DbSet<Produto> Produtos { get; set; }
        public DbSet<Despensa> Despensas { get; set; }
        public DbSet<EstoqueItem> EstoqueItens { get; set; }
        public DbSet<ListaDeComprasItem> ListaDeComprasItens { get; set; }
        
        // NOVOS DbSets para Partilha Familiar
        public DbSet<MembroDespensa> MembrosDespensa { get; set; }
        public DbSet<ConviteDespensa> ConvitesDespensa { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Configuração da chave primária composta para MembroDespensa
            modelBuilder.Entity<MembroDespensa>()
                .HasKey(md => new { md.UsuarioId, md.DespensaId });

            // Configuração da relação MembroDespensa -> Usuario
            modelBuilder.Entity<MembroDespensa>()
                .HasOne(md => md.Usuario)
                .WithMany(u => u.AcessosDespensa)
                .HasForeignKey(md => md.UsuarioId);

            // Configuração da relação MembroDespensa -> Despensa
            modelBuilder.Entity<MembroDespensa>()
                .HasOne(md => md.Despensa)
                .WithMany(d => d.Membros)
                .HasForeignKey(md => md.DespensaId);

            // Configuração da relação ConviteDespensa -> Despensa
            modelBuilder.Entity<ConviteDespensa>()
                .HasOne(c => c.Despensa)
                .WithMany(d => d.Convites)
                .HasForeignKey(c => c.DespensaId);

            // Configuração da relação ConviteDespensa -> Remetente
            modelBuilder.Entity<ConviteDespensa>()
                .HasOne(c => c.Remetente)
                .WithMany(u => u.ConvitesEnviados)
                .HasForeignKey(c => c.RemetenteId)
                .OnDelete(DeleteBehavior.Restrict); // Evitar cascade delete

            // Configuração da relação ConviteDespensa -> Destinatario
            modelBuilder.Entity<ConviteDespensa>()
                .HasOne(c => c.Destinatario)
                .WithMany(u => u.ConvitesRecebidos)
                .HasForeignKey(c => c.DestinatarioId)
                .OnDelete(DeleteBehavior.Restrict); // Evitar cascade delete

            // Configuração da relação EstoqueItem -> Despensa
            modelBuilder.Entity<EstoqueItem>()
                .HasOne(e => e.Despensa)
                .WithMany(d => d.EstoqueItens)
                .HasForeignKey(e => e.DespensaId);

            // Configuração da relação EstoqueItem -> Produto
            modelBuilder.Entity<EstoqueItem>()
                .HasOne(e => e.Produto)
                .WithMany()
                .HasForeignKey(e => e.ProdutoId);

            // Configuração da relação ListaDeComprasItem -> Usuario
            modelBuilder.Entity<ListaDeComprasItem>()
                .HasOne(l => l.Usuario)
                .WithMany(u => u.ListaDeCompras)
                .HasForeignKey(l => l.UsuarioId);

            // Configuração da relação ListaDeComprasItem -> Produto (opcional)
            modelBuilder.Entity<ListaDeComprasItem>()
                .HasOne(l => l.Produto)
                .WithMany()
                .HasForeignKey(l => l.ProdutoId)
                .OnDelete(DeleteBehavior.SetNull);

            // Configuração de índices únicos
            modelBuilder.Entity<Usuario>()
                .HasIndex(u => u.Email)
                .IsUnique();

            modelBuilder.Entity<Produto>()
                .HasIndex(p => p.CodigoBarras)
                .IsUnique();

            // Índice único para evitar convites duplicados
            modelBuilder.Entity<ConviteDespensa>()
                .HasIndex(c => new { c.DespensaId, c.DestinatarioId, c.Estado })
                .HasFilter("\"Estado\" = 0") // Apenas convites pendentes
                .IsUnique();
        }
    }
} 