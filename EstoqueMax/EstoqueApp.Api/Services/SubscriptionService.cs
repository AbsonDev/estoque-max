using EstoqueApp.Api.Data;
using EstoqueApp.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;

namespace EstoqueApp.Api.Services
{
    public interface ISubscriptionService
    {
        Task<bool> UsuarioTemAcessoPremiumAsync(int usuarioId);
        Task<bool> UsuarioPodeCriarMaisDespensasAsync(int usuarioId);
        Task<bool> UsuarioPodeEnviarConvitesAsync(int usuarioId);
        Task<bool> UsuarioTemAcessoAIAsync(int usuarioId);
        Task<bool> UsuarioTemAcessoAnalyticsCompletaAsync(int usuarioId);
        Task<Usuario> ObterUsuarioComPlanoAsync(int usuarioId);
        Task<SubscriptionStatus> ObterStatusAssinaturaAsync(int usuarioId);
        Task<int> ObterNumeroDeDespensasDoUsuarioAsync(int usuarioId);
        
        // NOVOS MÉTODOS - VERSÃO SIMPLIFICADA
        Task<SubscricaoStripe?> ObterAssinaturaAtivaAsync(int usuarioId);
        Task<SubscricaoStripe> CriarAssinaturaAsync(int usuarioId, string stripeSubscriptionId, string stripeCustomerId, string planId);
        Task<SubscricaoStripe> AtualizarStatusAssinaturaAsync(string stripeSubscriptionId, StatusAssinatura novoStatus);
        Task<bool> CancelarAssinaturaAsync(string stripeSubscriptionId, DateTime? dataFinalizacao = null);
        Task<SubscriptionAnalytics> ObterAnalyticsAssinaturasAsync();
        Task InvalidarCacheUsuarioAsync(int usuarioId);
    }

    public class SubscriptionService : ISubscriptionService
    {
        private readonly EstoqueContext _context;
        private readonly IMemoryCache _cache;
        private readonly ILogger<SubscriptionService> _logger;
        private const int CACHE_DURATION_MINUTES = 5;

        public SubscriptionService(EstoqueContext context, IMemoryCache cache, ILogger<SubscriptionService> logger)
        {
            _context = context;
            _cache = cache;
            _logger = logger;
        }

        public async Task<bool> UsuarioTemAcessoPremiumAsync(int usuarioId)
        {
            var status = await ObterStatusAssinaturaCachedAsync(usuarioId);
            return status.IsValid && status.PlanoAtual == TipoDePlano.Premium;
        }

        public async Task<bool> UsuarioPodeCriarMaisDespensasAsync(int usuarioId)
        {
            // Usuários Premium podem criar despensas ilimitadas
            if (await UsuarioTemAcessoPremiumAsync(usuarioId)) 
                return true;

            // Usuários Free podem criar até 3 despensas
            var numeroDespensas = await ObterNumeroDeDespensasDoUsuarioAsync(usuarioId);
            return numeroDespensas < 3;
        }

        public async Task<bool> UsuarioPodeEnviarConvitesAsync(int usuarioId)
        {
            return await UsuarioTemAcessoPremiumAsync(usuarioId);
        }

        public async Task<bool> UsuarioTemAcessoAIAsync(int usuarioId)
        {
            return await UsuarioTemAcessoPremiumAsync(usuarioId);
        }

        public async Task<bool> UsuarioTemAcessoAnalyticsCompletaAsync(int usuarioId)
        {
            return await UsuarioTemAcessoPremiumAsync(usuarioId);
        }

        public async Task<Usuario> ObterUsuarioComPlanoAsync(int usuarioId)
        {
            var user = await _context.Usuarios.FindAsync(usuarioId);
            if (user == null)
                throw new ArgumentException($"Usuário {usuarioId} não encontrado");
            
            return user;
        }

        public async Task<SubscriptionStatus> ObterStatusAssinaturaAsync(int usuarioId)
        {
            return await ObterStatusAssinaturaCachedAsync(usuarioId);
        }

