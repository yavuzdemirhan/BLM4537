namespace MotosikletTuruProjesi.Models
{
    public class Motorcycle
    {
        public int Id { get; set; }
        public string OwnerUsername { get; set; } // Kimin motoru?
        public string Brand { get; set; } // Yamaha, Honda...
        public string Model { get; set; } // MT-07, CBR650R...
        public int Year { get; set; }
        public int EngineCc { get; set; }
        public string ImageUrl { get; set; } // Motorun resmi
    }
}