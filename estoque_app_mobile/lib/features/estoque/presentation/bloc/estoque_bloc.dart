import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/estoque_service.dart';
import '../../data/models/estoque_item.dart';
import '../../data/models/produto.dart';
import 'estoque_event.dart';
import 'estoque_state.dart';

class EstoqueBloc extends Bloc<EstoqueEvent, EstoqueState> {
  final EstoqueService _estoqueService;

  EstoqueBloc(this._estoqueService) : super(EstoqueInitial()) {
    on<CarregarEstoque>(_onCarregarEstoque);
    on<AdicionarItemEstoque>(_onAdicionarItemEstoque);
    on<AtualizarItemEstoque>(_onAtualizarItemEstoque);
    on<ConsumirItemEstoque>(_onConsumirItemEstoque);
    on<RemoverItemEstoque>(_onRemoverItemEstoque);
    on<FiltrarEstoque>(_onFiltrarEstoque);
    on<CarregarProdutos>(_onCarregarProdutos);
    on<CriarProduto>(_onCriarProduto);
    on<AtualizarProduto>(_onAtualizarProduto);
    on<DeletarProduto>(_onDeletarProduto);
    on<BuscarProdutoPorCodigoBarras>(_onBuscarProdutoPorCodigoBarras);
    on<LimparProdutoEncontrado>(_onLimparProdutoEncontrado);
    on<LimparErroEstoque>(_onLimparErroEstoque);
  }

  Future<void> _onCarregarEstoque(
    CarregarEstoque event,
    Emitter<EstoqueState> emit,
  ) async {
    try {
      emit(EstoqueLoading());
      
      final itens = await _estoqueService.getEstoque(despensaId: event.despensaId);
      final produtos = await _estoqueService.getProdutos();
      
      emit(EstoqueLoaded(
        itens: itens,
        itensFiltrados: itens,
        produtos: produtos,
        despensaIdAtual: event.despensaId,
      ));
    } catch (e) {
      emit(EstoqueError(e.toString()));
    }
  }

  Future<void> _onAdicionarItemEstoque(
    AdicionarItemEstoque event,
    Emitter<EstoqueState> emit,
  ) async {
    try {
      emit(const EstoqueOperationLoading('Adicionando item...'));
      
      await _estoqueService.adicionarAoEstoque(event.dto);
      
      emit(const EstoqueOperationSuccess('Item adicionado com sucesso!'));
      
      // Recarregar estoque
      final currentState = state;
      if (currentState is EstoqueLoaded) {
        add(CarregarEstoque(despensaId: currentState.despensaIdAtual));
      }
    } catch (e) {
      emit(EstoqueError(e.toString()));
    }
  }

  Future<void> _onAtualizarItemEstoque(
    AtualizarItemEstoque event,
    Emitter<EstoqueState> emit,
  ) async {
    try {
      emit(const EstoqueOperationLoading('Atualizando item...'));
      
      await _estoqueService.atualizarEstoque(event.id, event.dto);
      
      emit(const EstoqueOperationSuccess('Item atualizado com sucesso!'));
      
      // Recarregar estoque
      final currentState = state;
      if (currentState is EstoqueLoaded) {
        add(CarregarEstoque(despensaId: currentState.despensaIdAtual));
      }
    } catch (e) {
      emit(EstoqueError(e.toString()));
    }
  }

  Future<void> _onConsumirItemEstoque(
    ConsumirItemEstoque event,
    Emitter<EstoqueState> emit,
  ) async {
    try {
      emit(const EstoqueOperationLoading('Consumindo item...'));
      
      await _estoqueService.consumirEstoque(event.id, event.dto);
      
      emit(const EstoqueOperationSuccess('Consumo registrado com sucesso!'));
      
      // Recarregar estoque
      final currentState = state;
      if (currentState is EstoqueLoaded) {
        add(CarregarEstoque(despensaId: currentState.despensaIdAtual));
      }
    } catch (e) {
      emit(EstoqueError(e.toString()));
    }
  }

  Future<void> _onRemoverItemEstoque(
    RemoverItemEstoque event,
    Emitter<EstoqueState> emit,
  ) async {
    try {
      emit(const EstoqueOperationLoading('Removendo item...'));
      
      await _estoqueService.removerDoEstoque(event.id);
      
      emit(const EstoqueOperationSuccess('Item removido com sucesso!'));
      
      // Recarregar estoque
      final currentState = state;
      if (currentState is EstoqueLoaded) {
        add(CarregarEstoque(despensaId: currentState.despensaIdAtual));
      }
    } catch (e) {
      emit(EstoqueError(e.toString()));
    }
  }

