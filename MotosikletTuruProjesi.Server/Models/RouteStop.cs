namespace MotosikletTuruProjesi.Models
{
    public class RouteStop
    {
        public int Id { get; set; }
        public int TourId { get; set; }
        public string StopName { get; set; } // "Bolu Dağı Mangal Evi"
        public string Description { get; set; } // "Yemek Molası"
        public int OrderIndex { get; set; } // 1. durak, 2. durak...
        public string Time { get; set; } // "10:30"
    }
}