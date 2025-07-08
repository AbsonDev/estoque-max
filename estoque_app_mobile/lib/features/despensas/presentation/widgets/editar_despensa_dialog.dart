import 'package:flutter/material.dart';
import '../../data/models/despensa.dart';
import '../../data/models/despensa_dto.dart';
import '../../../../core/theme/app_theme.dart';

Future<void> showEditarDespensaDialog({
  required BuildContext context,
  required Despensa despensa,
  required Function(CriarDespensaDto) onSubmit,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return EditarDespensaDialog(
        despensa: despensa,
        onSubmit: onSubmit,
      );
    },
  );
}

class EditarDespensaDialog extends StatefulWidget {
  final Despensa despensa;
  final Function(CriarDespensaDto) onSubmit;

  const EditarDespensaDialog({
    Key? key,
    required this.despensa,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<EditarDespensaDialog> createState() => _EditarDespensaDialogState();
}

class _EditarDespensaDialogState extends State<EditarDespensaDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _descricaoController;
  String? _tipoSelecionado;
  bool _isLoading = false;

  // Tipos de despensa disponíveis
  final List<String> _tiposDisponiveis = [
    'Cozinha',
    'Despensa',
    'Geladeira',
    'Freezer',
    'Armário',
    'Quarto',
    'Banheiro',
    'Escritório',
    'Garagem',
    'Outro',
  ];

  @override
  void initState() {
    super.initState();
    // Pré-preenche os campos com os dados da despensa
    _nomeController = TextEditingController(text: widget.despensa.nome);
    _descricaoController = TextEditingController(text: '');
    _tipoSelecionado = 'Outro';
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  void _salvarDespensa() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final dto = CriarDespensaDto(
        nome: _nomeController.text.trim(),
      );

      widget.onSubmit(dto);

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.edit_outlined,
            color: AppTheme.primaryColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Text(
            'Editar Despensa',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Campo Nome
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome da Despensa',
                    hintText: 'Ex: Cozinha Principal',
                    prefixIcon: Icon(Icons.label_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Nome é obrigatório';
                    }
                    if (value!.trim().length < 2) {
                      return 'Nome deve ter pelo menos 2 caracteres';
                    }
                    if (value.trim().length > 50) {
                      return 'Nome deve ter no máximo 50 caracteres';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                ),
                
                const SizedBox(height: 16),
                
                // Campo Tipo
                DropdownButtonFormField<String>(
                  value: _tipoSelecionado,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    prefixIcon: Icon(Icons.category_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: _tiposDisponiveis.map((tipo) {
                    return DropdownMenuItem(
                      value: tipo,
                      child: Text(tipo),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _tipoSelecionado = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Tipo é obrigatório';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Campo Descrição
                TextFormField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição (opcional)',
                    hintText: 'Ex: Local para armazenar ingredientes',
                    prefixIcon: Icon(Icons.description_outlined),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value != null && value.trim().length > 200) {
                      return 'Descrição deve ter no máximo 200 caracteres';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.sentences,
                ),
                
                const SizedBox(height: 16),
                
                // Informações adicionais
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Informações da Despensa',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Criada em: ${_formatarData(widget.despensa.dataCriacao)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (widget.despensa.membros.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Membros: ${widget.despensa.membros.length}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      if (widget.despensa.itens?.isNotEmpty ?? false) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Itens: ${widget.despensa.itens!.length}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _salvarDespensa,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Salvar Alterações'),
        ),
      ],
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }
} 