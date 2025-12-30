using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MotosikletTuruProjesi.Data;
using MotosikletTuruProjesi.Models;

namespace MotosikletTuruProjesi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ParticipationsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public ParticipationsController(ApplicationDbContext context)
        {
            _context = context;
        }

        // 1. Tura Katıl (Kayıt Ekle)
        [HttpPost]
        public async Task<IActionResult> JoinTour([FromBody] Participation participation)
        {
            // Aynı kişi aynı tura 2 kere katılmasın kontrolü
            var exists = await _context.Participations.AnyAsync(p => p.TourId == participation.TourId && p.Username == participation.Username);
            if (exists) return BadRequest("Zaten bu tura katıldınız.");

            _context.Participations.Add(participation);
            await _context.SaveChangesAsync();
            return Ok(new { message = "Kayıt başarılı!" });
        }

        [HttpGet("{username}")]
        public async Task<ActionResult<IEnumerable<Tour>>> GetMyParticipations(string username)
        {
            var joinedTours = await _context.Participations
                                    .Where(p => p.Username == username)
                                    .Join(_context.Tours,
                                          participation => participation.TourId,
                                          tour => tour.Id,
                                          (participation, tour) => tour)
                                    .ToListAsync();

            
            foreach (var tour in joinedTours)
            {
                var ratings = await _context.TourRatings.Where(r => r.TourId == tour.Id).ToListAsync();
                if (ratings.Any()) tour.AverageRating = ratings.Average(r => r.Score);
            }

            return joinedTours;
        }

        [HttpDelete("leave")]
        public async Task<IActionResult> LeaveTour([FromQuery] int tourId, [FromQuery] string username)
        {
            var participation = await _context.Participations
                .FirstOrDefaultAsync(p => p.TourId == tourId && p.Username == username);

            if (participation == null)
            {
                return NotFound(new { message = "Bu tura zaten katılmamışsınız." });
            }

            _context.Participations.Remove(participation);
            await _context.SaveChangesAsync();
            return Ok(new { message = "Turdan ayrıldınız." });
        }

        [HttpGet("check")]
        public async Task<IActionResult> CheckStatus([FromQuery] int tourId, [FromQuery] string username)
        {
            var exists = await _context.Participations.AnyAsync(p => p.TourId == tourId && p.Username == username);
            return Ok(new { isJoined = exists });
        }
    }
}