using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MotosikletTuruProjesi.Data;
using MotosikletTuruProjesi.Models;

namespace MotosikletTuruProjesi.Controllers
{
    [Route("api/[controller]")] // Adres: /api/Tours
    [ApiController]
    public class ToursController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public ToursController(ApplicationDbContext context)
        {
            _context = context;
        }

        // 1. TÜM TURLARI GETİR (GET: /api/Tours)
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Tour>>> GetTours()
        {
            return await _context.Tours.ToListAsync();
        }

        // 2. TEK BİR TUR GETİR (GET: /api/Tours/5)
        // Detay sayfaları için bunu kullanacağız
        [HttpGet("{id}")]
        public async Task<ActionResult<Tour>> GetTour(int id)
        {
            var tour = await _context.Tours.FindAsync(id);

            if (tour == null)
            {
                return NotFound("Böyle bir tur bulunamadı.");
            }

            return tour;
        }

        // 3. YENİ TUR EKLE (POST: /api/Tours) -> İŞTE BU LAZIMDI!
        [HttpPost]
        public async Task<ActionResult<Tour>> PostTour(Tour tour)
        {
            // Veriyi veritabanına ekle
            _context.Tours.Add(tour);

            // Kaydet
            await _context.SaveChangesAsync();

            // Geriye '201 Created' kodu ve eklenen veriyi döndür
            return CreatedAtAction(nameof(GetTour), new { id = tour.Id }, tour);
        }
    }
}