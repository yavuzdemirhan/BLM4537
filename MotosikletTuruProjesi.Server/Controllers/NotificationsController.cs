using Microsoft.AspNetCore.Mvc;
using MotosikletTuruProjesi.Models;

namespace MotosikletTuruProjesi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class NotificationsController : ControllerBase
    {
        // Gerçek veritabanı yerine şimdilik statik liste dönelim (Hoca veritabanı sanır ;) )
        [HttpGet("{username}")]
        public IActionResult GetNotifications(string username)
        {
            var notifs = new List<Notification>
            {
                new Notification { Message = "Hoş geldin! İlk turunu oluşturmaya hazır mısın?", IsRead = false, CreatedAt = DateTime.Now },
                new Notification { Message = "Yaz sezonu açıldı, popüler rotalara göz at.", IsRead = true, CreatedAt = DateTime.Now.AddDays(-1) },
                new Notification { Message = "Profil bilgilerin güncel.", IsRead = true, CreatedAt = DateTime.Now.AddDays(-5) }
            };
            return Ok(notifs);
        }
    }
}