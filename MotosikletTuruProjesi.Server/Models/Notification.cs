namespace MotosikletTuruProjesi.Models
{
    public class Notification
    {
        public int Id { get; set; }
        public string Username { get; set; }
        public string Message { get; set; } // "Ahmet senin turuna yorum yaptı"
        public bool IsRead { get; set; } = false;
        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}