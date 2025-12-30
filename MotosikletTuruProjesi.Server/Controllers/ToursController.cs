using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MotosikletTuruProjesi.Data;
using MotosikletTuruProjesi.Models;

namespace MotosikletTuruProjesi.Controllers
{
    [Route("api/[controller]")]
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
            var tours = await _context.Tours.ToListAsync();
            foreach (var tour in tours)
            {
                var ratings = await _context.TourRatings.Where(r => r.TourId == tour.Id).ToListAsync();
                if (ratings.Any()) tour.AverageRating = ratings.Average(r => r.Score);
            }
            return tours;
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

        // 3. YENİ TUR EKLE (POST: /api/Tours) 
        [HttpPost]
        public async Task<ActionResult<Tour>> PostTour(Tour tour)
        {
            _context.Tours.Add(tour);
            await _context.SaveChangesAsync();

            // ÖNEMLİ: Geriye oluşturulan objeyi ve ID'sini dönüyoruz
            return CreatedAtAction("GetTour", new { id = tour.Id }, tour);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteTour(int id)
        {
            var tour = await _context.Tours.FindAsync(id);
            if (tour == null)
            {
                return NotFound();
            }

            _context.Tours.Remove(tour);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        // --- Benim oluşturduğum turlar ---
        [HttpGet("my-created/{username}")]
        public async Task<ActionResult<IEnumerable<Tour>>> GetMyCreatedTours(string username)
        {
            return await _context.Tours
                                 .Where(t => t.olusturanKisi == username)
                                 .OrderByDescending(t => t.Tarih)
                                 .ToListAsync();
        }
    }

}