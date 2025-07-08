import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/despensa_dto.dart';

class CriarDespensaDialog extends StatefulWidget {
  final Function(CriarDespensaDto) onSubmit;
  final bool isLoading;

  const CriarDespensaDialog({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<CriarDespensaDialog> createState() => _CriarDespensaDialogState();
}

class _CriarDespensaDialogState extends State<CriarDespensaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Focar automaticamente no campo quando o modal abrir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate() && !widget.isLoading) {
      final dto = CriarDespensaDto(nome: _nomeController.text.trim());
      widget.onSubmit(dto);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: isWideScreen ? 400 : double.maxFinite,
        constraints: BoxConstraints(
          maxWidth: isWideScreen ? 400 : MediaQuery.of(context).size.width * 0.9,
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
                    AppTheme.primaryColor,
                    AppTheme.primaryVariant,
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
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.add_business_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Nova Despensa',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (!widget.isLoading)
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Organize seus itens em diferentes locais da sua casa',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Conteúdo do formulário
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Campo de nome
                    TextFormField(
                      controller: _nomeController,
                      focusNode: _focusNode,
                      enabled: !widget.isLoading,
                      decoration: InputDecoration(
                        labelText: 'Nome da Despensa',
                        hintText: 'Ex: Cozinha, Casa de Banho, Escritório',
                        prefixIcon: Icon(
                          Icons.home_outlined,
                          color: AppTheme.primaryColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.divider,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, digite o nome da despensa';
                        }
                        if (value.trim().length < 2) {
                          return 'O nome deve ter pelo menos 2 caracteres';
                        }
                        if (value.trim().length > 50) {
                          return 'O nome deve ter no máximo 50 caracteres';
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.words,
                      onFieldSubmitted: (_) => _submit(),
                    ),

                    const SizedBox(height: 24),

                    // Sugestões rápidas
                    if (!widget.isLoading) ...[
                      Text(
                        'Sugestões rápidas:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildSuggestionChip('Cozinha', Icons.kitchen_outlined),
                          _buildSuggestionChip('Casa de Banho', Icons.bathtub_outlined),
                          _buildSuggestionChip('Escritório', Icons.business_center_outlined),
                          _buildSuggestionChip('Quarto', Icons.bed_outlined),
                          _buildSuggestionChip('Garagem', Icons.garage_outlined),
                          _buildSuggestionChip('Lavandaria', Icons.local_laundry_service_outlined),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Botões de ação
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: widget.isLoading
                                ? null
                                : () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: AppTheme.divider),
                            ),
                            child: Text(
                              'Cancelar',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: widget.isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: widget.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Criar Despensa',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String label, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      onPressed: () {
        _nomeController.text = label;
        _focusNode.requestFocus();
        // Posiciona o cursor no final do texto
        _nomeController.selection = TextSelection.fromPosition(
          TextPosition(offset: _nomeController.text.length),
        );
      },
      backgroundColor: AppTheme.surface,
      labelStyle: TextStyle(
        color: AppTheme.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      side: BorderSide(
        color: AppTheme.divider,
      ),
    );
  }
}

/// Função helper para mostrar o dialog
Future<void> showCriarDespensaDialog({
  required BuildContext context,
  required Function(CriarDespensaDto) onSubmit,
  bool isLoading = false,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: !isLoading,
    builder: (context) => CriarDespensaDialog(
      onSubmit: onSubmit,
      isLoading: isLoading,
    ),
  );
} 