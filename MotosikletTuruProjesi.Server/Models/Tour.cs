using System.ComponentModel.DataAnnotations.Schema;

namespace MotosikletTuruProjesi.Models // Adı projenizle aynı olmalı
{
    public class Tour
    {
        // 1. Veritabanındaki Benzersiz Kimlik (Primary Key)
        public int Id { get; set; }

        // 2. Turun Adı (Örn: "Kapadokya Turu")
        public string Baslik { get; set; }

        // 3. Turun Detaylı Açıklaması
        public string Aciklama { get; set; }

        // 4. Turun Rotası (Örn: "Ankara - Tuz Gölü - Ihlara")
        public string Rota { get; set; }

        // 5. Turun Tarihi
        public DateTime Tarih { get; set; }

        public string MotosikletKategorisi { get; set; }

        public string olusturanKisi { get; set; }

        public int ViewCount { get; set; } = 0;

        public string? CustomImageUrl { get; set; }

        [NotMapped]
        public double AverageRating { get; set; } = 0.0;
    }
}