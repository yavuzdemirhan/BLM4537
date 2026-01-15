using Microsoft.AspNetCore.Identity;

namespace MotosikletTuruProjesi.Models
{
    // Standart IdentityUser özelliklerini (Id, Username, Email, PasswordHash vb.) miras alıyoruz.
    // Ekstra olarak kendi 'Role' sütunumuzu ekliyoruz.
    public class ApplicationUser : IdentityUser
    {
        public string Role { get; set; }
    }
}