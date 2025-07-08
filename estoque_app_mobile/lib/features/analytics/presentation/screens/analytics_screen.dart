import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/analytics_models.dart';
import '../bloc/analytics_bloc.dart';
import '../widgets/analytics_card.dart';
import '../widgets/chart_card.dart';
import '../widgets/insights_card.dart';
import '../widgets/kpi_card.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  void _loadDashboard() {
    context.read<AnalyticsBloc>().add(LoadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: BlocConsumer<AnalyticsBloc, AnalyticsState>(
          listener: (context, state) {
            if (state is AnalyticsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is AnalyticsLoading) {
              return _buildLoading();
            }

            if (state is AnalyticsLoaded) {
              return _buildDashboard(state.dashboard);
            }

            if (state is AnalyticsRefreshing) {
              return _buildDashboard(state.currentDashboard, isRefreshing: true);
            }

            return _buildError();
          },
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar analytics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente novamente mais tarde',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadDashboard,
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(AnalyticsDashboard dashboard, {bool isRefreshing = false}) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AnalyticsBloc>().add(RefreshAnalytics());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(isRefreshing),
            const SizedBox(height: 24),

            // KPIs
            _buildKPISection(dashboard.indicadores),
            const SizedBox(height: 24),

            // Charts Section
            _buildChartsSection(dashboard),
            const SizedBox(height: 24),

            // Top Products
            _buildTopProductsSection(dashboard.topProdutos),
            const SizedBox(height: 24),

            // Insights
            _buildInsightsSection(dashboard.insights),
            const SizedBox(height: 24),

            // Expired Items
            _buildExpiredItemsSection(dashboard.itensExpirados),
            const SizedBox(height: 100), // Bottom padding for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isRefreshing) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Analytics',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Acompanhe suas métricas e insights',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (isRefreshing)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
      ],
    );
  }

  Widget _buildKPISection(List<IndicadorChave> indicadores) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Indicadores Principais',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: indicadores.length,
          itemBuilder: (context, index) {
            final indicador = indicadores[index];
            return KPICard(
              title: indicador.nome,
              value: indicador.valor,
              unit: indicador.unidade,
              change: indicador.variacao,
              color: _getColorFromString(indicador.cor),
              icon: _getIconFromTipo(indicador.tipo),
            ).animate().fadeIn(
              delay: Duration(milliseconds: 100 * index),
              duration: const Duration(milliseconds: 500),
            );
          },
        ),
      ],
    );
  }

  Widget _buildChartsSection(AnalyticsDashboard dashboard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gráficos',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        
        // Monthly Expenses Chart
        if (dashboard.gastosMensais.isNotEmpty) ...[
          ChartCard(
            title: 'Gastos Mensais',
            chart: _buildMonthlyExpensesChart(dashboard.gastosMensais),
          ).animate().fadeIn(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 500),
          ),
          const SizedBox(height: 16),
        ],

        // Category Consumption Chart
        if (dashboard.consumoPorCategoria.isNotEmpty) ...[
          ChartCard(
            title: 'Consumo por Categoria',
            chart: _buildCategoryConsumptionChart(dashboard.consumoPorCategoria),
          ).animate().fadeIn(
            delay: const Duration(milliseconds: 300),
            duration: const Duration(milliseconds: 500),
          ),
          const SizedBox(height: 16),
        ],

        // Waste Trend Chart
        if (dashboard.tendenciaDesperdicio.isNotEmpty) ...[
          ChartCard(
            title: 'Tendência de Desperdício',
            chart: _buildWasteTrendChart(dashboard.tendenciaDesperdicio),
          ).animate().fadeIn(
            delay: const Duration(milliseconds: 400),
            duration: const Duration(milliseconds: 500),
          ),
        ],
      ],
    );
  }

  Widget _buildTopProductsSection(List<TopProduto> topProdutos) {
    if (topProdutos.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Produtos',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: topProdutos.asMap().entries.map((entry) {
              final index = entry.key;
              final produto = entry.value;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                title: Text(
                  produto.nome,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                subtitle: Text(
                  produto.categoria,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      NumberFormat.currency(
                        locale: 'pt_BR',
                        symbol: 'R\$',
                      ).format(produto.gasto),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '${produto.consumo.toStringAsFixed(1)} unidades',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ).animate().fadeIn(
          delay: const Duration(milliseconds: 500),
          duration: const Duration(milliseconds: 500),
        ),
      ],
    );
  }

  Widget _buildInsightsSection(List<InsightAI> insights) {
    if (insights.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Insights IA',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: insights.length,
          itemBuilder: (context, index) {
            final insight = insights[index];
            return InsightsCard(
              title: insight.titulo,
              description: insight.descricao,
              confidence: insight.confianca,
              type: insight.tipo,
              action: insight.acao,
            ).animate().fadeIn(
              delay: Duration(milliseconds: 100 * index),
              duration: const Duration(milliseconds: 500),
            );
          },
        ),
      ],
    );
  }

  Widget _buildExpiredItemsSection(List<ItemExpirado> itensExpirados) {
    if (itensExpirados.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Itens Expirados',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: itensExpirados.map((item) {
              return ListTile(
                leading: Icon(
                  Icons.warning_amber_rounded,
                  color: AppTheme.error,
                ),
                title: Text(
                  item.nome,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Expirado em ${DateFormat('dd/MM/yyyy').format(item.dataExpiracao)}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                  ),
                ),
                trailing: Text(
                  NumberFormat.currency(
                    locale: 'pt_BR',
                    symbol: 'R\$',
                  ).format(item.valor),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.error,
                  ),
                ),
              );
            }).toList(),
          ),
        ).animate().fadeIn(
          delay: const Duration(milliseconds: 600),
          duration: const Duration(milliseconds: 500),
        ),
      ],
    );
  }

  Widget _buildMonthlyExpensesChart(List<GastoMensal> gastos) {
    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: gastos.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.valor);
              }).toList(),
              isCurved: true,
              color: AppTheme.primaryColor,
              barWidth: 3,
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primaryColor.withOpacity(0.1),
              ),
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < gastos.length) {
                    return Text(
                      DateFormat('MMM').format(gastos[value.toInt()].mes),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    'R\$${value.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 100,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppTheme.textSecondary.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryConsumptionChart(List<ConsumoCategoria> consumo) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: consumo.map((categoria) {
            return PieChartSectionData(
              value: categoria.valor,
              title: categoria.categoria,
              color: _getColorFromString(categoria.cor),
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            );
          }).toList(),
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  Widget _buildWasteTrendChart(List<TendenciaDesperdicio> tendencia) {
    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: tendencia.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.valor);
              }).toList(),
              isCurved: true,
              color: AppTheme.error,
              barWidth: 3,
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.error.withOpacity(0.1),
              ),
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < tendencia.length) {
                    return Text(
                      DateFormat('dd/MM').format(tendencia[value.toInt()].data),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    'R\$${value.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 50,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppTheme.textSecondary.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
          ),
        ),
      ),
    );
  }

  Color _getColorFromString(String? colorString) {
    if (colorString == null) return AppTheme.primaryColor;
    
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xff')));
    } catch (e) {
      return AppTheme.primaryColor;
    }
  }

  IconData _getIconFromTipo(TipoIndicador tipo) {
    switch (tipo) {
      case TipoIndicador.economia:
        return Icons.savings;
      case TipoIndicador.desperdicio:
        return Icons.warning;
      case TipoIndicador.eficiencia:
        return Icons.trending_up;
      case TipoIndicador.consumo:
        return Icons.shopping_cart;
    }
  }
} 