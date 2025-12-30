using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MotosikletTuruProjesi.Data;
using MotosikletTuruProjesi.Models;

namespace MotosikletTuruProjesi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class RouteStopsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        public RouteStopsController(ApplicationDbContext context) => _context = context;

        [HttpGet("{tourId}")]
        public async Task<ActionResult<IEnumerable<RouteStop>>> GetStops(int tourId) => await _context.RouteStops.Where(r => r.TourId == tourId).OrderBy(r => r.OrderIndex).ToListAsync();

        [HttpPost]
        public async Task<IActionResult> AddStop(RouteStop stop)
        {
            _context.RouteStops.Add(stop);
            await _context.SaveChangesAsync();
            return Ok(stop);
        }
    }
}