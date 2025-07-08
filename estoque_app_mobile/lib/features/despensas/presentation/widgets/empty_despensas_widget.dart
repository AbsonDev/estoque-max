import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class EmptyDespensasWidget extends StatelessWidget {
  final VoidCallback? onCreateDespensa;
  final bool isLoading;

  const EmptyDespensasWidget({
    super.key,
    this.onCreateDespensa,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;
    
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isWideScreen ? 500 : double.infinity,
        ),
        padding: EdgeInsets.all(isWideScreen ? 40 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ilustração
            Container(
              width: isWideScreen ? 200 : 150,
              height: isWideScreen ? 200 : 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.1),
                    AppTheme.primaryVariant.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(isWideScreen ? 100 : 75),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.home_work_outlined,
                size: isWideScreen ? 80 : 60,
                color: AppTheme.primaryColor.withValues(alpha: 0.6),
              ),
            ),

            SizedBox(height: isWideScreen ? 40 : 32),

            // Título
            Text(
              'Nenhuma despensa encontrada',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                fontSize: isWideScreen ? 28 : 24,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: isWideScreen ? 16 : 12),

            // Descrição
            Text(
              'Comece criando sua primeira despensa para organizar os itens da sua casa',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
                height: 1.5,
                fontSize: isWideScreen ? 18 : 16,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: isWideScreen ? 40 : 32),

            // Benefícios/Features
            if (isWideScreen) ...[
              _buildFeaturesList(),
              const SizedBox(height: 40),
            ],

            // Botão de ação
            SizedBox(
              width: isWideScreen ? 300 : double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : onCreateDespensa,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: AppTheme.primaryColor.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.add_business_outlined, size: 24),
                label: Text(
                  isLoading ? 'Criando...' : 'Criar Primeira Despensa',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            // Features para mobile
            if (!isWideScreen) ...[
              const SizedBox(height: 32),
              _buildFeaturesList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    return Column(
      children: [
        _buildFeatureItem(
          icon: Icons.inventory_2_outlined,
          title: 'Organize por locais',
          description: 'Separe itens por cômodos ou áreas da casa',
          color: Colors.blue,
        ),
        const SizedBox(height: 16),
        _buildFeatureItem(
          icon: Icons.family_restroom_outlined,
          title: 'Compartilhe com a família',
          description: 'Convide familiares para colaborar',
          color: Colors.green,
        ),
        const SizedBox(height: 16),
        _buildFeatureItem(
          icon: Icons.analytics_outlined,
          title: 'Acompanhe o consumo',
          description: 'Veja estatísticas e previsões inteligentes',
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 