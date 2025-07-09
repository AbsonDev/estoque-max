import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../bloc/subscription_bloc.dart';
import '../screens/subscription_screen.dart';
import '../../data/models/subscription_models.dart';

class PaywallWidget extends StatelessWidget {
  final String feature;
  final Widget child;
  final bool enabled;

  const PaywallWidget({
    Key? key,
    required this.feature,
    required this.child,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }

    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        if (state is SubscriptionLoaded) {
          final featureAccess = state.featureAccess;

          if (_hasFeatureAccess(featureAccess)) {
            return child;
          } else {
            return _buildPaywallOverlay(context);
          }
        }

        return child;
      },
    );
  }

  bool _hasFeatureAccess(FeatureAccess featureAccess) {
    switch (feature) {
      case 'analytics':
        return featureAccess.hasAnalytics;
      case 'ai_predictions':
        return featureAccess.hasAIPredictions;
      case 'export':
        return featureAccess.hasExport;
      case 'scanner':
        return featureAccess.hasScanner;
      case 'advanced_filters':
        return featureAccess.hasAdvancedFilters;
      case 'custom_categories':
        return false; // Feature not implemented
      case 'priority_support':
        return false; // Feature not implemented
      default:
        return false;
    }
  }

  Widget _buildPaywallOverlay(BuildContext context) {
    return Stack(
      children: [
        // Conteúdo original desfocado
        Opacity(opacity: 0.3, child: AbsorbPointer(child: child)),
        // Overlay do paywall
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildPaywallContent(context),
          ),
        ),
      ],
    );
  }

  Widget _buildPaywallContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.amber,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.lock_outline, size: 40, color: Colors.white),
        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
        const SizedBox(height: 16),
        Text(
          'Funcionalidade Premium',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
        const SizedBox(height: 8),
        Text(
          _getFeatureDescription(),
          style: TextStyle(color: Colors.white70, fontSize: 14),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
        const SizedBox(height: 20),
        ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SubscriptionScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Fazer Upgrade',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
            .animate()
            .fadeIn(delay: 600.ms, duration: 600.ms)
            .slideY(begin: 0.3, curve: Curves.easeOutCubic),
      ],
    );
  }

  String _getFeatureDescription() {
    switch (feature) {
      case 'analytics':
        return 'Acesse análises detalhadas dos seus hábitos de consumo';
      case 'ai_predictions':
        return 'Previsões inteligentes baseadas em IA';
      case 'export':
        return 'Exporte seus dados para outros aplicativos';
      case 'scanner':
        return 'Escaneie códigos de barras para adicionar produtos';
      case 'advanced_filters':
        return 'Use filtros avançados para organizar melhor';
      case 'custom_categories':
        return 'Crie categorias personalizadas para seus produtos';
      case 'priority_support':
        return 'Suporte prioritário para resolver problemas rapidamente';
      default:
        return 'Esta funcionalidade está disponível apenas no plano Premium';
    }
  }
}

// Widget para botão com paywall
class PaywallButton extends StatelessWidget {
  final String feature;
  final VoidCallback onPressed;
  final Widget child;
  final bool enabled;

  const PaywallButton({
    Key? key,
    required this.feature,
    required this.onPressed,
    required this.child,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return ElevatedButton(onPressed: onPressed, child: child);
    }

    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        if (state is SubscriptionLoaded) {
          final featureAccess = state.featureAccess;

          if (_hasFeatureAccess(featureAccess)) {
            return ElevatedButton(onPressed: onPressed, child: child);
          } else {
            return ElevatedButton(
              onPressed: () => _showPaywallDialog(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline, size: 16),
                  const SizedBox(width: 8),
                  child,
                ],
              ),
            );
          }
        }

        return ElevatedButton(onPressed: onPressed, child: child);
      },
    );
  }

  bool _hasFeatureAccess(FeatureAccess featureAccess) {
    switch (feature) {
      case 'analytics':
        return featureAccess.hasAnalytics;
      case 'ai_predictions':
        return featureAccess.hasAIPredictions;
      case 'export':
        return featureAccess.hasExport;
      case 'scanner':
        return featureAccess.hasScanner;
      case 'advanced_filters':
        return featureAccess.hasAdvancedFilters;
      case 'custom_categories':
        return false; // Feature not implemented
      case 'priority_support':
        return false; // Feature not implemented
      default:
        return false;
    }
  }

  void _showPaywallDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Funcionalidade Premium'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 48, color: Colors.amber),
            const SizedBox(height: 16),
            Text(_getFeatureDescription(), textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SubscriptionScreen(),
                ),
              );
            },
            child: const Text('Fazer Upgrade'),
          ),
        ],
      ),
    );
  }

  String _getFeatureDescription() {
    switch (feature) {
      case 'analytics':
        return 'Acesse análises detalhadas dos seus hábitos de consumo';
      case 'ai_predictions':
        return 'Previsões inteligentes baseadas em IA';
      case 'export':
        return 'Exporte seus dados para outros aplicativos';
      case 'scanner':
        return 'Escaneie códigos de barras para adicionar produtos';
      case 'advanced_filters':
        return 'Use filtros avançados para organizar melhor';
      case 'custom_categories':
        return 'Crie categorias personalizadas para seus produtos';
      case 'priority_support':
        return 'Suporte prioritário para resolver problemas rapidamente';
      default:
        return 'Esta funcionalidade está disponível apenas no plano Premium';
    }
  }
}

// Widget para mostrar limites de uso
class UsageLimitWidget extends StatelessWidget {
  final String type;
  final int used;
  final int max;
  final String label;
  final VoidCallback? onUpgradePressed;

  const UsageLimitWidget({
    Key? key,
    required this.type,
    required this.used,
    required this.max,
    required this.label,
    this.onUpgradePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUnlimited = max == -1;
    final percentage = isUnlimited ? 0.0 : (used / max).clamp(0.0, 1.0);
    final isNearLimit = percentage > 0.8;
    final isAtLimit = percentage >= 1.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isUnlimited)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Ilimitado',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (!isUnlimited) ...[
              Text(
                '$used de $max',
                style: TextStyle(
                  fontSize: 14,
                  color: isAtLimit ? Colors.red : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  isAtLimit
                      ? Colors.red
                      : isNearLimit
                      ? Colors.orange
                      : Colors.blue,
                ),
              ),
              if (isNearLimit && onUpgradePressed != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onUpgradePressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                    ),
                    child: Text(
                      isAtLimit
                          ? 'Limite Atingido - Upgrade'
                          : 'Quase no Limite - Upgrade',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
