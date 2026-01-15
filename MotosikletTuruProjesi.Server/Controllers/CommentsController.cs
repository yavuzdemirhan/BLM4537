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

        // --- 1. TURA AİT YORUMLARI GETİR (SADECE ONAYLANMIŞLAR) ---
        [HttpGet("{tourId}")]
        public async Task<ActionResult<IEnumerable<Comment>>> GetComments(int tourId)
        {
            // Sadece IsApproved (Onay) durumu TRUE olanları getiriyoruz
            return await _context.Comments
                                 .Where(c => c.TourId == tourId && c.IsApproved == true)
                                 .OrderByDescending(c => c.CreatedAt)
                                 .ToListAsync();
        }

        // --- 2. YORUM YAP ---
        [HttpPost]
        public async Task<ActionResult<Comment>> PostComment(Comment comment)
        {
            // KURAL 1: Kullanıcı bu tura daha önce yorum atmış mı?
            var exists = await _context.Comments
                                       .AnyAsync(c => c.TourId == comment.TourId && c.Username == comment.Username);

            if (exists)
            {
                return BadRequest("Bu tura sadece 1 yorum yapabilirsiniz.");
            }

            // KURAL 2: Gelen veriyi güvenli hale getiriyoruz
            // Kullanıcı "true" gönderse bile biz burayı "false" yapıyoruz
            comment.IsApproved = false;

            // Tarihi sunucu saatine sabitliyoruz
            comment.CreatedAt = DateTime.Now;

            // Veritabanına ekle
            _context.Comments.Add(comment);
            await _context.SaveChangesAsync();

            // Kullanıcıya bilgi mesajı dön
            return Ok(new { message = "Yorum admin onayına gönderildi.", data = comment });
        }

        // --- 3. (ADMİN) ONAY BEKLEYENLERİ GETİR ---
        [HttpGet("pending")]
        public async Task<ActionResult<IEnumerable<Comment>>> GetPending()
        {
            // Onaylanmamış (False) olanları getir
            return await _context.Comments
                                 .Where(c => c.IsApproved == false)
                                 .OrderByDescending(c => c.CreatedAt)
                                 .ToListAsync();
        }

        // --- 4. (ADMİN) YORUMU ONAYLA ---
        [HttpPost("approve/{id}")]
        public async Task<IActionResult> Approve(int id)
        {
            var comment = await _context.Comments.FindAsync(id);
            if (comment == null) return NotFound();

            comment.IsApproved = true; // Onaylandı yap
            await _context.SaveChangesAsync();

            return Ok(new { message = "Yorum onaylandı." });
        }

        // --- 5. (ADMİN) YORUMU SİL / REDDET ---
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var comment = await _context.Comments.FindAsync(id);
            if (comment == null) return NotFound();

            _context.Comments.Remove(comment);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Yorum silindi." });
        }
    }
}