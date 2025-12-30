using System.ComponentModel.DataAnnotations;

namespace MotosikletTuruProjesi.Models.DTOs
{
    public class RegisterDto
    {
        // --- EKLENEN KISIM ---
        [Required(ErrorMessage = "Kullanıcı adı zorunludur")]
        public string Username { get; set; }
        // ---------------------

        [Required(ErrorMessage = "E-posta alanı zorunludur")]
        [EmailAddress(ErrorMessage = "Geçerli bir e-posta adresi girin")]
        public string Email { get; set; }

        [Required(ErrorMessage = "Şifre alanı zorunludur")]
        public string Password { get; set; }
    }
}