        public async Task<int> ObterNumeroDeDespensasDoUsuarioAsync(int usuarioId)
        {
            var cacheKey = $"user_pantries_count_{usuarioId}";
            
            if (_cache.TryGetValue(cacheKey, out int cachedCount))
                return cachedCount;

            var count = await _context.MembrosDespensa
                .Where(m => m.UsuarioId == usuarioId && m.Papel == PapelDespensa.Dono)
                .CountAsync();

            _cache.Set(cacheKey, count, TimeSpan.FromMinutes(CACHE_DURATION_MINUTES));
            return count;
        }

        public async Task<SubscricaoStripe?> ObterAssinaturaAtivaAsync(int usuarioId)
        {
            return await _context.AssinaturasStripe
                .Include(s => s.Pagamentos.OrderByDescending(p => p.DataPagamento).Take(5))
                .Where(s => s.UsuarioId == usuarioId)
                .Where(s => s.Status == StatusAssinatura.Ativa || s.Status == StatusAssinatura.EmTeste)
                .OrderByDescending(s => s.DataInicio)
                .FirstOrDefaultAsync();
        }

        public async Task<SubscricaoStripe> CriarAssinaturaAsync(int usuarioId, string stripeSubscriptionId, string stripeCustomerId, string planId)
        {
            // Verificar se já existe uma assinatura com este ID
            var existingSubscription = await _context.AssinaturasStripe
                .FirstOrDefaultAsync(s => s.StripeSubscriptionId == stripeSubscriptionId);

            if (existingSubscription != null)
            {
                _logger.LogWarning("Tentativa de criar assinatura duplicada: {StripeSubscriptionId}", stripeSubscriptionId);
                return existingSubscription;
            }

            // Criar assinatura com dados padrão (pode ser atualizada posteriormente via webhook)
            var novaAssinatura = new SubscricaoStripe
            {
                UsuarioId = usuarioId,
                StripeSubscriptionId = stripeSubscriptionId,
                StripeCustomerId = stripeCustomerId,
                PlanId = planId,
                Status = StatusAssinatura.Ativa, // Assumir ativa por padrão
                DataInicio = DateTime.UtcNow,
                ProximaCobranca = DateTime.UtcNow.AddDays(30), // Padrão 30 dias
                FimPeriodoAtual = DateTime.UtcNow.AddDays(30),
                Valor = planId.Contains("yearly") ? 49.99m : 4.99m, // Preços padrão
                Moeda = "EUR",
                Intervalo = planId.Contains("yearly") ? "year" : "month"
            };

            _context.AssinaturasStripe.Add(novaAssinatura);

            // Atualizar o usuário
            var usuario = await _context.Usuarios.FindAsync(usuarioId);
            if (usuario != null)
            {
                usuario.Plano = TipoDePlano.Premium;
                usuario.DataExpiracaoAssinatura = novaAssinatura.FimPeriodoAtual;
            }

            await _context.SaveChangesAsync();
            await InvalidarCacheUsuarioAsync(usuarioId);

            _logger.LogInformation("Nova assinatura criada para usuário {UserId}: {SubscriptionId}", usuarioId, stripeSubscriptionId);

            return novaAssinatura;
        }

        public async Task<SubscricaoStripe> AtualizarStatusAssinaturaAsync(string stripeSubscriptionId, StatusAssinatura novoStatus)
        {
            var assinatura = await _context.AssinaturasStripe
                .Include(s => s.Usuario)
                .FirstOrDefaultAsync(s => s.StripeSubscriptionId == stripeSubscriptionId);

            if (assinatura == null)
                throw new ArgumentException($"Assinatura {stripeSubscriptionId} não encontrada");

            var statusAnterior = assinatura.Status;
            assinatura.Status = novoStatus;
            assinatura.DataAtualizacao = DateTime.UtcNow;

            // Atualizar usuário baseado no status
            if (assinatura.Usuario != null)
            {
                if (novoStatus == StatusAssinatura.Ativa)
                {
                    assinatura.Usuario.Plano = TipoDePlano.Premium;
                    // Manter data de expiração atual
                }
                else if (novoStatus == StatusAssinatura.Cancelada)
                {
                    assinatura.Usuario.Plano = TipoDePlano.Free;
                    assinatura.Usuario.DataExpiracaoAssinatura = null;
                    assinatura.DataCancelamento = DateTime.UtcNow;
                }
            }

            await _context.SaveChangesAsync();
            await InvalidarCacheUsuarioAsync(assinatura.UsuarioId);

            _logger.LogInformation("Status da assinatura {SubscriptionId} alterado de {OldStatus} para {NewStatus}", 
                stripeSubscriptionId, statusAnterior, novoStatus);

            return assinatura;
        }

