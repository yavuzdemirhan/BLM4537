using Microsoft.EntityFrameworkCore;
using MotosikletTuruProjesi.Data;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Authentication.JwtBearer; 
using Microsoft.IdentityModel.Tokens; 
using System.Text;
using MotosikletTuruProjesi.Infrastructure;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        builder =>
        {
            builder
                .AllowAnyOrigin()   // Her yerden gelen isteði kabul et
                .AllowAnyMethod()   // GET, POST, PUT, DELETE
                .AllowAnyHeader();  // Tüm headerlar
        });
});


builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// 1. Veritabaný baðlantýsý
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(connectionString));

// 2. Identity (Kullanýcý) sistemi
builder.Services.AddIdentity<IdentityUser, IdentityRole>(options =>
{
    options.Password.RequireDigit = true;
    options.Password.RequiredLength = 8;
    options.Password.RequireNonAlphanumeric = true;
    options.Password.RequireUppercase = true;
    options.Password.RequireLowercase = true;

    options.User.RequireUniqueEmail = true;
})
    .AddEntityFrameworkStores<ApplicationDbContext>()
    .AddErrorDescriber<TurkishIdentityErrorDescriber>(); 


// 3. Projeye "Authentication" (Kimlik Doðrulama) sistemini ekle
builder.Services.AddAuthentication(options =>
{
    // Varsayýlan kimlik doðrulama yöntemi olarak JWT'yi kullan
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options => // JWT (Kimlik Kartý) ayarlarý
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true, // Kartý vereni (Issuer) doðrula
        ValidateAudience = true, // Kartý kullananý (Audience) doðrula
        ValidateLifetime = true, // Kartýn süresinin geçip geçmediðini kontrol et
        ValidateIssuerSigningKey = true, // Kartýn imzasýný (gizli anahtar) doðrula

        // Geçerli deðerleri appsettings.json'dan al
        ValidIssuer = builder.Configuration["Jwt:Issuer"],
        ValidAudience = builder.Configuration["Jwt:Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]))
    };
});


var app = builder.Build();

app.UseDefaultFiles();
app.UseStaticFiles();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

//app.UseHttpsRedirection();

app.UseCors("AllowAll");

app.UseAuthentication(); // Önce kimlik kartý var mý diye bak (Authentication)
app.UseAuthorization();  // Sonra o kartýn yetkisi var mý diye bak (Authorization)


app.MapControllers();

app.MapFallbackToFile("/index.html");

app.Run();