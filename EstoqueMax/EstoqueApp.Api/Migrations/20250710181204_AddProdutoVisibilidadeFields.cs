using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace EstoqueApp.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddProdutoVisibilidadeFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "DataCriacao",
                table: "Produtos",
                type: "timestamp with time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<int>(
                name: "UsuarioCriadorId",
                table: "Produtos",
                type: "integer",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "Visibilidade",
                table: "Produtos",
                type: "integer",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DataCriacao",
                table: "Produtos");

            migrationBuilder.DropColumn(
                name: "UsuarioCriadorId",
                table: "Produtos");

            migrationBuilder.DropColumn(
                name: "Visibilidade",
                table: "Produtos");
        }
    }
}
