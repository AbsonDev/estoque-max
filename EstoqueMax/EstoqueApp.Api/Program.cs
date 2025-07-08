using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using EstoqueApp.Api.Data;
using EstoqueApp.Api.Services;
using EstoqueApp.Api.Hubs;
using EstoqueApp.Api.Services.AI;
using EstoqueApp.Api.Services.Analytics;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);
var configuration = builder.Configuration;

// Add services to the container.
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "EstoqueMax API", Version = "v1" });
    
    // Configuração para JWT Bearer Authentication
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme. Example: \"Authorization: Bearer {token}\"",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });
    
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            new string[] {}
        }
    });
});

// Adicionar controllers
builder.Services.AddControllers();

// **NOVO: Configurar CORS para Flutter Web**
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(
        builder =>
        {
            builder.AllowAnyOrigin()
                   .AllowAnyMethod()
                   .AllowAnyHeader();
        });
});

// Configuração do Entity Framework Core - SQLite para desenvolvimento, PostgreSQL para produção
builder.Services.AddDbContext<EstoqueContext>(options =>
{
    if (builder.Environment.IsDevelopment())
    {
        // Use SQLite para desenvolvimento
        options.UseSqlite(builder.Configuration.GetConnectionString("SQLiteConnection") ?? "Data Source=EstoqueMax.db");
    }
    else
    {
        // Use PostgreSQL para produção
        options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection"));
    }
});

// Registrar serviços personalizados
builder.Services.AddScoped<IPermissionService, PermissionService>();

// **NOVO: Registrar serviços de IA**
builder.Services.AddScoped<PredictionService>();
builder.Services.AddHostedService<AITrainingBackgroundService>();

// **NOVO: Registrar serviços de Analytics**
builder.Services.AddScoped<IAnalyticsService, AnalyticsService>();

// Adicionar SignalR para comunicação em tempo real
builder.Services.AddSignalR();

// Adicionar a configuração de autenticação JWT
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = configuration["Jwt:Issuer"],
            ValidAudience = configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(configuration["Jwt:Key"]!))
        };

        // Configuração especial para SignalR com JWT
        options.Events = new JwtBearerEvents
        {
            OnMessageReceived = context =>
            {
                var accessToken = context.Request.Query["access_token"];
                var path = context.HttpContext.Request.Path;
                
                // Se a requisição for para o hub SignalR e tiver token na query string
                if (!string.IsNullOrEmpty(accessToken) && path.StartsWithSegments("/estoqueHub"))
                {
                    context.Token = accessToken;
                }
                return Task.CompletedTask;
            }
        };
    });

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "EstoqueMax API v1");
        c.RoutePrefix = "swagger";
    });
}

// **NOVO: Usar CORS - deve vir antes de UseHttpsRedirection**
app.UseCors();

app.UseHttpsRedirection();

// !!! A ORDEM É IMPORTANTE AQUI !!!
app.UseAuthentication(); // 1. Primeiro você autentica
app.UseAuthorization();  // 2. Depois você autoriza

// Mapear controllers
app.MapControllers();

// Mapear o Hub do SignalR
app.MapHub<EstoqueHub>("/estoqueHub");

var summaries = new[]
{
    "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
};

app.MapGet("/weatherforecast", () =>
{
    var forecast =  Enumerable.Range(1, 5).Select(index =>
        new WeatherForecast
        (
            DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            Random.Shared.Next(-20, 55),
            summaries[Random.Shared.Next(summaries.Length)]
        ))
        .ToArray();
    return forecast;
})
.WithName("GetWeatherForecast");

app.Run();

record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}
