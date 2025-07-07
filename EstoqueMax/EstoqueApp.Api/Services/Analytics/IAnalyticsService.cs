using EstoqueApp.Api.Dtos;

namespace EstoqueApp.Api.Services.Analytics
{
    public interface IAnalyticsService
    {
        // **ANÁLISES DE CONSUMO**
        Task<List<ChartDataItemDto>> GetConsumoPorCategoriaAsync(int userId, int periodoDias = 30);
        Task<List<ChartDataItemDto>> GetTopProdutosMaisConsumidosAsync(int userId, int periodoDias = 30, int topLimit = 5);
        
        // **ANÁLISES FINANCEIRAS**
        Task<List<TimeSeriesChartItemDto>> GetGastosMensaisAsync(int userId, int meses = 6);
        Task<List<ChartDataItemDto>> GetGastosPorCategoriaAsync(int userId, int periodoDias = 30);
        
        // **ANÁLISES DE DESPERDÍCIO**
        Task<List<TimeSeriesChartItemDto>> GetTendenciaDesperdicioAsync(int userId, int meses = 6);
        Task<int> GetItensExpiradosNoMesAsync(int userId);
        
        // **ANÁLISES DE HÁBITOS**
        Task<List<HeatmapDataDto>> GetHeatmapConsumoAsync(int userId, int periodoDias = 30);
        
        // **KPIs (INDICADORES-CHAVE)**
        Task<List<KpiDataDto>> GetIndicadoresChaveAsync(int userId, int periodoDias = 30);
        
        // **DASHBOARD COMPLETO**
        Task<DashboardResponseDto> GetDashboardCompletoAsync(int userId, AnalyticsFilterDto? filtros = null);
        
        // **INSIGHTS AUTOMÁTICOS**
        Task<List<InsightDto>> GetInsightsAsync(int userId, int periodoDias = 30);
        
        // **ANÁLISES ESPECÍFICAS POR DESPENSA**
        Task<DashboardResponseDto> GetDashboardPorDespensaAsync(int userId, int despensaId, AnalyticsFilterDto? filtros = null);
        
        // **COMPARAÇÕES TEMPORAIS**
        Task<List<ChartDataItemDto>> GetComparacaoConsumoPeriodicaAsync(int userId, int periodoDiasAtual = 30, int periodoDiasAnterior = 30);
    }
} 