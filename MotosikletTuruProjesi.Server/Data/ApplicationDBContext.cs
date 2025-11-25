using Microsoft.AspNetCore.Identity.EntityFrameworkCore; // <-- Identity için bu satır GEREKLİ
using Microsoft.EntityFrameworkCore;
using MotosikletTuruProjesi.Models;

namespace MotosikletTuruProjesi.Data
{
    public class ApplicationDbContext : IdentityDbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        // Tour tablomuz
        public DbSet<Tour> Tours { get; set; }

    }
}