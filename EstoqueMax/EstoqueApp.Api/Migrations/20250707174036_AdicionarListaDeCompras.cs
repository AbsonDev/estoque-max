using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace EstoqueApp.Api.Migrations
{
    /// <inheritdoc />
    public partial class AdicionarListaDeCompras : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "QuantidadeMinima",
                table: "EstoqueItens",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateTable(
                name: "ListaDeComprasItens",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    UsuarioId = table.Column<int>(type: "integer", nullable: false),
                    ProdutoId = table.Column<int>(type: "integer", nullable: true),
                    Comprado = table.Column<bool>(type: "boolean", nullable: false),
                    DescricaoManual = table.Column<string>(type: "text", nullable: true),
                    QuantidadeDesejada = table.Column<int>(type: "integer", nullable: false),
                    DataCriacao = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ListaDeComprasItens", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ListaDeComprasItens_Produtos_ProdutoId",
                        column: x => x.ProdutoId,
                        principalTable: "Produtos",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_ListaDeComprasItens_Usuarios_UsuarioId",
                        column: x => x.UsuarioId,
                        principalTable: "Usuarios",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_ListaDeComprasItens_ProdutoId",
                table: "ListaDeComprasItens",
                column: "ProdutoId");

            migrationBuilder.CreateIndex(
                name: "IX_ListaDeComprasItens_UsuarioId",
                table: "ListaDeComprasItens",
                column: "UsuarioId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ListaDeComprasItens");

            migrationBuilder.DropColumn(
                name: "QuantidadeMinima",
                table: "EstoqueItens");
        }
    }
}
