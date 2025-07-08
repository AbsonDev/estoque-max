import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/subscription_models.dart';
import '../bloc/subscription_bloc.dart';
import '../widgets/subscription_plan_card.dart';
import '../widgets/subscription_status_card.dart';
import '../widgets/usage_analytics_card.dart';
import '../widgets/billing_history_card.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    context.read<SubscriptionBloc>().add(LoadSubscriptionStatus());
    context.read<SubscriptionBloc>().add(LoadAvailablePlans());
    context.read<SubscriptionBloc>().add(LoadSubscriptionAnalytics());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Assinatura'),
        backgroundColor: AppTheme.background,
        elevation: 0,
        foregroundColor: AppTheme.textPrimary,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              context.read<SubscriptionBloc>().add(CreateCustomerPortalSession());
            },
            icon: const Icon(Icons.manage_accounts),
            tooltip: 'Gerenciar Assinatura',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Status'),
            Tab(text: 'Planos'),
            Tab(text: 'Histórico'),
          ],
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryColor,
        ),
      ),
      body: BlocListener<SubscriptionBloc, SubscriptionState>(
        listener: (context, state) {
          if (state is SubscriptionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.error,
              ),
            );
          }
          
          if (state is CheckoutSessionCreated) {
            _launchUrl(state.url);
          }
          
          if (state is CustomerPortalSessionCreated) {
            _launchUrl(state.url);
          }
          
          if (state is SubscriptionCancelled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Assinatura cancelada com sucesso'),
                backgroundColor: AppTheme.success,
              ),
            );
            _loadData();
          }
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildStatusTab(),
            _buildPlansTab(),
            _buildHistoryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          BlocBuilder<SubscriptionBloc, SubscriptionState>(
            builder: (context, state) {
              if (state is SubscriptionStatusLoaded) {
                return SubscriptionStatusCard(status: state.status);
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
          const SizedBox(height: 16),
          BlocBuilder<SubscriptionBloc, SubscriptionState>(
            builder: (context, state) {
              if (state is SubscriptionAnalyticsLoaded) {
                return UsageAnalyticsCard(analytics: state.analytics);
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlansTab() {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        if (state is SubscriptionPlansLoaded) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.plans.length,
            itemBuilder: (context, index) {
              final plan = state.plans[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SubscriptionPlanCard(
                  plan: plan,
                  onSelectPlan: (planId) {
                    _showUpgradeDialog(planId);
                  },
                ),
              );
            },
          );
        }
        
        if (state is SubscriptionLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return const Center(
          child: Text('Nenhum plano disponível'),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        if (state is SubscriptionHistoryLoaded) {
          if (state.history.isEmpty) {
            return const Center(
              child: Text('Nenhum histórico de pagamento'),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.history.length,
            itemBuilder: (context, index) {
              final history = state.history[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: BillingHistoryCard(history: history),
              );
            },
          );
        }
        
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  void _showUpgradeDialog(String planId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Atualizar Plano'),
        content: const Text('Deseja atualizar seu plano de assinatura?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<SubscriptionBloc>().add(CreateCheckoutSession(planId: planId));
            },
            child: const Text('Atualizar'),
          ),
        ],
      ),
    );
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir a URL'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }
} 