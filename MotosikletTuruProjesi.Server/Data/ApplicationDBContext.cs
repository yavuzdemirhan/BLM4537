using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using MotosikletTuruProjesi.Models;

namespace MotosikletTuruProjesi.Data
{
    public class ApplicationDbContext : IdentityDbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options) { }

        public DbSet<Tour> Tours { get; set; }
        public DbSet<Participation> Participations { get; set; }
        public DbSet<Comment> Comments { get; set; }
        public DbSet<Favorite> Favorites { get; set; }
        public DbSet<Notification> Notifications { get; set; }
        public DbSet<Motorcycle> Motorcycles { get; set; }
        public DbSet<RouteStop> RouteStops { get; set; }
        public DbSet<UserFollow> UserFollows { get; set; }
        public DbSet<TourRating> TourRatings { get; set; }
        public DbSet<EmergencyInfo> EmergencyInfos { get; set; }
    }
}