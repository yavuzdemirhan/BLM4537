using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity; // Kullanıcı yönetimi için (UserManager, SignInManager)
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens; // JWT Token (Kimlik Kartı) için
using MotosikletTuruProjesi.Models.DTOs; // RegisterDto ve LoginDto'larımızı kullanmak için
using System.IdentityModel.Tokens.Jwt; // JWT Token (Kimlik Kartı) için
using System.Security.Claims; // JWT Token (Kimlik Kartı) için
using System.Text; // Gizli anahtarı kodlamak için

namespace MotosikletTuruProjesi.Controllers
{
    [Route("api/[controller]")] // Adres: /api/Account
    [ApiController]
    public class AccountController : ControllerBase
    {
        // 1. GEREKLİ ARAÇLAR
        private readonly UserManager<IdentityUser> _userManager;
        private readonly SignInManager<IdentityUser> _signInManager;
        private readonly IConfiguration _config;

        // 2. "Constructor" Metodu:
        // .NET'e bu controller başladığında bize bu 3 aracı vermesini söylüyoruz.
        public AccountController(
            UserManager<IdentityUser> userManager,
            SignInManager<IdentityUser> signInManager,
            IConfiguration config)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _config = config; // appsettings.json dosyasını okumak için
        }


        // --- KAYIT OLMA (REGISTER) PENCERESİ ---
        // Adres: POST /api/account/register
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDto registerDto)
        {
            if (!ModelState.IsValid) // DTO'daki kurallara uyulmuş mu? (Required, EmailAddress vb.)
            {
                return BadRequest(ModelState);
            }

            // Yeni bir kullanıcı nesnesi oluştur
            var user = new IdentityUser
            {
                UserName = registerDto.Username,
                Email = registerDto.Email
            };

            // .NET Identity kullanarak kullanıcıyı veritabanına kaydetmeyi dene
            // Şifreyi de burada hash'leyip (şifreleyip) kaydeder
            var result = await _userManager.CreateAsync(user, registerDto.Password);

            if (result.Succeeded)
            {
                // Kayıt başarılıysa
                return Ok(new { message = "Kayıt başarıyla tamamlandı." });
            }

            // Eğer e-posta zaten varsa veya şifre kurallara uymuyorsa (biz gevşettik ama),
            // hataları React'e geri gönder.
            foreach (var error in result.Errors)
            {
                ModelState.AddModelError(string.Empty, error.Description);
            }
            return BadRequest(ModelState);
        }


        // --- GİRİŞ YAPMA (LOGIN) PENCERESİ ---
        // Adres: POST /api/account/login
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDto loginDto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            // Önce böyle bir kullanıcı var mı diye e-postadan bulmayı dene
            var user = await _userManager.FindByEmailAsync(loginDto.Email);

            // Kullanıcı varsa VE şifresi doğruysa
            if (user != null && await _userManager.CheckPasswordAsync(user, loginDto.Password))
            {
                // --- KİMLİK KARTI (TOKEN) OLUŞTURMA BAŞLIYOR ---

                // Helper (yardımcı) metodu çağırarak token'ı oluştur
                var tokenString = GenerateJwtToken(user);

                // React'e bu "dijital kimlik kartını" gönder
                return Ok(new
                {
                    token = tokenString,
                    username = user.UserName, 
                    message = "Giriş başarılı."
                });
            }

            // E-posta veya şifre yanlışsa, React'e "Yetkiniz yok" de.
            // (Güvenlik için hangisinin yanlış olduğunu söylemeyiz)
            return Unauthorized(new { message = "Geçersiz e-posta veya şifre." });
        }


        // --- YARDIMCI METOT (JWT TOKEN OLUŞTURUCU) ---
        private string GenerateJwtToken(IdentityUser user)
        {
            // 1. appsettings.json'daki gizli anahtarı al
            var jwtKey = _config["Jwt:Key"];
            var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey));
            var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);

            // 2. Token'ın içine hangi bilgileri (Claims) koyacağımızı belirle
            // React'in kullanıcının kim olduğunu bilmesi için
            var claims = new[]
            {
                new Claim(JwtRegisteredClaimNames.Sub, user.Email), // Konu: E-posta
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()), // Benzersiz ID
                new Claim(ClaimTypes.NameIdentifier, user.Id) // En önemlisi: Kullanıcının ID'si
            };

            // 3. appsettings.json'daki Issuer ve Audience bilgilerini al
            var issuer = _config["Jwt:Issuer"];
            var audience = _config["Jwt:Audience"];

            // 4. Token'ı oluştur
            var token = new JwtSecurityToken(
                issuer: issuer,
                audience: audience,
                claims: claims,
                expires: DateTime.Now.AddHours(2), // Token 2 saat geçerli olsun
                signingCredentials: credentials);

            // 5. Token'ı metin (string) formatına çevir
            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}