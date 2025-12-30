using Microsoft.AspNetCore.Identity;

namespace MotosikletTuruProjesi.Infrastructure
{
    // Bu sınıf, Identity'nin standart İngilizce hatalarını ezer ve Türkçe döndürür.
    public class TurkishIdentityErrorDescriber : IdentityErrorDescriber
    {
        public override IdentityError DuplicateEmail(string email)
        {
            return new IdentityError { Code = nameof(DuplicateEmail), Description = $"'{email}' e-posta adresi zaten kullanımda." };
        }

        public override IdentityError DuplicateUserName(string userName)
        {
            return new IdentityError { Code = nameof(DuplicateUserName), Description = $"'{userName}' kullanıcı adı zaten alınmış." };
        }

        public override IdentityError PasswordTooShort(int length)
        {
            return new IdentityError { Code = nameof(PasswordTooShort), Description = $"Şifreniz en az {length} karakter olmalıdır." };
        }

        public override IdentityError PasswordRequiresNonAlphanumeric()
        {
            return new IdentityError { Code = nameof(PasswordRequiresNonAlphanumeric), Description = "Şifreniz en az bir özel karakter (. , ! ? * vb.) içermelidir." };
        }

        public override IdentityError PasswordRequiresDigit()
        {
            return new IdentityError { Code = nameof(PasswordRequiresDigit), Description = "Şifreniz en az bir rakam (0-9) içermelidir." };
        }

        public override IdentityError PasswordRequiresLower()
        {
            return new IdentityError { Code = nameof(PasswordRequiresLower), Description = "Şifreniz en az bir küçük harf (a-z) içermelidir." };
        }

        public override IdentityError PasswordRequiresUpper()
        {
            return new IdentityError { Code = nameof(PasswordRequiresUpper), Description = "Şifreniz en az bir büyük harf (A-Z) içermelidir." };
        }
    }
}