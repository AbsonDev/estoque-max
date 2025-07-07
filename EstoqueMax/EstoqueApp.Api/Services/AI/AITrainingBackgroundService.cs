using EstoqueApp.Api.Data;
using EstoqueApp.Api.Services.AI;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.SignalR;
using EstoqueApp.Api.Hubs;

namespace EstoqueApp.Api.Services.AI
{
    public class AITrainingBackgroundService : BackgroundService
    {
        private readonly IServiceProvider _serviceProvider;
        private readonly ILogger<AITrainingBackgroundService> _logger;
        private readonly TimeSpan _periodo = TimeSpan.FromHours(6); // Treinar a cada 6 horas

        public AITrainingBackgroundService(IServiceProvider serviceProvider, ILogger<AITrainingBackgroundService> logger)
        {
            _serviceProvider = serviceProvider;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("Serviço de treino de IA iniciado. Executará a cada {Periodo}", _periodo);

            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    await ProcessarTreinoModelos();
                    await Task.Delay(_periodo, stoppingToken);
                }
                catch (OperationCanceledException)
                {
                    _logger.LogInformation("Serviço de treino de IA foi cancelado");
                    break;
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Erro no serviço de treino de IA");
                    // Em caso de erro, esperar um período menor antes de tentar novamente
                    await Task.Delay(TimeSpan.FromMinutes(30), stoppingToken);
                }
            }
        }

        private async Task ProcessarTreinoModelos()
        {
            using var scope = _serviceProvider.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<EstoqueContext>();
            var predictionService = scope.ServiceProvider.GetRequiredService<PredictionService>();
            var hubContext = scope.ServiceProvider.GetRequiredService<IHubContext<EstoqueHub>>();

            _logger.LogInformation("Iniciando processo de treino de modelos de IA");

            try
            {
                // 1. Buscar todos os EstoqueItens ativos (com quantidade > 0)
                var itensAtivos = await context.EstoqueItens
                    .Where(e => e.Quantidade > 0)
                    .Include(e => e.Produto)
                    .Include(e => e.Despensa)
                    .ToListAsync();

                _logger.LogInformation("Encontrados {Count} itens de estoque ativos para processar", itensAtivos.Count);

                var modelosProcessados = 0;
                var modelosComSucesso = 0;
                var previsõesAtualizadas = new List<(int EstoqueItemId, int DiasRestantes, int DespensaId)>();

                foreach (var item in itensAtivos)
                {
                    try
                    {
                        modelosProcessados++;
                        
                        // 2. Verificar se tem histórico suficiente
                        var totalHistorico = await context.HistoricosDeConsumo
                            .CountAsync(h => h.EstoqueItemId == item.Id);

                        if (totalHistorico < 5)
                        {
                            _logger.LogDebug("Item {ProdutoNome} (ID: {ItemId}) tem histórico insuficiente ({Count} registros)", 
                                item.Produto.Nome, item.Id, totalHistorico);
                            continue;
                        }

                        // 3. Obter previsão atualizada
                        var previsao = await predictionService.ObterPrevisaoConsumoAsync(item.Id);
                        
                        if (previsao.DiasRestantesEstimados > 0)
                        {
                            modelosComSucesso++;
                            previsõesAtualizadas.Add((item.Id, previsao.DiasRestantesEstimados, item.DespensaId));
                            
                            _logger.LogDebug("Previsão atualizada para {ProdutoNome}: {Dias} dias restantes (confiança: {Confianca})", 
                                item.Produto.Nome, previsao.DiasRestantesEstimados, previsao.StatusConfianca);
                        }

                        // Pequena pausa para não sobrecarregar o sistema
                        await Task.Delay(100);
                    }
                    catch (Exception ex)
                    {
                        _logger.LogWarning(ex, "Erro ao processar item {ProdutoNome} (ID: {ItemId})", 
                            item.Produto.Nome, item.Id);
                    }
                }

                // 4. Notificar clientes sobre previsões atualizadas via SignalR
                if (previsõesAtualizadas.Any())
                {
                    await NotificarPrevisõesAtualizadas(hubContext, previsõesAtualizadas);
                }

                // 5. Limpar modelos antigos
                await predictionService.LimparModelosAntigosAsync();

                _logger.LogInformation("Treino concluído: {Sucesso}/{Total} modelos processados com sucesso. {Previsoes} previsões atualizadas", 
                    modelosComSucesso, modelosProcessados, previsõesAtualizadas.Count);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro durante o processo de treino de modelos");
            }
        }

        private async Task NotificarPrevisõesAtualizadas(IHubContext<EstoqueHub> hubContext, 
            List<(int EstoqueItemId, int DiasRestantes, int DespensaId)> previsões)
        {
            try
            {
                // Agrupar por despensa para otimizar notificações
                var previsõesPorDespensa = previsões.GroupBy(p => p.DespensaId);

                foreach (var grupo in previsõesPorDespensa)
                {
                    var despensaId = grupo.Key;
                    var itensAtualizados = grupo.Select(g => new {
                        estoqueItemId = g.EstoqueItemId,
                        diasRestantes = g.DiasRestantes
                    }).ToArray();

                    // Notificar todos os membros da despensa
                    await hubContext.Clients.Group($"Despensa-{despensaId}")
                        .SendAsync("PrevisõesAtualizadas", new {
                            despensaId = despensaId,
                            itensAtualizados = itensAtualizados,
                            dataAtualizacao = DateTime.UtcNow
                        });

                    _logger.LogDebug("Notificação enviada para Despensa-{DespensaId} com {Count} previsões atualizadas", 
                        despensaId, itensAtualizados.Length);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao notificar previsões atualizadas via SignalR");
            }
        }

        public override async Task StopAsync(CancellationToken cancellationToken)
        {
            _logger.LogInformation("Parando serviço de treino de IA...");
            await base.StopAsync(cancellationToken);
        }
    }
} 