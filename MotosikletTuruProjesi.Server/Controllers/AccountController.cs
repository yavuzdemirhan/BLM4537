using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity; 
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens; 
using MotosikletTuruProjesi.Models.DTOs; 
using System.IdentityModel.Tokens.Jwt; 
using System.Security.Claims; 
using System.Text; 

namespace MotosikletTuruProjesi.Controllers
{
    [Route("api/[controller]")] 
    [ApiController]
    public class AccountController : ControllerBase
    {
        
        private readonly UserManager<IdentityUser> _userManager;
        private readonly SignInManager<IdentityUser> _signInManager;
        private readonly IConfiguration _config;

        
        public AccountController(
            UserManager<IdentityUser> userManager,
            SignInManager<IdentityUser> signInManager,
            IConfiguration config)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _config = config; 
        }


        // --- KAYIT OLMA (REGISTER) PENCERESİ ---
        
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDto registerDto)
        {
            if (!ModelState.IsValid) 
            {
                return BadRequest(ModelState);
            }

            
            var user = new IdentityUser
            {
                UserName = registerDto.Username,
                Email = registerDto.Email
            };

            
            var result = await _userManager.CreateAsync(user, registerDto.Password);

            if (result.Succeeded)
            {
                
                return Ok(new { message = "Kayıt başarıyla tamamlandı." });
            }


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

                var tokenString = GenerateJwtToken(user);

                return Ok(new
                {
                    token = tokenString,
                    username = user.UserName, 
                    message = "Giriş başarılı."
                });
            }

            return Unauthorized(new { message = "Geçersiz e-posta veya şifre." });
        }


        // --- JWT TOKEN OLUŞTURUCU ---
        private string GenerateJwtToken(IdentityUser user)
        {
          
            var jwtKey = _config["Jwt:Key"];
            var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey));
            var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);

            
            var claims = new[]
            {
                new Claim(JwtRegisteredClaimNames.Sub, user.Email), // Konu: E-posta
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()), // Benzersiz ID
                new Claim(ClaimTypes.NameIdentifier, user.Id) //  Kullanıcının ID'si
            };

            
            var issuer = _config["Jwt:Issuer"];
            var audience = _config["Jwt:Audience"];

           
            var token = new JwtSecurityToken(
                issuer: issuer,
                audience: audience,
                claims: claims,
                expires: DateTime.Now.AddHours(2),
                signingCredentials: credentials);

            
            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}