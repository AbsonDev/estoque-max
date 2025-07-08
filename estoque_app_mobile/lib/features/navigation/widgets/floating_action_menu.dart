import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class FloatingActionMenu extends StatelessWidget {
  final AnimationController animationController;
  final VoidCallback onClose;

  const FloatingActionMenu({
    super.key,
    required this.animationController,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background overlay
        GestureDetector(
          onTap: onClose,
          child: Container(
            color: Colors.black.withOpacity(0.5),
            child: const SizedBox.expand(),
          ),
        ),
        
        // Menu items
        Positioned(
          bottom: 140,
          right: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMenuItem(
                context,
                icon: Icons.add_shopping_cart,
                label: 'Adicionar à Lista',
                color: AppTheme.warning,
                onTap: () {
                  onClose();
                  // Navigate to add to shopping list
                  _showAddToShoppingListDialog(context);
                },
              ),
              const SizedBox(height: 16),
              _buildMenuItem(
                context,
                icon: Icons.inventory_2,
                label: 'Adicionar ao Estoque',
                color: AppTheme.secondary,
                onTap: () {
                  onClose();
                  // Navigate to add to inventory
                  _showAddToInventoryDialog(context);
                },
              ),
              const SizedBox(height: 16),
              _buildMenuItem(
                context,
                icon: Icons.store,
                label: 'Nova Despensa',
                color: AppTheme.primaryColor,
                onTap: () {
                  onClose();
                  // Navigate to create new pantry
                  _showCreateDespensaDialog(context);
                },
              ),
              const SizedBox(height: 16),
              _buildMenuItem(
                context,
                icon: Icons.scanner,
                label: 'Escanear QR',
                color: AppTheme.success,
                onTap: () {
                  onClose();
                  // Navigate to QR scanner
                  _showQRScannerDialog(context);
                },
              ),
            ],
          ).animate().scale(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddToShoppingListDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar à Lista'),
        content: const Text('Funcionalidade de adicionar à lista de compras será implementada aqui.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showAddToInventoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar ao Estoque'),
        content: const Text('Funcionalidade de adicionar ao estoque será implementada aqui.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showCreateDespensaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Despensa'),
        content: const Text('Funcionalidade de criar nova despensa será implementada aqui.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showQRScannerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escanear QR'),
        content: const Text('Funcionalidade de scanner QR será implementada aqui.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
} 