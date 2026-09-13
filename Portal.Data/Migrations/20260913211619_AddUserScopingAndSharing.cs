using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Portal.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddUserScopingAndSharing : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "OwnerId",
                table: "Projects",
                type: "varchar(255)",
                nullable: true)
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.AddColumn<string>(
                name: "OwnerId",
                table: "Notes",
                type: "varchar(255)",
                nullable: true)
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.AddColumn<Guid>(
                name: "NoteId",
                table: "AspNetUsers",
                type: "char(36)",
                nullable: true,
                collation: "ascii_general_ci");

            migrationBuilder.AddColumn<Guid>(
                name: "ProjectId",
                table: "AspNetUsers",
                type: "char(36)",
                nullable: true,
                collation: "ascii_general_ci");

            migrationBuilder.CreateIndex(
                name: "IX_Projects_OwnerId",
                table: "Projects",
                column: "OwnerId");

            migrationBuilder.CreateIndex(
                name: "IX_Notes_OwnerId",
                table: "Notes",
                column: "OwnerId");

            migrationBuilder.CreateIndex(
                name: "IX_AspNetUsers_NoteId",
                table: "AspNetUsers",
                column: "NoteId");

            migrationBuilder.CreateIndex(
                name: "IX_AspNetUsers_ProjectId",
                table: "AspNetUsers",
                column: "ProjectId");

            migrationBuilder.AddForeignKey(
                name: "FK_AspNetUsers_Notes_NoteId",
                table: "AspNetUsers",
                column: "NoteId",
                principalTable: "Notes",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_AspNetUsers_Projects_ProjectId",
                table: "AspNetUsers",
                column: "ProjectId",
                principalTable: "Projects",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Notes_AspNetUsers_OwnerId",
                table: "Notes",
                column: "OwnerId",
                principalTable: "AspNetUsers",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Projects_AspNetUsers_OwnerId",
                table: "Projects",
                column: "OwnerId",
                principalTable: "AspNetUsers",
                principalColumn: "Id");

            // Backfill: ken bestaande projecten en notities veilig toe aan je huidige admin/hoofdaccount
            migrationBuilder.Sql(@"
                UPDATE Projects 
                SET OwnerId = (SELECT Id FROM AspNetUsers ORDER BY Id ASC LIMIT 1) 
                WHERE OwnerId IS NULL OR OwnerId = '';
            ");

            migrationBuilder.Sql(@"
                UPDATE Notes 
                SET OwnerId = (SELECT Id FROM AspNetUsers ORDER BY Id ASC LIMIT 1) 
                WHERE OwnerId IS NULL OR OwnerId = '';
            ");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_AspNetUsers_Notes_NoteId",
                table: "AspNetUsers");

            migrationBuilder.DropForeignKey(
                name: "FK_AspNetUsers_Projects_ProjectId",
                table: "AspNetUsers");

            migrationBuilder.DropForeignKey(
                name: "FK_Notes_AspNetUsers_OwnerId",
                table: "Notes");

            migrationBuilder.DropForeignKey(
                name: "FK_Projects_AspNetUsers_OwnerId",
                table: "Projects");

            migrationBuilder.DropIndex(
                name: "IX_Projects_OwnerId",
                table: "Projects");

            migrationBuilder.DropIndex(
                name: "IX_Notes_OwnerId",
                table: "Notes");

            migrationBuilder.DropIndex(
                name: "IX_AspNetUsers_NoteId",
                table: "AspNetUsers");

            migrationBuilder.DropIndex(
                name: "IX_AspNetUsers_ProjectId",
                table: "AspNetUsers");

            migrationBuilder.DropColumn(
                name: "OwnerId",
                table: "Projects");

            migrationBuilder.DropColumn(
                name: "OwnerId",
                table: "Notes");

            migrationBuilder.DropColumn(
                name: "NoteId",
                table: "AspNetUsers");

            migrationBuilder.DropColumn(
                name: "ProjectId",
                table: "AspNetUsers");
        }
    }
}