        public async Task<bool> CancelarAssinaturaAsync(string stripeSubscriptionId, DateTime? dataFinalizacao = null)
        {
            var assinatura = await _context.AssinaturasStripe
                .Include(s => s.Usuario)
                .FirstOrDefaultAsync(s => s.StripeSubscriptionId == stripeSubscriptionId);

            if (assinatura == null)
            {
                _logger.LogWarning("Tentativa de cancelar assinatura inexistente: {SubscriptionId}", stripeSubscriptionId);
                return false;
            }

            assinatura.DataCancelamento = DateTime.UtcNow;
            assinatura.CanceladaFimPeriodo = dataFinalizacao.HasValue;

            if (dataFinalizacao.HasValue)
            {
                // Cancelamento no fim do período - manter acesso até lá
                assinatura.Status = StatusAssinatura.Ativa;
                if (assinatura.Usuario != null)
                {
                    assinatura.Usuario.DataExpiracaoAssinatura = dataFinalizacao.Value;
                }
            }
            else
            {
                // Cancelamento imediato
                assinatura.Status = StatusAssinatura.Cancelada;
                if (assinatura.Usuario != null)
                {
                    assinatura.Usuario.Plano = TipoDePlano.Free;
                    assinatura.Usuario.DataExpiracaoAssinatura = null;
                }
            }

            await _context.SaveChangesAsync();
            await InvalidarCacheUsuarioAsync(assinatura.UsuarioId);

            var tipoCancelamento = dataFinalizacao.HasValue ? "fim do período" : "imediato";
            _logger.LogInformation("Assinatura {SubscriptionId} cancelada ({Tipo})", stripeSubscriptionId, tipoCancelamento);

            return true;
        }

        public async Task<SubscriptionAnalytics> ObterAnalyticsAssinaturasAsync()
        {
            var agora = DateTime.UtcNow;
            var inicioMes = new DateTime(agora.Year, agora.Month, 1);
            
            // MRR (Monthly Recurring Revenue)
            var assinaturasAtivas = await _context.AssinaturasStripe
                .Where(s => s.Status == StatusAssinatura.Ativa)
                .ToListAsync();

            var mrr = assinaturasAtivas
                .Where(s => s.Intervalo == "month")
                .Sum(s => s.Valor) +
                assinaturasAtivas
                .Where(s => s.Intervalo == "year")
                .Sum(s => s.Valor / 12);

            // ARR (Annual Recurring Revenue)
            var arr = mrr * 12;

            // Churn Rate
            var cancelamentosUltimoMes = await _context.AssinaturasStripe
                .Where(s => s.DataCancelamento >= inicioMes && s.DataCancelamento < agora)
                .CountAsync();

            var assinaturasInicioMes = await _context.AssinaturasStripe
                .Where(s => s.DataInicio < inicioMes && (s.DataCancelamento == null || s.DataCancelamento >= inicioMes))
                .CountAsync();

            var churnRate = assinaturasInicioMes > 0 ? (double)cancelamentosUltimoMes / assinaturasInicioMes : 0;

            // Conversion Rate
            var novasAssinaturasUltimoMes = await _context.AssinaturasStripe
                .Where(s => s.DataInicio >= inicioMes && s.DataInicio < agora)
                .CountAsync();

            var usuariosFree = await _context.Usuarios
                .Where(u => u.Plano == TipoDePlano.Free)
                .CountAsync();

            var conversionRate = usuariosFree > 0 ? (double)novasAssinaturasUltimoMes / usuariosFree : 0;

            // ARPU
            var usuariosAtivos = await _context.Usuarios.CountAsync();
            var arpu = usuariosAtivos > 0 ? mrr / usuariosAtivos : 0;

            return new SubscriptionAnalytics
            {
                MRR = mrr,
                ARR = arr,
                ChurnRate = churnRate,
                ConversionRate = conversionRate,
                TrialConversions = 0,
                ARPU = arpu,
                AssinaturasAtivas = assinaturasAtivas.Count,
                NovasAssinaturasUltimoMes = novasAssinaturasUltimoMes,
                CancelamentosUltimoMes = cancelamentosUltimoMes
            };
        }

