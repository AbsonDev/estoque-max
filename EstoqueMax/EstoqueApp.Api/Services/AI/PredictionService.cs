using Microsoft.ML;
using Microsoft.ML.Transforms.TimeSeries;
using EstoqueApp.Api.Data;
using EstoqueApp.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace EstoqueApp.Api.Services.AI
{
    public class PredictionService
    {
        private readonly MLContext _mlContext = new MLContext(seed: 1);
        private readonly EstoqueContext _context;
        private readonly ILogger<PredictionService> _logger;

        public PredictionService(EstoqueContext context, ILogger<PredictionService> logger)
        {
            _context = context;
            _logger = logger;
        }

        // Define a estrutura dos dados de entrada para o modelo
        public class ConsumoInput
        {
            public float QuantidadeConsumida { get; set; }
            public DateTime Data { get; set; }
        }

        // Define a estrutura da previsão
        public class ConsumoPrediction
        {
            public float[] Previsao { get; set; } = Array.Empty<float>();
        }

        // Modelo de dados para treino mais completo
        public class ConsumoExtendido
        {
            public float QuantidadeConsumida { get; set; }
            public float DiaDaSemana { get; set; } // 1-7
            public float HoraDoDia { get; set; } // 0-23
            public float QuantidadeRestante { get; set; }
            public float DiaDoMes { get; set; } // 1-31
        }

        public class PrevisaoResultado
        {
            public int DiasRestantesEstimados { get; set; }
            public float ConsumoMedioDiario { get; set; }
            public float[] PrevisaoProximos7Dias { get; set; } = Array.Empty<float>();
            public string StatusConfianca { get; set; } = "Baixa";
            public int TotalRegistrosUtilizados { get; set; }
        }

        // Método para treinar um modelo para um produto específico
        public async Task<ITransformer?> TreinarModeloAsync(int estoqueItemId)
        {
            try
            {
                _logger.LogInformation("Iniciando treino do modelo para EstoqueItem {EstoqueItemId}", estoqueItemId);

                // Buscar histórico de consumo dos últimos 6 meses
                var seisMailAtras = DateTime.UtcNow.AddMonths(-6);
                var historicoConsumo = await _context.HistoricosDeConsumo
                    .Where(h => h.EstoqueItemId == estoqueItemId && h.DataDoConsumo >= seisMailAtras)
                    .OrderBy(h => h.DataDoConsumo)
                    .ToListAsync();

                if (historicoConsumo.Count < 10) // Mínimo de 10 registros para treinar
                {
                    _logger.LogWarning("Dados insuficientes para treinar modelo. EstoqueItem {EstoqueItemId} tem apenas {Count} registros", 
                        estoqueItemId, historicoConsumo.Count);
                    return null;
                }

                // Converter para dados de treino
                var dadosParaTreino = historicoConsumo.Select(h => new ConsumoExtendido
                {
                    QuantidadeConsumida = h.QuantidadeConsumida,
                    DiaDaSemana = (float)h.DiaSemanaDaConsumo + 1, // 1-7
                    HoraDoDia = h.HoraDaConsumo,
                    QuantidadeRestante = h.QuantidadeRestanteAposConsumo,
                    DiaDoMes = h.DataDoConsumo.Day
                }).ToList();

                var dados = _mlContext.Data.LoadFromEnumerable(dadosParaTreino);

                // Pipeline de ML para previsão de séries temporais
                var pipeline = _mlContext.Forecasting.ForecastBySsa(
                    outputColumnName: nameof(ConsumoPrediction.Previsao),
                    inputColumnName: nameof(ConsumoExtendido.QuantidadeConsumida),
                    windowSize: Math.Min(7, dadosParaTreino.Count / 2), // Janela semanal ou menor se poucos dados
                    seriesLength: Math.Min(30, dadosParaTreino.Count), // Até 30 dias de análise
                    trainSize: dadosParaTreino.Count,
                    horizon: 7, // Prever próximos 7 dias
                    confidenceLevel: 0.95f,
                    confidenceLowerBoundColumn: "LowerBoundResult",
                    confidenceUpperBoundColumn: "UpperBoundResult"
                );

                var modelo = pipeline.Fit(dados);
                
                _logger.LogInformation("Modelo treinado com sucesso para EstoqueItem {EstoqueItemId} usando {Count} registros", 
                    estoqueItemId, dadosParaTreino.Count);
                
                return modelo;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao treinar modelo para EstoqueItem {EstoqueItemId}", estoqueItemId);
                return null;
            }
        }

        // Método para usar um modelo treinado para fazer uma previsão
        public ConsumoPrediction? Prever(ITransformer modelo)
        {
            try
            {
                var motorDePrevisao = modelo.CreateTimeSeriesEngine<ConsumoExtendido, ConsumoPrediction>(_mlContext);
                return motorDePrevisao.Predict();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao fazer previsão com modelo");
                return null;
            }
        }

        // Método principal para obter previsão completa de um item
        public async Task<PrevisaoResultado> ObterPrevisaoConsumoAsync(int estoqueItemId)
        {
            try
            {
                // Verificar se existe histórico suficiente
                var totalRegistros = await _context.HistoricosDeConsumo
                    .CountAsync(h => h.EstoqueItemId == estoqueItemId);

                if (totalRegistros < 5)
                {
                    return new PrevisaoResultado
                    {
                        DiasRestantesEstimados = -1,
                        ConsumoMedioDiario = 0,
                        StatusConfianca = "Dados Insuficientes",
                        TotalRegistrosUtilizados = totalRegistros
                    };
                }

                // Calcular consumo médio dos últimos 30 dias
                var trintaDiasAtras = DateTime.UtcNow.AddDays(-30);
                var consumoRecente = await _context.HistoricosDeConsumo
                    .Where(h => h.EstoqueItemId == estoqueItemId && h.DataDoConsumo >= trintaDiasAtras)
                    .ToListAsync();

                var consumoMedioDiario = 0f;
                if (consumoRecente.Any())
                {
                    var totalConsumido = consumoRecente.Sum(h => h.QuantidadeConsumida);
                    var diasComConsumo = consumoRecente.GroupBy(h => h.DataDoConsumo.Date).Count();
                    consumoMedioDiario = diasComConsumo > 0 ? totalConsumido / (float)diasComConsumo : 0;
                }

                // Buscar quantidade atual do estoque
                var estoqueItem = await _context.EstoqueItens.FindAsync(estoqueItemId);
                if (estoqueItem == null)
                {
                    throw new ArgumentException($"EstoqueItem {estoqueItemId} não encontrado");
                }

                // Treinar modelo para previsão mais precisa
                var modelo = await TreinarModeloAsync(estoqueItemId);
                var previsaoIA = new float[7];
                
                if (modelo != null)
                {
                    var previsao = Prever(modelo);
                    if (previsao?.Previsao != null && previsao.Previsao.Length > 0)
                    {
                        previsaoIA = previsao.Previsao.Take(7).ToArray();
                    }
                }

                // Calcular dias restantes baseado na previsão da IA ou média simples
                var diasRestantes = CalcularDiasRestantes(estoqueItem.Quantidade, previsaoIA, consumoMedioDiario);
                
                // Determinar nível de confiança
                var statusConfianca = DeterminarConfianca(totalRegistros, modelo != null);

                return new PrevisaoResultado
                {
                    DiasRestantesEstimados = diasRestantes,
                    ConsumoMedioDiario = consumoMedioDiario,
                    PrevisaoProximos7Dias = previsaoIA,
                    StatusConfianca = statusConfianca,
                    TotalRegistrosUtilizados = totalRegistros
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao obter previsão de consumo para EstoqueItem {EstoqueItemId}", estoqueItemId);
                return new PrevisaoResultado
                {
                    DiasRestantesEstimados = -1,
                    ConsumoMedioDiario = 0,
                    StatusConfianca = "Erro",
                    TotalRegistrosUtilizados = 0
                };
            }
        }

        private int CalcularDiasRestantes(int quantidadeAtual, float[] previsaoIA, float consumoMedioDiario)
        {
            if (quantidadeAtual <= 0) return 0;

            // Se temos previsão da IA e ela é válida
            if (previsaoIA != null && previsaoIA.Length > 0 && previsaoIA.Any(p => p > 0))
            {
                var quantidadeSimulada = (float)quantidadeAtual;
                var diasSimulados = 0;

                // Simular consumo dia a dia usando previsão da IA
                for (int dia = 0; dia < previsaoIA.Length && quantidadeSimulada > 0; dia++)
                {
                    var consumoDoDia = Math.Max(0, previsaoIA[dia]);
                    quantidadeSimulada -= consumoDoDia;
                    diasSimulados++;
                    
                    if (quantidadeSimulada <= 0) return diasSimulados;
                }

                // Se ainda há estoque após 7 dias, extrapolar com a média da previsão
                if (quantidadeSimulada > 0)
                {
                    var mediaPrevisao = previsaoIA.Where(p => p > 0).DefaultIfEmpty(0).Average();
                    if (mediaPrevisao > 0)
                    {
                        var diasAdicionais = (int)Math.Ceiling(quantidadeSimulada / mediaPrevisao);
                        return diasSimulados + diasAdicionais;
                    }
                }

                return diasSimulados;
            }

            // Fallback: usar consumo médio diário simples
            if (consumoMedioDiario > 0)
            {
                return (int)Math.Ceiling(quantidadeAtual / consumoMedioDiario);
            }

            // Se não há dados suficientes, retornar -1 (indeterminado)
            return -1;
        }

        private string DeterminarConfianca(int totalRegistros, bool modeloTreinado)
        {
            if (!modeloTreinado || totalRegistros < 5) return "Baixa";
            if (totalRegistros >= 50) return "Alta";
            if (totalRegistros >= 20) return "Média";
            return "Baixa";
        }

        // Método para limpar modelos antigos (chamado pelo serviço em background)
        public Task LimparModelosAntigosAsync()
        {
            try
            {
                var diretorioModelos = Path.Combine(Directory.GetCurrentDirectory(), "modelos_ia");
                if (Directory.Exists(diretorioModelos))
                {
                    var arquivos = Directory.GetFiles(diretorioModelos, "*.zip");
                    var seteDiasAtras = DateTime.UtcNow.AddDays(-7);

                    foreach (var arquivo in arquivos)
                    {
                        var infoArquivo = new FileInfo(arquivo);
                        if (infoArquivo.CreationTime < seteDiasAtras)
                        {
                            File.Delete(arquivo);
                            _logger.LogInformation("Modelo antigo removido: {Arquivo}", arquivo);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao limpar modelos antigos");
            }
            
            return Task.CompletedTask;
        }
    }
} 