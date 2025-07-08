using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace EstoqueApp.Api.Migrations
{
    /// <inheritdoc />
    public partial class AdicionarPartilhaFamiliar : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // 1. Criar as novas tabelas PRIMEIRO (sem remover nada ainda)
            migrationBuilder.CreateTable(
                name: "ConvitesDespensa",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    DespensaId = table.Column<int>(type: "integer", nullable: false),
                    RemetenteId = table.Column<int>(type: "integer", nullable: false),
                    DestinatarioId = table.Column<int>(type: "integer", nullable: false),
                    Estado = table.Column<int>(type: "integer", nullable: false),
                    DataEnvio = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    DataResposta = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    Mensagem = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ConvitesDespensa", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ConvitesDespensa_Despensas_DespensaId",
                        column: x => x.DespensaId,
                        principalTable: "Despensas",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ConvitesDespensa_Usuarios_DestinatarioId",
                        column: x => x.DestinatarioId,
                        principalTable: "Usuarios",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ConvitesDespensa_Usuarios_RemetenteId",
                        column: x => x.RemetenteId,
                        principalTable: "Usuarios",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "MembrosDespensa",
                columns: table => new
                {
                    UsuarioId = table.Column<int>(type: "integer", nullable: false),
                    DespensaId = table.Column<int>(type: "integer", nullable: false),
                    Papel = table.Column<int>(type: "integer", nullable: false),
                    DataAcesso = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MembrosDespensa", x => new { x.UsuarioId, x.DespensaId });
                    table.ForeignKey(
                        name: "FK_MembrosDespensa_Despensas_DespensaId",
                        column: x => x.DespensaId,
                        principalTable: "Despensas",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_MembrosDespensa_Usuarios_UsuarioId",
                        column: x => x.UsuarioId,
                        principalTable: "Usuarios",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            // 2. Migrar dados existentes: criar entradas na tabela MembrosDespensa para os donos atuais
            migrationBuilder.Sql(@"
                INSERT INTO ""MembrosDespensa"" (""UsuarioId"", ""DespensaId"", ""Papel"", ""DataAcesso"")
                SELECT ""UsuarioId"", ""Id"", 0, datetime('now')
                FROM ""Despensas""
                WHERE ""UsuarioId"" IS NOT NULL;
            ");

            // 3. Criar índices
            migrationBuilder.CreateIndex(
                name: "IX_ConvitesDespensa_DespensaId_DestinatarioId_Estado",
                table: "ConvitesDespensa",
                columns: new[] { "DespensaId", "DestinatarioId", "Estado" },
                unique: true,
                filter: "\"Estado\" = 0");

            migrationBuilder.CreateIndex(
                name: "IX_ConvitesDespensa_DestinatarioId",
                table: "ConvitesDespensa",
                column: "DestinatarioId");

            migrationBuilder.CreateIndex(
                name: "IX_ConvitesDespensa_RemetenteId",
                table: "ConvitesDespensa",
                column: "RemetenteId");

            migrationBuilder.CreateIndex(
                name: "IX_MembrosDespensa_DespensaId",
                table: "MembrosDespensa",
                column: "DespensaId");

            // 4. AGORA SIM, remover a estrutura antiga
            migrationBuilder.DropForeignKey(
                name: "FK_Despensas_Usuarios_UsuarioId",
                table: "Despensas");

            migrationBuilder.DropIndex(
                name: "IX_Despensas_UsuarioId",
                table: "Despensas");

            migrationBuilder.DropColumn(
                name: "UsuarioId",
                table: "Despensas");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ConvitesDespensa");

            migrationBuilder.DropTable(
                name: "MembrosDespensa");

            migrationBuilder.AddColumn<int>(
                name: "UsuarioId",
                table: "Despensas",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateIndex(
                name: "IX_Despensas_UsuarioId",
                table: "Despensas",
                column: "UsuarioId");

            migrationBuilder.AddForeignKey(
                name: "FK_Despensas_Usuarios_UsuarioId",
                table: "Despensas",
                column: "UsuarioId",
                principalTable: "Usuarios",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
