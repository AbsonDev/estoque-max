import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../despensas/data/models/despensa.dart';

class DespensaSelector extends StatelessWidget {
  final List<Despensa> despensas;
  final Despensa? selectedDespensa;
  final Function(Despensa?) onDespensaChanged;
  final String? label;

  const DespensaSelector({
    super.key,
    required this.despensas,
    this.selectedDespensa,
    required this.onDespensaChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Despensa>(
      value: selectedDespensa,
      decoration: InputDecoration(
        labelText: label ?? 'Despensa',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.store),
      ),
      items: despensas.map((despensa) {
        return DropdownMenuItem(
          value: despensa,
          child: Row(
            children: [
              // Ícone da despensa
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.store,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              
              // Informações da despensa
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      despensa.nome,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2,
                          size: 12,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${despensa.totalItens} itens',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.people,
                          size: 12,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${despensa.totalMembros} membros',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Badge do papel do usuário
              if (despensa.sounDono)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Dono',
                    style: TextStyle(
                      color: Colors.amber.shade700,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
      onChanged: onDespensaChanged,
      validator: (value) {
        if (value == null) {
          return 'Selecione uma despensa';
        }
        return null;
      },
      isExpanded: true,
      menuMaxHeight: 300,
    );
  }
}