using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Portal.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddKanbanBoardsTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_BoardLabels_Projects_ProjectId",
                table: "BoardLabels");

            migrationBuilder.DropForeignKey(
                name: "FK_KanbanCards_Projects_ProjectId",
                table: "KanbanCards");

            migrationBuilder.DropIndex(
                name: "IX_KanbanCards_ProjectId",
                table: "KanbanCards");

            migrationBuilder.DropIndex(
                name: "IX_BoardLabels_ProjectId",
                table: "BoardLabels");

            migrationBuilder.DropColumn(
                name: "ProjectId",
                table: "KanbanCards");

            migrationBuilder.DropColumn(
                name: "ProjectId",
                table: "BoardLabels");

            migrationBuilder.AddColumn<Guid>(
                name: "BoardId",
                table: "KanbanCards",
                type: "char(36)",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"),
                collation: "ascii_general_ci");

            migrationBuilder.AddColumn<Guid>(
                name: "BoardId",
                table: "BoardLabels",
                type: "char(36)",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"),
                collation: "ascii_general_ci");

            migrationBuilder.CreateTable(
                name: "KanbanBoards",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "char(36)", nullable: false, collation: "ascii_general_ci"),
                    Title = table.Column<string>(type: "longtext", nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Description = table.Column<string>(type: "longtext", nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    ProjectId = table.Column<Guid>(type: "char(36)", nullable: true, collation: "ascii_general_ci"),
                    CreatedAt = table.Column<DateTime>(type: "datetime(6)", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime(6)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_KanbanBoards", x => x.Id);
                    table.ForeignKey(
                        name: "FK_KanbanBoards_Projects_ProjectId",
                        column: x => x.ProjectId,
                        principalTable: "Projects",
                        principalColumn: "Id");
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateIndex(
                name: "IX_KanbanCards_BoardId",
                table: "KanbanCards",
                column: "BoardId");

            migrationBuilder.CreateIndex(
                name: "IX_BoardLabels_BoardId",
                table: "BoardLabels",
                column: "BoardId");

            migrationBuilder.CreateIndex(
                name: "IX_KanbanBoards_ProjectId",
                table: "KanbanBoards",
                column: "ProjectId");

            migrationBuilder.AddForeignKey(
                name: "FK_BoardLabels_KanbanBoards_BoardId",
                table: "BoardLabels",
                column: "BoardId",
                principalTable: "KanbanBoards",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_KanbanCards_KanbanBoards_BoardId",
                table: "KanbanCards",
                column: "BoardId",
                principalTable: "KanbanBoards",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_BoardLabels_KanbanBoards_BoardId",
                table: "BoardLabels");

            migrationBuilder.DropForeignKey(
                name: "FK_KanbanCards_KanbanBoards_BoardId",
                table: "KanbanCards");

            migrationBuilder.DropTable(
                name: "KanbanBoards");

            migrationBuilder.DropIndex(
                name: "IX_KanbanCards_BoardId",
                table: "KanbanCards");

            migrationBuilder.DropIndex(
                name: "IX_BoardLabels_BoardId",
                table: "BoardLabels");

            migrationBuilder.DropColumn(
                name: "BoardId",
                table: "KanbanCards");

            migrationBuilder.DropColumn(
                name: "BoardId",
                table: "BoardLabels");

            migrationBuilder.AddColumn<Guid>(
                name: "ProjectId",
                table: "KanbanCards",
                type: "char(36)",
                nullable: true,
                collation: "ascii_general_ci");

            migrationBuilder.AddColumn<Guid>(
                name: "ProjectId",
                table: "BoardLabels",
                type: "char(36)",
                nullable: true,
                collation: "ascii_general_ci");

            migrationBuilder.CreateIndex(
                name: "IX_KanbanCards_ProjectId",
                table: "KanbanCards",
                column: "ProjectId");

            migrationBuilder.CreateIndex(
                name: "IX_BoardLabels_ProjectId",
                table: "BoardLabels",
                column: "ProjectId");

            migrationBuilder.AddForeignKey(
                name: "FK_BoardLabels_Projects_ProjectId",
                table: "BoardLabels",
                column: "ProjectId",
                principalTable: "Projects",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_KanbanCards_Projects_ProjectId",
                table: "KanbanCards",
                column: "ProjectId",
                principalTable: "Projects",
                principalColumn: "Id");
        }
    }
}