  void _onFiltrarEstoque(
    FiltrarEstoque event,
    Emitter<EstoqueState> emit,
  ) {
    final currentState = state;
    if (currentState is EstoqueLoaded) {
      List<EstoqueItem> itensFiltrados = List.from(currentState.itens);

      // Aplicar filtro de texto
      if (event.filtro != null && event.filtro!.isNotEmpty) {
        itensFiltrados = itensFiltrados.where((item) =>
          item.produtoNome.toLowerCase().contains(event.filtro!.toLowerCase()) ||
          (item.produtoMarca?.toLowerCase().contains(event.filtro!.toLowerCase()) ?? false) ||
          item.despensaNome.toLowerCase().contains(event.filtro!.toLowerCase())
        ).toList();
      }

      // Aplicar filtro de vencidos
      if (event.apenasVencidos ?? false) {
        itensFiltrados = itensFiltrados.where((item) => item.estaVencido).toList();
      }

      // Aplicar filtro de baixo estoque
      if (event.apenasBaixoEstoque ?? false) {
        itensFiltrados = itensFiltrados.where((item) => item.precisaRepor).toList();
      }

      emit(currentState.copyWith(
        itensFiltrados: itensFiltrados,
        filtroAtual: event.filtro,
        apenasVencidos: event.apenasVencidos ?? currentState.apenasVencidos,
        apenasBaixoEstoque: event.apenasBaixoEstoque ?? currentState.apenasBaixoEstoque,
      ));
    }
  }

  Future<void> _onCarregarProdutos(
    CarregarProdutos event,
    Emitter<EstoqueState> emit,
  ) async {
    try {
      final produtos = await _estoqueService.getProdutos(busca: event.busca);
      
      final currentState = state;
      if (currentState is EstoqueLoaded) {
        emit(currentState.copyWith(produtos: produtos));
      }
    } catch (e) {
      emit(EstoqueError(e.toString()));
    }
  }

  Future<void> _onCriarProduto(
    CriarProduto event,
    Emitter<EstoqueState> emit,
  ) async {
    try {
      emit(const EstoqueOperationLoading('Criando produto...'));
      
      final produto = await _estoqueService.criarProduto(event.dto);
      
      emit(const EstoqueOperationSuccess('Produto criado com sucesso!'));
      
      // Recarregar produtos
      final currentState = state;
      if (currentState is EstoqueLoaded) {
        final produtosAtualizados = List<Produto>.from(currentState.produtos);
        produtosAtualizados.add(produto);
        emit(currentState.copyWith(produtos: produtosAtualizados));
      }
    } catch (e) {
      emit(EstoqueError(e.toString()));
    }
  }

  Future<void> _onAtualizarProduto(
    AtualizarProduto event,
    Emitter<EstoqueState> emit,
  ) async {
    try {
      emit(const EstoqueOperationLoading('Atualizando produto...'));
      
      final produto = await _estoqueService.atualizarProduto(event.id, event.dto);
      
      emit(const EstoqueOperationSuccess('Produto atualizado com sucesso!'));
      
      // Atualizar lista de produtos
      final currentState = state;
      if (currentState is EstoqueLoaded) {
        final produtosAtualizados = currentState.produtos.map((p) => 
          p.id == event.id ? produto : p
        ).toList();
        emit(currentState.copyWith(produtos: produtosAtualizados));
      }
    } catch (e) {
      emit(EstoqueError(e.toString()));
    }
  }

  Future<void> _onDeletarProduto(
    DeletarProduto event,
    Emitter<EstoqueState> emit,
  ) async {
    try {
      emit(const EstoqueOperationLoading('Deletando produto...'));
      
      await _estoqueService.deletarProduto(event.id);
      
      emit(const EstoqueOperationSuccess('Produto deletado com sucesso!'));
      
      // Remover da lista de produtos
      final currentState = state;
      if (currentState is EstoqueLoaded) {
        final produtosAtualizados = currentState.produtos.where((p) => p.id != event.id).toList();
        emit(currentState.copyWith(produtos: produtosAtualizados));
      }
    } catch (e) {
      emit(EstoqueError(e.toString()));
    }
  }

  Future<void> _onBuscarProdutoPorCodigoBarras(
    BuscarProdutoPorCodigoBarras event,
    Emitter<EstoqueState> emit,
  ) async {
    try {
      final produto = await _estoqueService.buscarProdutoPorCodigoBarras(event.codigoBarras);
      
      final currentState = state;
      if (currentState is EstoqueLoaded) {
        emit(currentState.copyWith(produtoEncontrado: produto));
      }
    } catch (e) {
      emit(EstoqueError(e.toString()));
    }
  }

  void _onLimparProdutoEncontrado(
    LimparProdutoEncontrado event,
    Emitter<EstoqueState> emit,
  ) {
    final currentState = state;
    if (currentState is EstoqueLoaded) {
      emit(currentState.copyWith(clearProdutoEncontrado: true));
    }
  }

  void _onLimparErroEstoque(
    LimparErroEstoque event,
    Emitter<EstoqueState> emit,
  ) {
    final currentState = state;
    if (currentState is EstoqueLoaded) {
      // Mantém o estado atual se for loaded
      emit(currentState);
    } else {
      emit(EstoqueInitial());
    }
  }
} 