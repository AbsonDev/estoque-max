using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace EstoqueApp.Api.Migrations
{
    /// <inheritdoc />
    public partial class FixDataCriacaoDefault : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Corrigir o valor padrão da DataCriacao para usar CURRENT_TIMESTAMP
            migrationBuilder.Sql(@"
                ALTER TABLE ""Produtos"" 
                ALTER COLUMN ""DataCriacao"" SET DEFAULT CURRENT_TIMESTAMP;
            ");

            // Atualizar registros existentes com valor inválido
            migrationBuilder.Sql(@"
                UPDATE ""Produtos"" 
                SET ""DataCriacao"" = CURRENT_TIMESTAMP 
                WHERE ""DataCriacao"" = TIMESTAMPTZ '-infinity';
            ");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Reverter para o valor padrão anterior
            migrationBuilder.Sql(@"
                ALTER TABLE ""Produtos"" 
                ALTER COLUMN ""DataCriacao"" SET DEFAULT TIMESTAMPTZ '-infinity';
            ");
        }
    }
}
