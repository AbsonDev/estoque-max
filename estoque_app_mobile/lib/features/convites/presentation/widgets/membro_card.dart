import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/models/convite_models.dart';

class MembroCard extends StatelessWidget {
  final MembroDespensa membro;
  final VoidCallback? onRemover;
  final Function(String)? onAlterarRole;

  const MembroCard({
    Key? key,
    required this.membro,
    this.onRemover,
    this.onAlterarRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: membro.isAdmin ? Colors.blue : Colors.grey,
                  child: Text(
                    membro.nome.isNotEmpty ? membro.nome[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        membro.nome,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        membro.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildRoleChip(),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.schedule_outlined,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'Membro desde ${_formatarData(membro.dataJuntou)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                if (onAlterarRole != null)
                  _buildRoleButton(context),
                if (onRemover != null && !membro.isAdmin)
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline,
                      size: 20,
                      color: Colors.red[400],
                    ),
                    onPressed: onRemover,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: membro.isAdmin ? Colors.blue : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        membro.isAdmin ? 'Admin' : 'Membro',
        style: TextStyle(
          fontSize: 10,
          color: membro.isAdmin ? Colors.white : Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRoleButton(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        size: 20,
        color: Colors.grey[600],
      ),
      onSelected: (value) {
        if (value == 'toggle_admin') {
          final novoRole = membro.isAdmin ? 'member' : 'admin';
          onAlterarRole?.call(novoRole);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'toggle_admin',
          child: Row(
            children: [
              Icon(
                membro.isAdmin ? Icons.remove_moderator : Icons.admin_panel_settings,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(membro.isAdmin ? 'Remover Admin' : 'Tornar Admin'),
            ],
          ),
        ),
      ],
    );
  }

  String _formatarData(DateTime data) {
    final now = DateTime.now();
    final diff = now.difference(data);

    if (diff.inDays > 30) {
      final months = (diff.inDays / 30).floor();
      return '${months} mês${months > 1 ? 'es' : ''} atrás';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} dia${diff.inDays > 1 ? 's' : ''} atrás';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hora${diff.inHours > 1 ? 's' : ''} atrás';
    } else {
      return 'Hoje';
    }
  }
} 