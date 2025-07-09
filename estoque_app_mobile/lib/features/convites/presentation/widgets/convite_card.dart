import 'package:flutter/material.dart';
import '../../data/models/convite_models.dart';

class ConviteCard extends StatelessWidget {
  final Convite convite;
  final bool isRecebido;
  final VoidCallback? onAceitar;
  final VoidCallback? onRecusar;
  final VoidCallback? onDeletar;

  const ConviteCard({
    Key? key,
    required this.convite,
    required this.isRecebido,
    this.onAceitar,
    this.onRecusar,
    this.onDeletar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              _getStatusColor(convite.status).withOpacity(0.1),
              Colors.transparent,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildContent(),
              if (convite.mensagem != null) ...[
                const SizedBox(height: 8),
                _buildMensagem(),
              ],
              const SizedBox(height: 12),
              _buildFooter(),
              if (isRecebido && convite.isPendente) ...[
                const SizedBox(height: 16),
                _buildActions(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getStatusColor(convite.status).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getStatusIcon(convite.status),
            color: _getStatusColor(convite.status),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                convite.despensaNome,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isRecebido
                    ? 'Convite de ${convite.remetenteNome}'
                    : 'Convite para ${convite.destinatarioEmail}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(convite.status),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getStatusText(convite.status),
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Row(
      children: [
        Icon(Icons.email_outlined, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            isRecebido ? convite.remetenteEmail : convite.destinatarioEmail,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildMensagem() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.message_outlined, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              convite.mensagem!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Icon(Icons.schedule_outlined, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          _formatarData(convite.dataEnvio),
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        if (convite.dataResposta != null) ...[
          const SizedBox(width: 16),
          Icon(Icons.reply_outlined, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            'Respondido: ${_formatarData(convite.dataResposta!)}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
        const Spacer(),
        if (onDeletar != null)
          IconButton(
            icon: Icon(Icons.delete_outline, size: 20, color: Colors.red[400]),
            onPressed: onDeletar,
          ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onAceitar,
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Aceitar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onRecusar,
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Recusar'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.red[400]!),
              foregroundColor: Colors.red[400],
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pendente':
        return Colors.orange;
      case 'aceito':
        return Colors.green;
      case 'recusado':
        return Colors.red;
      case 'expirado':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pendente':
        return Icons.schedule;
      case 'aceito':
        return Icons.check_circle;
      case 'recusado':
        return Icons.cancel;
      case 'expirado':
        return Icons.access_time;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pendente':
        return 'Pendente';
      case 'aceito':
        return 'Aceito';
      case 'recusado':
        return 'Recusado';
      case 'expirado':
        return 'Expirado';
      default:
        return status;
    }
  }

  String _formatarData(DateTime data) {
    final now = DateTime.now();
    final diff = now.difference(data);

    if (diff.inDays > 0) {
      return '${diff.inDays} dia${diff.inDays > 1 ? 's' : ''} atrás';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hora${diff.inHours > 1 ? 's' : ''} atrás';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minuto${diff.inMinutes > 1 ? 's' : ''} atrás';
    } else {
      return 'Agora';
    }
  }
}
