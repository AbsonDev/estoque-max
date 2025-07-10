import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../data/models/estoque_item.dart';
import '../bloc/estoque_bloc.dart';
import '../bloc/estoque_state.dart';
import '../widgets/editar_item_dialog.dart';

class EstoqueItemDetalhesScreen extends StatefulWidget {
  final int itemId;

  const EstoqueItemDetalhesScreen({Key? key, required this.itemId})
    : super(key: key);

  @override
  State<EstoqueItemDetalhesScreen> createState() =>
      _EstoqueItemDetalhesScreenState();
}

class _EstoqueItemDetalhesScreenState extends State<EstoqueItemDetalhesScreen> {
  EstoqueItem? _item;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _carregarItem();
  }

  Future<void> _carregarItem() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Por enquanto, vamos buscar o item da lista atual
      final bloc = context.read<EstoqueBloc>();
      if (bloc.state is EstoqueLoaded) {
        final state = bloc.state as EstoqueLoaded;
        final item = state.items.firstWhere(
          (item) => item.id == widget.itemId,
          orElse: () => throw Exception('Item não encontrado'),
        );
        setState(() {
          _item = item;
          _isLoading = false;
        });
      } else {
        throw Exception('Dados não carregados');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Item'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_item != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _mostrarDialogEdicao(context, _item!),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregarItem,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (_item == null) {
      return const Center(child: Text('Item não encontrado'));
    }

    return _buildDetalhesContent(_item!);
  }

  Widget _buildDetalhesContent(EstoqueItem item) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInformacoesPrincipais(item),
          const SizedBox(height: 24),
          _buildStatusCard(item),
        ],
      ),
    );
  }

  Widget _buildInformacoesPrincipais(EstoqueItem item) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações Principais',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Produto', item.produto),
            _buildInfoRow('Despensa', item.despensaNome),
            _buildInfoRow('Quantidade', item.quantidade.toString()),
            _buildInfoRow(
              'Quantidade Mínima',
              item.quantidadeMinima.toString(),
            ),
            if (item.marca != null) _buildInfoRow('Marca', item.marca!),
            if (item.codigoBarras != null)
              _buildInfoRow('Código de Barras', item.codigoBarras!),
            if (item.dataValidade != null)
              _buildInfoRow(
                'Data de Validade',
                DateFormat('dd/MM/yyyy').format(item.dataValidade!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(EstoqueItem item) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status do Item',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStatusItem('Estoque Baixo', item.isQuantidadeBaixa),
            _buildStatusItem('Em Falta', item.isEmFalta),
            _buildStatusItem('Vencido', item.isVencido),
            _buildStatusItem('Vencendo em 7 dias', item.isVencendoEm7Dias),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, bool status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            status ? Icons.warning : Icons.check_circle,
            color: status ? Colors.orange : Colors.green,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(label),
          const Spacer(),
          Text(
            status ? 'Sim' : 'Não',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: status ? Colors.orange : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _mostrarDialogEdicao(BuildContext context, EstoqueItem item) {
    showDialog(
      context: context,
      builder: (context) => EditarItemDialog(
        item: item,
        onItemEditado: () {
          // Recarrega os detalhes após edição
          _carregarItem();
        },
      ),
    );
  }
}
