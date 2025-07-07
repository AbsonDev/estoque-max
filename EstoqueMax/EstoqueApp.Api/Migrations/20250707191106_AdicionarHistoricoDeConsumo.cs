using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace EstoqueApp.Api.Migrations
{
    /// <inheritdoc />
    public partial class AdicionarHistoricoDeConsumo : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "HistoricosDeConsumo",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    EstoqueItemId = table.Column<int>(type: "integer", nullable: false),
                    QuantidadeConsumida = table.Column<int>(type: "integer", nullable: false),
                    DataDoConsumo = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UsuarioId = table.Column<int>(type: "integer", nullable: false),
                    QuantidadeRestanteAposConsumo = table.Column<int>(type: "integer", nullable: false),
                    DiaSemanaDaConsumo = table.Column<int>(type: "integer", nullable: false),
                    HoraDaConsumo = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_HistoricosDeConsumo", x => x.Id);
                    table.ForeignKey(
                        name: "FK_HistoricosDeConsumo_EstoqueItens_EstoqueItemId",
                        column: x => x.EstoqueItemId,
                        principalTable: "EstoqueItens",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_HistoricosDeConsumo_Usuarios_UsuarioId",
                        column: x => x.UsuarioId,
                        principalTable: "Usuarios",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_HistoricoConsumo_Data",
                table: "HistoricosDeConsumo",
                column: "DataDoConsumo");

            migrationBuilder.CreateIndex(
                name: "IX_HistoricoConsumo_EstoqueItem_Data",
                table: "HistoricosDeConsumo",
                columns: new[] { "EstoqueItemId", "DataDoConsumo" });

            migrationBuilder.CreateIndex(
                name: "IX_HistoricosDeConsumo_UsuarioId",
                table: "HistoricosDeConsumo",
                column: "UsuarioId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "HistoricosDeConsumo");
        }
    }
}
