namespace MotosikletTuruProjesi.Models
{
    public class Comment
    {
        public int Id { get; set; }
        public int TourId { get; set; } // Hangi tura yapıldı?
        public string Username { get; set; } // Kim yaptı?
        public string Content { get; set; } // Ne yazdı?
        public DateTime CreatedAt { get; set; } = DateTime.Now; // Ne zaman?
    }
}