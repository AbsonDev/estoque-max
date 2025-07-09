import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
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

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with SingleTickerProviderStateMixin {
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
    // Load data when available
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
              // Manage subscription when available
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
        },
        child: TabBarView(
          controller: _tabController,
          children: [_buildStatusTab(), _buildPlansTab(), _buildHistoryTab()],
        ),
      ),
    );
  }

  Widget _buildStatusTab() {
    return const Center(child: Text('Status da assinatura'));
  }

  Widget _buildPlansTab() {
    return const Center(child: Text('Planos disponíveis'));
  }

  Widget _buildHistoryTab() {
    return const Center(child: Text('Histórico de pagamentos'));
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
              // Upgrade plan when available
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
