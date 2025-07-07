using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using EstoqueApp.Api.Data;
using EstoqueApp.Api.Models;
using EstoqueApp.Api.Dtos;
using Google.Apis.Auth; // **NOVO: Para validação de tokens Google**

namespace EstoqueApp.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IConfiguration _config;
        private readonly EstoqueContext _context;

        public AuthController(IConfiguration config, EstoqueContext context)
        {
            _config = config;
            _context = context;
        }

        [HttpPost("registrar")]
        public async Task<IActionResult> Registrar(UsuarioRegistroDto request)
        {
            // 1. Verificar se o usuário já existe
            if (await _context.Usuarios.AnyAsync(u => u.Email == request.Email))
            {
                return BadRequest("Usuário já existe.");
            }

            // 2. Criar o hash da senha com BCrypt
            string senhaHash = BCrypt.Net.BCrypt.HashPassword(request.Senha);

            var novoUsuario = new Usuario
            {
                Nome = request.Nome,
                Email = request.Email,
                SenhaHash = senhaHash,
                Provider = "Email" // **ATUALIZADO: Definir o provedor**
            };

            _context.Usuarios.Add(novoUsuario);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Usuário registrado com sucesso!" });
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login(UsuarioLoginDto request)
        {
            // 1. Encontrar o usuário pelo email
            var usuario = await _context.Usuarios.FirstOrDefaultAsync(u => u.Email == request.Email);

            // 2. Verificar se o usuário existe e se a senha está correta com BCrypt
            if (usuario == null || usuario.SenhaHash == null || !BCrypt.Net.BCrypt.Verify(request.Senha, usuario.SenhaHash))
            {
                return Unauthorized("Email ou senha inválidos.");
            }

            // 3. Gerar o Token JWT
            string token = GerarToken(usuario);

            return Ok(new { token = token });
        }

        // **NOVO: Endpoint para Login com Google**
        [HttpPost("google-login")]
        public async Task<IActionResult> GoogleLogin([FromBody] GoogleLoginRequestDto request)
        {
            try
            {
                // 1. Define as configurações de validação. A audiência DEVE ser o seu ClientId.
                var validationSettings = new GoogleJsonWebSignature.ValidationSettings
                {
                    Audience = new[] { _config["Authentication:Google:ClientId"] }
                };

                // 2. Valida o token. Esta chamada comunica com os servidores da Google.
                var payload = await GoogleJsonWebSignature.ValidateAsync(request.IdToken, validationSettings);

                // 3. Procura o utilizador na base de dados pelo email extraído do token.
                var usuario = await _context.Usuarios.FirstOrDefaultAsync(u => u.Email == payload.Email);

                if (usuario == null)
                {
                    // 4. Se não existir, cria um novo utilizador.
                    usuario = new Usuario
                    {
                        Nome = payload.Name,
                        Email = payload.Email,
                        SenhaHash = null, // Não tem senha, a autenticação é via Google
                        Provider = "Google"
                    };
                    _context.Usuarios.Add(usuario);
                    await _context.SaveChangesAsync();
                }
                else if (string.IsNullOrEmpty(usuario.Provider) || usuario.Provider != "Google")
                {
                    // Opcional: Lida com o caso de um utilizador com o mesmo email mas registado com senha.
                    return BadRequest("Já existe uma conta com este email. Por favor, faça login com a sua senha.");
                }

                // 5. Gera o nosso próprio token JWT para o utilizador e envia para o cliente.
                string nossoToken = GerarToken(usuario);

                return Ok(new { 
                    token = nossoToken,
                    message = "Login com Google realizado com sucesso!",
                    user = new {
                        id = usuario.Id,
                        nome = usuario.Nome,
                        email = usuario.Email,
                        provider = usuario.Provider
                    }
                });
            }
            catch (Exception ex)
            {
                // Ocorre se o token for inválido, expirado ou a audiência não corresponder.
                return Unauthorized(new { 
                    error = "Token do Google inválido.",
                    details = ex.Message 
                });
            }
        }

        private string GerarToken(Usuario usuario)
        {
            var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["Jwt:Key"]!));
            var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);

            // Claims são as "informações" que você quer guardar no token
            var claims = new[]
            {
                new Claim(ClaimTypes.NameIdentifier, usuario.Id.ToString()),
                new Claim(ClaimTypes.Email, usuario.Email),
                new Claim(ClaimTypes.Name, usuario.Nome)
                // Você pode adicionar outras claims aqui, como roles (cargos)
            };

            var token = new JwtSecurityToken(
                issuer: _config["Jwt:Issuer"],
                audience: _config["Jwt:Audience"],
                claims: claims,
                expires: DateTime.Now.AddHours(8), // Duração do token
                signingCredentials: credentials);

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
} 