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

// GitHub Action trigger test - workflow correction applied
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

// **NOVO: Registrar serviços de IA**
builder.Services.AddScoped<PredictionService>();
// Temporariamente desabilitado até corrigirmos os campos DateTime
// builder.Services.AddHostedService<AITrainingBackgroundService>();

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

// Configure and run the application
var app = builder.Build();

// Fix DateTime fields on startup
try
{
    using var scope = app.Services.CreateScope();
    var context = scope.ServiceProvider.GetRequiredService<EstoqueContext>();
    var connection = context.Database.GetDbConnection();
    await connection.OpenAsync();
    
    var command = connection.CreateCommand();
    command.CommandText = @"
        DELETE FROM ""EstoqueItens"";
        
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
    
    // Criar dados de teste após as migrações
    Console.WriteLine("Criando dados de teste...");
    await SeedTestData(context);
    
    await connection.CloseAsync();
    Console.WriteLine("✅ All database fields corrected successfully!");
}
catch (Exception ex)
{
    Console.WriteLine($"❌ Error fixing fields: {ex.Message}");
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
            DateOnly.FromDateTime(DateTime.UtcNow.AddDays(index)),
            Random.Shared.Next(-20, 55),
            summaries[Random.Shared.Next(summaries.Length)]
        ))
        .ToArray();
    return forecast;
})
.WithName("GetWeatherForecast");

app.Run();

// Método para criar dados de teste
static async Task SeedTestData(EstoqueContext context)
{
    try
    {
        // Verificar se já existem dados de teste
        if (await context.EstoqueItens.AnyAsync())
        {
            Console.WriteLine("Dados de teste já existem. Pulando seed...");
            return;
        }

        // Buscar usuário existente (você deve estar logado com este usuário)
        var usuario = await context.Usuarios.FirstOrDefaultAsync();
        if (usuario == null)
        {
            Console.WriteLine("Nenhum usuário encontrado. Criando usuário de teste...");
            usuario = new Usuario
            {
                Nome = "Abson",
                Email = "abson@test.com",
                SenhaHash = "hash_placeholder", // Você deve ajustar para o hash correto
                Plano = TipoDePlano.Free
            };
            context.Usuarios.Add(usuario);
            await context.SaveChangesAsync();
        }

        // Buscar ou criar despensa
        var despensa = await context.Despensas.FirstOrDefaultAsync();
        if (despensa == null)
        {
            Console.WriteLine("Criando despensa de teste...");
            despensa = new Despensa
            {
                Nome = "Cozinha Principal",
                DataCriacao = DateTime.UtcNow
            };
            context.Despensas.Add(despensa);
            await context.SaveChangesAsync();

            // Adicionar usuário como membro da despensa
            var membro = new MembroDespensa
            {
                UsuarioId = usuario.Id,
                DespensaId = despensa.Id,
                Papel = PapelDespensa.Dono,
                DataAcesso = DateTime.UtcNow
            };
            context.MembrosDespensa.Add(membro);
            await context.SaveChangesAsync();
        }

        // Criar ou buscar produtos
        var produtoLeite = await context.Produtos.FirstOrDefaultAsync(p => p.Nome == "Leite Integral");
        if (produtoLeite == null)
        {
            produtoLeite = new Produto
            {
                Nome = "Leite Integral",
                Marca = "Parmalat",
                CodigoBarras = "7891234567890",
                Categoria = "Laticínios",
                Visibilidade = TipoVisibilidadeProduto.Publico,
                DataCriacao = DateTime.UtcNow
            };
            context.Produtos.Add(produtoLeite);
        }

        var produtoPao = await context.Produtos.FirstOrDefaultAsync(p => p.Nome == "Pão de Forma");
        if (produtoPao == null)
        {
            produtoPao = new Produto
            {
                Nome = "Pão de Forma",
                Marca = "Wickbold",
                CodigoBarras = "7891234567891",
                Categoria = "Padaria",
                Visibilidade = TipoVisibilidadeProduto.Publico,
                DataCriacao = DateTime.UtcNow
            };
            context.Produtos.Add(produtoPao);
        }

        var produtoArroz = await context.Produtos.FirstOrDefaultAsync(p => p.Nome == "Arroz Branco");
        if (produtoArroz == null)
        {
            produtoArroz = new Produto
            {
                Nome = "Arroz Branco",
                Marca = "Tio João",
                CodigoBarras = "7891234567892",
                Categoria = "Grãos",
                Visibilidade = TipoVisibilidadeProduto.Publico,
                DataCriacao = DateTime.UtcNow
            };
            context.Produtos.Add(produtoArroz);
        }

        await context.SaveChangesAsync();

        // Criar itens de estoque
        var estoqueItens = new List<EstoqueItem>
        {
            new EstoqueItem
            {
                DespensaId = despensa.Id,
                ProdutoId = produtoLeite.Id,
                Quantidade = 3,
                QuantidadeMinima = 1,
                DataValidade = DateTime.UtcNow.AddDays(7),
                DataAdicao = DateTime.UtcNow
            },
            new EstoqueItem
            {
                DespensaId = despensa.Id,
                ProdutoId = produtoPao.Id,
                Quantidade = 2,
                QuantidadeMinima = 1,
                DataValidade = DateTime.UtcNow.AddDays(3),
                DataAdicao = DateTime.UtcNow
            },
            new EstoqueItem
            {
                DespensaId = despensa.Id,
                ProdutoId = produtoArroz.Id,
                Quantidade = 5,
                QuantidadeMinima = 2,
                DataAdicao = DateTime.UtcNow
            }
        };

        context.EstoqueItens.AddRange(estoqueItens);
        await context.SaveChangesAsync();

        Console.WriteLine($"✅ Dados de teste criados: {estoqueItens.Count} itens de estoque");
    }
    catch (Exception ex)
    {
        Console.WriteLine($"❌ Erro ao criar dados de teste: {ex.Message}");
    }
}

record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}
