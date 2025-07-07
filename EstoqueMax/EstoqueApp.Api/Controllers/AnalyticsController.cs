using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using EstoqueApp.Api.Services.Analytics;
using EstoqueApp.Api.Dtos;
using Microsoft.AspNetCore.SignalR;
using EstoqueApp.Api.Hubs;

namespace EstoqueApp.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class AnalyticsController : ControllerBase
    {
        private readonly IAnalyticsService _analyticsService;
        private readonly IHubContext<EstoqueHub> _hubContext;
        private readonly ILogger<AnalyticsController> _logger;

        public AnalyticsController(IAnalyticsService analyticsService, IHubContext<EstoqueHub> hubContext, ILogger<AnalyticsController> logger)
        {
            _analyticsService = analyticsService;
            _hubContext = hubContext;
            _logger = logger;
        }

        // **ENDPOINT PRINCIPAL: Dashboard Completo**
        // GET: api/analytics/dashboard
        [HttpGet("dashboard")]
        public async Task<IActionResult> GetDashboardCompleto([FromQuery] AnalyticsFilterDto? filtros = null)
        {
            var userId = GetUserId();
            if (userId == null) return Unauthorized();

            try
            {
                var dashboard = await _analyticsService.GetDashboardCompletoAsync(userId.Value, filtros);
                
                return Ok(new { 
                    success = true,
                    data = dashboard,
                    message = "Dashboard carregado com sucesso",
                    timestamp = DateTime.UtcNow
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao obter dashboard para usuário {UserId}", userId);
                return BadRequest(new { 
                    success = false,
                    message = "Erro ao carregar dashboard",
                    error = ex.Message 
                });
            }
        }

        // **ANÁLISES DE CONSUMO**
        // GET: api/analytics/consumo/por-categoria
        [HttpGet("consumo/por-categoria")]
        public async Task<IActionResult> GetConsumoPorCategoria([FromQuery] int periodo = 30)
        {
            var userId = GetUserId();
            if (userId == null) return Unauthorized();

            try
            {
                var dados = await _analyticsService.GetConsumoPorCategoriaAsync(userId.Value, periodo);
                return Ok(dados);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao obter consumo por categoria para usuário {UserId}", userId);
                return BadRequest(new { error = "Erro ao carregar dados de consumo por categoria" });
            }
        }

        // GET: api/analytics/consumo/top-produtos
        [HttpGet("consumo/top-produtos")]
        public async Task<IActionResult> GetTopProdutos([FromQuery] int periodo = 30, [FromQuery] int top = 5)
        {
            var userId = GetUserId();
            if (userId == null) return Unauthorized();

            try
            {
                var dados = await _analyticsService.GetTopProdutosMaisConsumidosAsync(userId.Value, periodo, top);
                return Ok(dados);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao obter top produtos para usuário {UserId}", userId);
                return BadRequest(new { error = "Erro ao carregar dados de top produtos" });
            }
        }

        // **ANÁLISES FINANCEIRAS**
        // GET: api/analytics/gastos/evolucao-mensal
        [HttpGet("gastos/evolucao-mensal")]
        public async Task<IActionResult> GetGastosMensais([FromQuery] int meses = 6)
        {
            var userId = GetUserId();
            if (userId == null) return Unauthorized();

            try
            {
                var dados = await _analyticsService.GetGastosMensaisAsync(userId.Value, meses);
                return Ok(dados);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao obter gastos mensais para usuário {UserId}", userId);
                return BadRequest(new { error = "Erro ao carregar dados de gastos mensais" });
            }
        }

        // GET: api/analytics/gastos/por-categoria
        [HttpGet("gastos/por-categoria")]
        public async Task<IActionResult> GetGastosPorCategoria([FromQuery] int periodo = 30)
        {
            var userId = GetUserId();
            if (userId == null) return Unauthorized();

            try
            {
                var dados = await _analyticsService.GetGastosPorCategoriaAsync(userId.Value, periodo);
                return Ok(dados);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao obter gastos por categoria para usuário {UserId}", userId);
                return BadRequest(new { error = "Erro ao carregar dados de gastos por categoria" });
            }
        }

        // **ANÁLISES DE DESPERDÍCIO**
        // GET: api/analytics/desperdicio/tendencia
        [HttpGet("desperdicio/tendencia")]
        public async Task<IActionResult> GetTendenciaDesperdicio([FromQuery] int meses = 6)
        {
            var userId = GetUserId();
            if (userId == null) return Unauthorized();

            try
            {
                var dados = await _analyticsService.GetTendenciaDesperdicioAsync(userId.Value, meses);
                return Ok(dados);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao obter tendência de desperdício para usuário {UserId}", userId);
                return BadRequest(new { error = "Erro ao carregar dados de desperdício" });
            }
        }

        // GET: api/analytics/desperdicio/itens-expirados
        [HttpGet("desperdicio/itens-expirados")]
        public async Task<IActionResult> GetItensExpiradosNoMes()
        {
            var userId = GetUserId();
            if (userId == null) return Unauthorized();

            try
            {
                var quantidade = await _analyticsService.GetItensExpiradosNoMesAsync(userId.Value);
                return Ok(new { 
                    quantidade = quantidade,
                    mes = DateTime.UtcNow.ToString("MMMM yyyy"),
                    alerta = quantidade > 5 ? "Alto desperdício detectado" : "Nível normal"
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao obter itens expirados para usuário {UserId}", userId);
                return BadRequest(new { error = "Erro ao carregar dados de itens expirados" });
            }
        }

        // **ANÁLISES DE HÁBITOS**
        // GET: api/analytics/habitos/heatmap
        [HttpGet("habitos/heatmap")]
        public async Task<IActionResult> GetHeatmapConsumo([FromQuery] int periodo = 30)
        {
            var userId = GetUserId();
            if (userId == null) return Unauthorized();

            try
            {
                var dados = await _analyticsService.GetHeatmapConsumoAsync(userId.Value, periodo);
                return Ok(dados);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao obter heatmap de consumo para usuário {UserId}", userId);
                return BadRequest(new { error = "Erro ao carregar dados de heatmap" });
            }
        }

        // **KPIs (INDICADORES-CHAVE)**
        // GET: api/analytics/kpis
        [HttpGet("kpis")]
        public async Task<IActionResult> GetIndicadoresChave([FromQuery] int periodo = 30)
        {
            var userId = GetUserId();
            if (userId == null) return Unauthorized();

            try
            {
                var kpis = await _analyticsService.GetIndicadoresChaveAsync(userId.Value, periodo);
                return Ok(new { 
                    kpis = kpis,
                    totalKpis = kpis.Count,
                    periodoAnalise = periodo,
                    dataUltimaAtualizacao = DateTime.UtcNow
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao obter KPIs para usuário {UserId}", userId);
                return BadRequest(new { error = "Erro ao carregar indicadores-chave" });
            }
        }

        // **INSIGHTS AUTOMÁTICOS**
        // GET: api/analytics/insights
        [HttpGet("insights")]
        public async Task<IActionResult> GetInsights([FromQuery] int periodo = 30)
        {
            var userId = GetUserId();
            if (userId == null) return Unauthorized();

            try
            {
                var insights = await _analyticsService.GetInsightsAsync(userId.Value, periodo);
                
                // Notificar via SignalR se houver insights críticos
                var insightsCriticos = insights.Where(i => i.Prioridade >= 4).ToList();
                if (insightsCriticos.Any())
                {
                    await _hubContext.Clients.Group($"User-{userId}")
                        .SendAsync("InsightsCriticosDetectados", new { 
                            insights = insightsCriticos,
                            quantidade = insightsCriticos.Count
                        });
                }

                return Ok(new { 
                    insights = insights,
                    totalInsights = insights.Count,
                    insightsCriticos = insightsCriticos.Count,
                    periodoAnalise = periodo
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao obter insights para usuário {UserId}", userId);
                return BadRequest(new { error = "Erro ao carregar insights" });
            }
        }

        // **ANÁLISES POR DESPENSA**
        // GET: api/analytics/despensa/{despensaId}
        [HttpGet("despensa/{despensaId}")]
        public async Task<IActionResult> GetDashboardPorDespensa(int despensaId, [FromQuery] AnalyticsFilterDto? filtros = null)
        {
            var userId = GetUserId();
            if (userId == null) return Unauthorized();

            try
            {
                var dashboard = await _analyticsService.GetDashboardPorDespensaAsync(userId.Value, despensaId, filtros);
                return Ok(new { 
                    success = true,
                    data = dashboard,
                    despensaId = despensaId,
                    message = "Dashboard da despensa carregado com sucesso"
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao obter dashboard da despensa {DespensaId} para usuário {UserId}", despensaId, userId);
                return BadRequest(new { error = "Erro ao carregar dashboard da despensa" });
            }
        }

        // **COMPARAÇÕES E TENDÊNCIAS**
        // GET: api/analytics/comparacao/consumo-periodica
        [HttpGet("comparacao/consumo-periodica")]
        public async Task<IActionResult> GetComparacaoConsumoPeriodicaAsync([FromQuery] int periodoAtual = 30, [FromQuery] int periodoAnterior = 30)
        {
            var userId = GetUserId();
            if (userId == null) return Unauthorized();

            try
            {
                var dados = await _analyticsService.GetComparacaoConsumoPeriodicaAsync(userId.Value, periodoAtual, periodoAnterior);
                return Ok(new { 
                    comparacao = dados,
                    periodoAtual = periodoAtual,
                    periodoAnterior = periodoAnterior,
                    dataComparacao = DateTime.UtcNow
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao obter comparação de consumo para usuário {UserId}", userId);
                return BadRequest(new { error = "Erro ao carregar comparação de consumo" });
            }
        }

        // **ENDPOINT PARA ATUALIZAR DADOS**
        // POST: api/analytics/refresh
        [HttpPost("refresh")]
        public async Task<IActionResult> RefreshAnalytics()
        {
            var userId = GetUserId();
            if (userId == null) return Unauthorized();

            try
            {
                // Simular atualização de dados (poderia disparar recálculo de análises)
                await Task.Delay(100); // Simulação de processamento

                // Notificar via SignalR que os dados foram atualizados
                await _hubContext.Clients.Group($"User-{userId}")
                    .SendAsync("AnalyticsAtualizados", new { 
                        message = "Dados do dashboard atualizados",
                        dataAtualizacao = DateTime.UtcNow
                    });

                return Ok(new { 
                    success = true,
                    message = "Dados do dashboard atualizados com sucesso",
                    dataAtualizacao = DateTime.UtcNow
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao atualizar analytics para usuário {UserId}", userId);
                return BadRequest(new { error = "Erro ao atualizar dados" });
            }
        }

        // **ENDPOINT PARA EXPORT DE DADOS**
        // GET: api/analytics/export
        [HttpGet("export")]
        public async Task<IActionResult> ExportarDados([FromQuery] string formato = "json", [FromQuery] int periodo = 30)
        {
            var userId = GetUserId();
            if (userId == null) return Unauthorized();

            try
            {
                var dashboard = await _analyticsService.GetDashboardCompletoAsync(userId.Value, new AnalyticsFilterDto { PeriodoDias = periodo });
                
                if (formato.ToLower() == "csv")
                {
                    // Implementar exportação CSV (simplificado)
                    var csv = ConvertDashboardToCSV(dashboard);
                    return File(System.Text.Encoding.UTF8.GetBytes(csv), "text/csv", $"estoque-analytics-{DateTime.UtcNow:yyyy-MM-dd}.csv");
                }
                
                return Ok(new { 
                    formato = formato,
                    dados = dashboard,
                    dataExportacao = DateTime.UtcNow
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao exportar dados para usuário {UserId}", userId);
                return BadRequest(new { error = "Erro ao exportar dados" });
            }
        }

        // **MÉTODOS AUXILIARES**
        private int? GetUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return int.TryParse(userIdClaim, out int userId) ? userId : null;
        }

        private string ConvertDashboardToCSV(DashboardResponseDto dashboard)
        {
            // Implementação básica de conversão para CSV
            var csv = new System.Text.StringBuilder();
            csv.AppendLine("Tipo,Label,Valor,Data");
            
            foreach (var item in dashboard.ConsumoPorCategoria)
            {
                csv.AppendLine($"Consumo por Categoria,{item.Label},{item.Value},{DateTime.UtcNow:yyyy-MM-dd}");
            }
            
            foreach (var item in dashboard.GastosPorCategoria)
            {
                csv.AppendLine($"Gastos por Categoria,{item.Label},{item.Value},{DateTime.UtcNow:yyyy-MM-dd}");
            }
            
            return csv.ToString();
        }
    }
} 