        public Task InvalidarCacheUsuarioAsync(int usuarioId)
        {
            _cache.Remove($"subscription_status_{usuarioId}");
            _cache.Remove($"user_pantries_count_{usuarioId}");
            return Task.CompletedTask;
        }

        // MÉTODOS PRIVADOS

        private async Task<SubscriptionStatus> ObterStatusAssinaturaCachedAsync(int usuarioId)
        {
            var cacheKey = $"subscription_status_{usuarioId}";
            
            if (_cache.TryGetValue(cacheKey, out SubscriptionStatus? cachedStatus) && cachedStatus != null)
                return cachedStatus;

            var status = await CalcularStatusAssinaturaAsync(usuarioId);
            _cache.Set(cacheKey, status, TimeSpan.FromMinutes(CACHE_DURATION_MINUTES));
            
            return status;
        }

        private async Task<SubscriptionStatus> CalcularStatusAssinaturaAsync(int usuarioId)
        {
            var usuario = await _context.Usuarios.FindAsync(usuarioId);
            
            if (usuario == null)
            {
                return new SubscriptionStatus
                {
                    IsValid = false,
                    PlanoAtual = TipoDePlano.Free,
                    DaysUntilExpiration = 0,
                    CanUpgrade = false
                };
            }

            // Verificar assinatura ativa
            var assinaturaAtiva = await ObterAssinaturaAtivaAsync(usuarioId);
            
            bool isValid = false;
            int daysUntilExpiration = 0;

            if (assinaturaAtiva != null)
            {
                isValid = assinaturaAtiva.Status == StatusAssinatura.Ativa && 
                         assinaturaAtiva.FimPeriodoAtual > DateTime.UtcNow;
                
                if (isValid)
                {
                    var timeUntilExpiration = assinaturaAtiva.FimPeriodoAtual - DateTime.UtcNow;
                    daysUntilExpiration = Math.Max(0, (int)timeUntilExpiration.TotalDays);
                }
            }
            else if (usuario.Plano == TipoDePlano.Premium && usuario.DataExpiracaoAssinatura.HasValue)
            {
                // Fallback para o modelo antigo
                isValid = usuario.DataExpiracaoAssinatura.Value > DateTime.UtcNow;
                if (isValid)
                {
                    var timeUntilExpiration = usuario.DataExpiracaoAssinatura.Value - DateTime.UtcNow;
                    daysUntilExpiration = Math.Max(0, (int)timeUntilExpiration.TotalDays);
                }
            }

            return new SubscriptionStatus
            {
                IsValid = isValid,
                PlanoAtual = isValid ? TipoDePlano.Premium : TipoDePlano.Free,
                DataExpiracao = assinaturaAtiva?.FimPeriodoAtual ?? usuario.DataExpiracaoAssinatura,
                DaysUntilExpiration = daysUntilExpiration,
                CanUpgrade = !isValid
            };
        }
    }

    public class SubscriptionStatus
    {
        public bool IsValid { get; set; }
        public TipoDePlano PlanoAtual { get; set; }
        public DateTime? DataExpiracao { get; set; }
        public int DaysUntilExpiration { get; set; }
        public bool CanUpgrade { get; set; }
    }

    public class SubscriptionAnalytics
    {
        public decimal MRR { get; set; }
        public decimal ARR { get; set; }
        public double ChurnRate { get; set; }
        public double ConversionRate { get; set; }
        public int TrialConversions { get; set; }
        public decimal ARPU { get; set; }
        public int AssinaturasAtivas { get; set; }
        public int NovasAssinaturasUltimoMes { get; set; }
        public int CancelamentosUltimoMes { get; set; }
    }
} 