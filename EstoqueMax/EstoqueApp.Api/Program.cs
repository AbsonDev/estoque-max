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
using EstoqueApp.Api.Models;

var builder = WebApplication.CreateBuilder(args);
var configuration = builder.Configuration;

// Configurar o cliente Stripe
Stripe.StripeConfiguration.ApiKey = configuration["Stripe:SecretKey"];

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

// Configurar CORS para produção
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(
        builder =>
        {
            // Em produção, especifique apenas as origens permitidas
            if (configuration["ASPNETCORE_ENVIRONMENT"] == "Development")
            {
                builder.AllowAnyOrigin()
                       .AllowAnyMethod()
                       .AllowAnyHeader();
            }
            else
            {
                // Em produção, especifique apenas as origens permitidas
                builder.WithOrigins(
                        "https://estoque-max.vercel.app",
                        "https://estoque-max-git-main.vercel.app",
                        "https://estoque-max-git-develop.vercel.app",
                        "https://thankful-pebble-0ab32d00f.2.azurestaticapps.net",
                        "https://estoquemaxapi-acfwdye6g0bbdwb5.brazilsouth-01.azurewebsites.net"
                    )
                    .AllowAnyMethod()
                    .AllowAnyHeader()
                    .AllowCredentials();
            }
        });
});

// Configuração do Entity Framework Core - PostgreSQL para desenvolvimento e produção
builder.Services.AddDbContext<EstoqueContext>(options =>
{
    // Usar PostgreSQL tanto para desenvolvimento quanto para produção
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection"));
});

// Adicionar cache em memória
builder.Services.AddMemoryCache();

// Registrar serviços personalizados
builder.Services.AddScoped<IPermissionService, PermissionService>();
builder.Services.AddScoped<ISubscriptionService, SubscriptionService>();

// Registrar serviços de IA
builder.Services.AddScoped<PredictionService>();
// Temporariamente desabilitado até corrigirmos os campos DateTime
// builder.Services.AddHostedService<AITrainingBackgroundService>();

// Registrar serviços de Analytics
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

// Configure and run the application
var app = builder.Build();

// Fix DateTime fields on startup (apenas em desenvolvimento)
if (app.Environment.IsDevelopment())
{
    try
    {
        using var scope = app.Services.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<EstoqueContext>();
        var connection = context.Database.GetDbConnection();
        await connection.OpenAsync();
        
        var command = connection.CreateCommand();
        command.CommandText = @"
            DO $$
            BEGIN
                IF (SELECT data_type FROM information_schema.columns 
                    WHERE table_name = 'EstoqueItens' AND column_name = 'DataAdicao') = 'text' THEN
                    ALTER TABLE ""EstoqueItens"" DROP COLUMN ""DataAdicao"";
                    ALTER TABLE ""EstoqueItens"" ADD COLUMN ""DataAdicao"" timestamp with time zone NOT NULL DEFAULT NOW();
                END IF;
                
                IF (SELECT data_type FROM information_schema.columns 
                    WHERE table_name = 'EstoqueItens' AND column_name = 'DataValidade') = 'text' THEN
                    ALTER TABLE ""EstoqueItens"" DROP COLUMN ""DataValidade"";
                    ALTER TABLE ""EstoqueItens"" ADD COLUMN ""DataValidade"" timestamp with time zone NULL;
                END IF;
                
                -- Fix Comprado field in ListaDeComprasItens
                IF (SELECT data_type FROM information_schema.columns 
                    WHERE table_name = 'ListaDeComprasItens' AND column_name = 'Comprado') != 'boolean' THEN
                    
                    ALTER TABLE ""ListaDeComprasItens"" 
                    ALTER COLUMN ""Comprado"" TYPE boolean 
                    USING CASE 
                        WHEN ""Comprado""::text = '1' THEN true
                        WHEN ""Comprado""::text = '0' THEN false
                        ELSE false
                    END;
                    
                    ALTER TABLE ""ListaDeComprasItens"" 
                    ALTER COLUMN ""Comprado"" SET DEFAULT false;
                END IF;
                
                -- Add DataCompra column if it doesn't exist
                IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                    WHERE table_name = 'ListaDeComprasItens' AND column_name = 'DataCompra') THEN
                    ALTER TABLE ""ListaDeComprasItens"" 
                    ADD COLUMN ""DataCompra"" timestamp with time zone NULL;
                END IF;
                
                -- Add PrecoEstimado column if it doesn't exist
                IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                    WHERE table_name = 'ListaDeComprasItens' AND column_name = 'PrecoEstimado') THEN
                    ALTER TABLE ""ListaDeComprasItens"" 
                    ADD COLUMN ""PrecoEstimado"" decimal(10,2) NULL;
                END IF;
                
                -- Add Loja column if it doesn't exist
                IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                    WHERE table_name = 'ListaDeComprasItens' AND column_name = 'Loja') THEN
                    ALTER TABLE ""ListaDeComprasItens"" 
                    ADD COLUMN ""Loja"" text NULL;
                END IF;
                
                -- Add Notas column if it doesn't exist
                IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                    WHERE table_name = 'ListaDeComprasItens' AND column_name = 'Notas') THEN
                    ALTER TABLE ""ListaDeComprasItens"" 
                    ADD COLUMN ""Notas"" text NULL;
                END IF;
            END $$;
        ";
        await command.ExecuteNonQueryAsync();
        
        await connection.CloseAsync();
        Console.WriteLine("✅ Database fields corrected successfully!");
    }
    catch (Exception ex)
    {
        Console.WriteLine($"❌ Error fixing database fields: {ex.Message}");
    }
}

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

// Usar CORS - deve vir antes de UseHttpsRedirection
app.UseCors();

app.UseHttpsRedirection();

// A ORDEM É IMPORTANTE AQUI
app.UseAuthentication(); // 1. Primeiro você autentica
app.UseAuthorization();  // 2. Depois você autoriza

// Mapear controllers
app.MapControllers();

// Mapear o Hub do SignalR
app.MapHub<EstoqueHub>("/estoqueHub");

app.Run();
