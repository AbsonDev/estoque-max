namespace EstoqueApp.Api.Dtos
{
    // **DTO base para gráficos de pizza e barras**
    public class ChartDataItemDto
    {
        public string Label { get; set; } = string.Empty;
        public decimal Value { get; set; }
        public string? Color { get; set; } // Para customização visual
        public int? Count { get; set; } // Para dados que precisam de contagem adicional
    }

    // **DTO para gráficos de linha temporal**
    public class TimeSeriesChartItemDto
    {
        public DateTime Date { get; set; }
        public decimal Value { get; set; }
        public string? Label { get; set; } // Para séries múltiplas
    }

    // **DTO para KPIs (indicadores-chave)**
    public class KpiDataDto
    {
        public string Name { get; set; } = string.Empty;
        public decimal Value { get; set; }
        public decimal? PreviousValue { get; set; }
        public decimal? PercentageChange { get; set; }
        public string Trend { get; set; } = "stable"; // "up", "down", "stable"
        public string Unit { get; set; } = string.Empty; // "€", "itens", "%"
        public string? Icon { get; set; }
    }

    // **DTO para heatmap semanal**
    public class HeatmapDataDto
    {
        public DayOfWeek DayOfWeek { get; set; }
        public int Hour { get; set; }
        public decimal Intensity { get; set; } // 0-100 para intensidade de cor
        public int Count { get; set; } // Número real de consumos
    }

    // **DTO consolidado para resposta do dashboard**
    public class DashboardResponseDto
    {
        // Análise de Consumo
        public List<ChartDataItemDto> ConsumoPorCategoria { get; set; } = new();
        public List<ChartDataItemDto> TopProdutosMaisConsumidos { get; set; } = new();
        
        // Análises Financeiras
        public List<TimeSeriesChartItemDto> GastosMensais { get; set; } = new();
        public List<ChartDataItemDto> GastosPorCategoria { get; set; } = new();
        
        // KPIs importantes
        public List<KpiDataDto> IndicadoresChave { get; set; } = new();
        
        // Análise de Desperdício
        public List<TimeSeriesChartItemDto> TendenciaDesperdicio { get; set; } = new();
        
        // Análise de Hábitos
        public List<HeatmapDataDto> HeatmapConsumo { get; set; } = new();
        
        // Metadados
        public DateTime DataUltimaAtualizacao { get; set; } = DateTime.UtcNow;
        public int PeriodoAnalise { get; set; } // Dias analisados
        public string? UsuarioNome { get; set; }
        public int TotalDespensas { get; set; }
    }

    // **DTO para parâmetros de filtro**
    public class AnalyticsFilterDto
    {
        public int PeriodoDias { get; set; } = 30;
        public int? DespensaId { get; set; } // null = todas as despensas
        public string? Categoria { get; set; } // null = todas as categorias
        public DateTime? DataInicio { get; set; }
        public DateTime? DataFim { get; set; }
        public int TopLimit { get; set; } = 5; // Para rankings
    }

    // **DTO para insights automáticos**
    public class InsightDto
    {
        public string Titulo { get; set; } = string.Empty;
        public string Descricao { get; set; } = string.Empty;
        public string Tipo { get; set; } = string.Empty; // "warning", "info", "success", "tip"
        public string? Acao { get; set; } // Ação sugerida
        public decimal? Valor { get; set; } // Valor monetário associado
        public string? Icon { get; set; }
        public int Prioridade { get; set; } = 1; // 1-5, sendo 5 o mais importante
    }
} 