using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MotosikletTuruProjesi.Data;
using MotosikletTuruProjesi.Models;

namespace MotosikletTuruProjesi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CommentsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public CommentsController(ApplicationDbContext context)
        {
            _context = context;
        }

        // Tura ait yorumları getir
        [HttpGet("{tourId}")]
        public async Task<ActionResult<IEnumerable<Comment>>> GetComments(int tourId)
        {
            return await _context.Comments
                                 .Where(c => c.TourId == tourId)
                                 .OrderByDescending(c => c.CreatedAt)
                                 .ToListAsync();
        }

        // Yorum yap
        [HttpPost]
        public async Task<ActionResult<Comment>> PostComment(Comment comment)
        {
            _context.Comments.Add(comment);
            await _context.SaveChangesAsync();
            return Ok(comment);
        }
    }
}