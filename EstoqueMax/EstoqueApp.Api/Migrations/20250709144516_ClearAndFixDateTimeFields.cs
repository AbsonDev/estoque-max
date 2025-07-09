using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace EstoqueApp.Api.Migrations
{
    /// <inheritdoc />
    public partial class ClearAndFixDateTimeFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DataAdicaoString",
                table: "EstoqueItens");

            migrationBuilder.DropColumn(
                name: "DataValidadeString",
                table: "EstoqueItens");

            migrationBuilder.AddColumn<DateTime>(
                name: "DataAdicao",
                table: "EstoqueItens",
                type: "timestamp with time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<DateTime>(
                name: "DataValidade",
                table: "EstoqueItens",
                type: "timestamp with time zone",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DataAdicao",
                table: "EstoqueItens");

            migrationBuilder.DropColumn(
                name: "DataValidade",
                table: "EstoqueItens");

            migrationBuilder.AddColumn<string>(
                name: "DataAdicaoString",
                table: "EstoqueItens",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "DataValidadeString",
                table: "EstoqueItens",
                type: "text",
                nullable: true);
        }
    }
}
