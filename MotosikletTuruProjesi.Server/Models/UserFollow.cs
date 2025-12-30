namespace MotosikletTuruProjesi.Models
{
    public class UserFollow
    {
        public int Id { get; set; }
        public string FollowerUsername { get; set; } // Takip Eden
        public string FollowingUsername { get; set; } // Takip Edilen
    }
}