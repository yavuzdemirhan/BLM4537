using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MotosikletTuruProjesi.Server.Migrations
{
    /// <inheritdoc />
    public partial class TourImage : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "CustomImageUrl",
                table: "Tours",
                type: "nvarchar(max)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CustomImageUrl",
                table: "Tours");
        }
    }
}
