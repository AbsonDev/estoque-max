import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/convites_bloc.dart';
import '../../data/models/convite_models.dart';

class ConviteEnviarDialog extends StatefulWidget {
  final int despensaId;
  final String despensaNome;

  const ConviteEnviarDialog({
    Key? key,
    required this.despensaId,
    required this.despensaNome,
  }) : super(key: key);

  @override
  State<ConviteEnviarDialog> createState() => _ConviteEnviarDialogState();
}

class _ConviteEnviarDialogState extends State<ConviteEnviarDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _mensagemController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _mensagemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ConvitesBloc, ConvitesState>(
      listener: (context, state) {
        if (state is ConvitesLoading) {
          setState(() {
            _isLoading = true;
          });
        } else {
          setState(() {
            _isLoading = false;
          });

          if (state is ConvitesSuccess) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is ConvitesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
      builder: (context, state) {
        return AlertDialog(
          title: const Text('Convidar Pessoa'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enviar convite para despensa "${widget.despensaNome}"',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Digite o email da pessoa',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Digite um email';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Digite um email válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _mensagemController,
                  decoration: const InputDecoration(
                    labelText: 'Mensagem (opcional)',
                    hintText: 'Digite uma mensagem personalizada',
                    prefixIcon: Icon(Icons.message_outlined),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  maxLength: 200,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      Navigator.of(context).pop();
                    },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _enviarConvite,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  void _enviarConvite() {
    if (_formKey.currentState!.validate()) {
      final request = ConviteRequest(
        email: _emailController.text.trim(),
        mensagem: _mensagemController.text.trim().isNotEmpty
            ? _mensagemController.text.trim()
            : null,
      );

      context.read<ConvitesBloc>().add(
        EnviarConvite(despensaId: widget.despensaId, request: request),
      );
    }
  }

  static void show(BuildContext context, int despensaId, String despensaNome) {
    showDialog(
      context: context,
      builder: (context) => ConviteEnviarDialog(
        despensaId: despensaId,
        despensaNome: despensaNome,
      ),
    );
  }
}
