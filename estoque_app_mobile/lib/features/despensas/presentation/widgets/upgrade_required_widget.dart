import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class UpgradeRequiredWidget extends StatelessWidget {
  final String title;
  final String message;
  final String upgradeMessage;
  final String? currentPlan;
  final int? limit;
  final String? feature;
  final VoidCallback? onUpgrade;
  final VoidCallback? onDismiss;

  const UpgradeRequiredWidget({
    super.key,
    required this.title,
    required this.message,
    required this.upgradeMessage,
    this.currentPlan,
    this.limit,
    this.feature,
    this.onUpgrade,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: isWideScreen ? 500 : double.maxFinite,
        constraints: BoxConstraints(
          maxWidth: isWideScreen ? 500 : MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header com gradiente
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.amber,
                    Colors.orange,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.workspace_premium,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (onDismiss != null)
                        IconButton(
                          onPressed: onDismiss,
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    upgradeMessage,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Conteúdo
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mensagem principal
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textPrimary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Informações do plano atual
                  if (currentPlan != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppTheme.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Plano Atual',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currentPlan!,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          if (limit != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Limite: $limit despensas',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Benefícios do Premium
                  Text(
                    'Benefícios do Plano Premium:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildBenefitItem(
                    icon: Icons.all_inclusive,
                    title: 'Despensas ilimitadas',
                    description: 'Crie quantas despensas precisar',
                  ),
                  const SizedBox(height: 12),
                  _buildBenefitItem(
                    icon: Icons.family_restroom,
                    title: 'Compartilhamento familiar',
                    description: 'Convide familiares e amigos',
                  ),
                  const SizedBox(height: 12),
                  _buildBenefitItem(
                    icon: Icons.analytics,
                    title: 'Analytics avançados',
                    description: 'Relatórios detalhados de consumo',
                  ),
                  const SizedBox(height: 12),
                  _buildBenefitItem(
                    icon: Icons.cloud_sync,
                    title: 'Sincronização em tempo real',
                    description: 'Dados sempre atualizados',
                  ),

                  const SizedBox(height: 32),

                  // Botões de ação
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: onUpgrade,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.workspace_premium, size: 24),
                          label: const Text(
                            'Fazer Upgrade para Premium',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      
                      if (onDismiss != null) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 48,
                          child: TextButton(
                            onPressed: onDismiss,
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Continuar com plano gratuito',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.amber,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Função helper para mostrar o dialog de upgrade
Future<void> showUpgradeRequiredDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String upgradeMessage,
  String? currentPlan,
  int? limit,
  String? feature,
  VoidCallback? onUpgrade,
  VoidCallback? onDismiss,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: onDismiss != null,
    builder: (context) => UpgradeRequiredWidget(
      title: title,
      message: message,
      upgradeMessage: upgradeMessage,
      currentPlan: currentPlan,
      limit: limit,
      feature: feature,
      onUpgrade: onUpgrade,
      onDismiss: onDismiss,
    ),
  );
} 