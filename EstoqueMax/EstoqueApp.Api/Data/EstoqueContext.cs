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

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Configuração da relação Despensa -> Usuario
            modelBuilder.Entity<Despensa>()
                .HasOne(d => d.Usuario)
                .WithMany(u => u.Despensas)
                .HasForeignKey(d => d.UsuarioId);

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

            // Configuração de índices únicos
            modelBuilder.Entity<Usuario>()
                .HasIndex(u => u.Email)
                .IsUnique();

            modelBuilder.Entity<Produto>()
                .HasIndex(p => p.CodigoBarras)
                .IsUnique();
        }
    }
} 