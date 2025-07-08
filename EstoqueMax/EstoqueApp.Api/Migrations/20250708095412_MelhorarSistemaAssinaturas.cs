using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace EstoqueApp.Api.Migrations
{
    /// <inheritdoc />
    public partial class MelhorarSistemaAssinaturas : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "AssinaturasStripe",
                columns: table => new
                {
                    Id = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    UsuarioId = table.Column<int>(type: "INTEGER", nullable: false),
                    StripeSubscriptionId = table.Column<string>(type: "TEXT", maxLength: 255, nullable: false),
                    StripeCustomerId = table.Column<string>(type: "TEXT", maxLength: 255, nullable: false),
                    PlanId = table.Column<string>(type: "TEXT", maxLength: 100, nullable: false),
                    Status = table.Column<int>(type: "INTEGER", nullable: false),
                    DataInicio = table.Column<DateTime>(type: "TEXT", nullable: false),
                    DataCancelamento = table.Column<DateTime>(type: "TEXT", nullable: true),
                    ProximaCobranca = table.Column<DateTime>(type: "TEXT", nullable: false),
                    FimPeriodoAtual = table.Column<DateTime>(type: "TEXT", nullable: false),
                    Valor = table.Column<decimal>(type: "TEXT", nullable: false),
                    Moeda = table.Column<string>(type: "TEXT", maxLength: 3, nullable: false),
                    Intervalo = table.Column<string>(type: "TEXT", maxLength: 50, nullable: true),
                    CanceladaFimPeriodo = table.Column<bool>(type: "INTEGER", nullable: false),
                    DataCriacao = table.Column<DateTime>(type: "TEXT", nullable: false),
                    DataAtualizacao = table.Column<DateTime>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AssinaturasStripe", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AssinaturasStripe_Usuarios_UsuarioId",
                        column: x => x.UsuarioId,
                        principalTable: "Usuarios",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "WebhookEvents",
                columns: table => new
                {
                    Id = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    StripeEventId = table.Column<string>(type: "TEXT", maxLength: 255, nullable: false),
                    EventType = table.Column<string>(type: "TEXT", maxLength: 100, nullable: false),
                    ProcessadoEm = table.Column<DateTime>(type: "TEXT", nullable: false),
                    ProcessadoComSucesso = table.Column<bool>(type: "INTEGER", nullable: false),
                    ErroProcessamento = table.Column<string>(type: "TEXT", maxLength: 1000, nullable: true),
                    PayloadCompleto = table.Column<string>(type: "TEXT", nullable: true),
                    DataCriacao = table.Column<DateTime>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_WebhookEvents", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "PagamentosHistorico",
                columns: table => new
                {
                    Id = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    SubscricaoStripeId = table.Column<int>(type: "INTEGER", nullable: false),
                    StripeInvoiceId = table.Column<string>(type: "TEXT", maxLength: 255, nullable: false),
                    StripePaymentIntentId = table.Column<string>(type: "TEXT", maxLength: 255, nullable: true),
                    Valor = table.Column<decimal>(type: "TEXT", nullable: false),
                    Moeda = table.Column<string>(type: "TEXT", maxLength: 3, nullable: false),
                    Status = table.Column<int>(type: "INTEGER", nullable: false),
                    DataPagamento = table.Column<DateTime>(type: "TEXT", nullable: false),
                    DataProcessamento = table.Column<DateTime>(type: "TEXT", nullable: true),
                    MotivoFalha = table.Column<string>(type: "TEXT", maxLength: 500, nullable: true),
                    CodigoFalha = table.Column<string>(type: "TEXT", maxLength: 100, nullable: true),
                    TentativasRetry = table.Column<int>(type: "INTEGER", nullable: false),
                    ProximaTentativa = table.Column<DateTime>(type: "TEXT", nullable: true),
                    InicioPeriodo = table.Column<DateTime>(type: "TEXT", nullable: false),
                    FimPeriodo = table.Column<DateTime>(type: "TEXT", nullable: false),
                    DataCriacao = table.Column<DateTime>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PagamentosHistorico", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PagamentosHistorico_AssinaturasStripe_SubscricaoStripeId",
                        column: x => x.SubscricaoStripeId,
                        principalTable: "AssinaturasStripe",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_AssinaturasStripe_StripeSubscriptionId",
                table: "AssinaturasStripe",
                column: "StripeSubscriptionId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_SubscricaoStripe_Usuario_Status",
                table: "AssinaturasStripe",
                columns: new[] { "UsuarioId", "Status" });

            migrationBuilder.CreateIndex(
                name: "IX_PagamentoHistorico_Subscricao_Data",
                table: "PagamentosHistorico",
                columns: new[] { "SubscricaoStripeId", "DataPagamento" });

            migrationBuilder.CreateIndex(
                name: "IX_PagamentosHistorico_StripeInvoiceId",
                table: "PagamentosHistorico",
                column: "StripeInvoiceId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_WebhookEvent_Type_Processed",
                table: "WebhookEvents",
                columns: new[] { "EventType", "ProcessadoEm" });

            migrationBuilder.CreateIndex(
                name: "IX_WebhookEvents_StripeEventId",
                table: "WebhookEvents",
                column: "StripeEventId",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "PagamentosHistorico");

            migrationBuilder.DropTable(
                name: "WebhookEvents");

            migrationBuilder.DropTable(
                name: "AssinaturasStripe");
        }
    }
}
