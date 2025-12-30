namespace MotosikletTuruProjesi.Models
{
    public class Participation
    {
        public int Id { get; set; }
        public int TourId { get; set; } // Hangi tur?
        public string Username { get; set; } // Kim katıldı?
        public string TourTitle { get; set; } // Turun adı neydi? (Listelerken kolaylık olsun)
        public DateTime JoinDate { get; set; } = DateTime.Now; // Ne zaman tıkladı?
    }
}