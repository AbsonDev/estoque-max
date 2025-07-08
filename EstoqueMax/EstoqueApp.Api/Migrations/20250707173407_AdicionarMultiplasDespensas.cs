using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace EstoqueApp.Api.Migrations
{
    /// <inheritdoc />
    public partial class AdicionarMultiplasDespensas : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // 1. Criar a tabela Despensas
            migrationBuilder.CreateTable(
                name: "Despensas",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Nome = table.Column<string>(type: "text", nullable: false),
                    DataCriacao = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UsuarioId = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Despensas", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Despensas_Usuarios_UsuarioId",
                        column: x => x.UsuarioId,
                        principalTable: "Usuarios",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Despensas_UsuarioId",
                table: "Despensas",
                column: "UsuarioId");

            // 2. Criar uma despensa padrão para cada usuário que já tem itens no estoque
            migrationBuilder.Sql(@"
                INSERT INTO ""Despensas"" (""Nome"", ""DataCriacao"", ""UsuarioId"")
                SELECT DISTINCT 'Despensa Principal', datetime('now'), ""UsuarioId""
                FROM ""EstoqueItens""
                WHERE ""UsuarioId"" IS NOT NULL;
            ");

            // 3. Adicionar a coluna DespensaId à tabela EstoqueItens (mantendo UsuarioId por enquanto)
            migrationBuilder.AddColumn<int>(
                name: "DespensaId",
                table: "EstoqueItens",
                type: "integer",
                nullable: true);

            // 4. Atualizar os registros existentes para apontar para as despensas padrão
            migrationBuilder.Sql(@"
                UPDATE ""EstoqueItens"" 
                SET ""DespensaId"" = (
                    SELECT ""Id"" 
                    FROM ""Despensas"" 
                    WHERE ""Despensas"".""UsuarioId"" = ""EstoqueItens"".""UsuarioId""
                    AND ""Despensas"".""Nome"" = 'Despensa Principal'
                    LIMIT 1
                )
                WHERE ""DespensaId"" IS NULL;
            ");

            // 5. Tornar a coluna DespensaId obrigatória
            migrationBuilder.AlterColumn<int>(
                name: "DespensaId",
                table: "EstoqueItens",
                type: "integer",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "integer",
                oldNullable: true);

            // 6. Criar o índice para DespensaId
            migrationBuilder.CreateIndex(
                name: "IX_EstoqueItens_DespensaId",
                table: "EstoqueItens",
                column: "DespensaId");

            // 7. Adicionar a foreign key para DespensaId
            migrationBuilder.AddForeignKey(
                name: "FK_EstoqueItens_Despensas_DespensaId",
                table: "EstoqueItens",
                column: "DespensaId",
                principalTable: "Despensas",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            // 8. Remover a foreign key antiga e a coluna UsuarioId
            migrationBuilder.DropForeignKey(
                name: "FK_EstoqueItens_Usuarios_UsuarioId",
                table: "EstoqueItens");

            migrationBuilder.DropColumn(
                name: "UsuarioId",
                table: "EstoqueItens");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_EstoqueItens_Despensas_DespensaId",
                table: "EstoqueItens");

            migrationBuilder.DropIndex(
                name: "IX_EstoqueItens_DespensaId",
                table: "EstoqueItens");

            migrationBuilder.DropColumn(
                name: "DespensaId",
                table: "EstoqueItens");

            migrationBuilder.DropTable(
                name: "Despensas");

            migrationBuilder.AddColumn<int>(
                name: "UsuarioId",
                table: "EstoqueItens",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateIndex(
                name: "IX_EstoqueItens_UsuarioId",
                table: "EstoqueItens",
                column: "UsuarioId");

            migrationBuilder.AddForeignKey(
                name: "FK_EstoqueItens_Usuarios_UsuarioId",
                table: "EstoqueItens",
                column: "UsuarioId",
                principalTable: "Usuarios",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
