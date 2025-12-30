namespace MotosikletTuruProjesi.Models
{
    public class TourRating
    {
        public int Id { get; set; }
        public int TourId { get; set; }
        public string Username { get; set; }
        public int Score { get; set; } // 1 ile 5 arası
    }
}