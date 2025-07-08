import 'package:signalr_netcore/signalr_client.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

class SignalRService {
  static const String hubUrl = 'http://localhost:5265/estoqueHub';
  
  final ApiService _apiService;
  HubConnection? _hubConnection;
  bool _isConnected = false;

  // Callbacks para eventos
  Function(Map<String, dynamic>)? onEstoqueItemAtualizado;
  Function(Map<String, dynamic>)? onListaDeComprasAtualizada;
  Function(Map<String, dynamic>)? onNovoConviteRecebido;
  Function(Map<String, dynamic>)? onPrevisaoAtualizada;
  Function(Map<String, dynamic>)? onDespensaAtualizada;
  Function(Map<String, dynamic>)? onMembroAdicionado;
  Function(Map<String, dynamic>)? onMembroRemovido;

  SignalRService(this._apiService);

  Future<void> connect() async {
    if (_isConnected) return;

    try {
      final token = await _apiService.getToken();
      if (token == null) {
        throw Exception('Token não encontrado');
      }

      _hubConnection = HubConnectionBuilder()
          .withUrl(hubUrl, options: HttpConnectionOptions(
            accessTokenFactory: () => Future.value(token),
          ))
          .build();

      // Configura os event handlers
      _setupEventHandlers();

      // Conecta ao hub
      await _hubConnection!.start();
      _isConnected = true;

      debugPrint('SignalR conectado com sucesso');
    } catch (e) {
      debugPrint('Erro ao conectar SignalR: $e');
      throw Exception('Erro ao conectar SignalR: $e');
    }
  }

  Future<void> disconnect() async {
    if (!_isConnected || _hubConnection == null) return;

    try {
      await _hubConnection!.stop();
      _isConnected = false;
      debugPrint('SignalR desconectado');
    } catch (e) {
      debugPrint('Erro ao desconectar SignalR: $e');
    }
  }

  void _setupEventHandlers() {
    if (_hubConnection == null) return;

    // Evento: EstoqueItemAtualizado
    _hubConnection!.on('EstoqueItemAtualizado', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final data = arguments[0] as Map<String, dynamic>;
        onEstoqueItemAtualizado?.call(data);
        debugPrint('EstoqueItemAtualizado: $data');
      }
    });

    // Evento: ListaDeComprasAtualizada
    _hubConnection!.on('ListaDeComprasAtualizada', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final data = arguments[0] as Map<String, dynamic>;
        onListaDeComprasAtualizada?.call(data);
        debugPrint('ListaDeComprasAtualizada: $data');
      }
    });

    // Evento: NovoConviteRecebido
    _hubConnection!.on('NovoConviteRecebido', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final data = arguments[0] as Map<String, dynamic>;
        onNovoConviteRecebido?.call(data);
        debugPrint('NovoConviteRecebido: $data');
      }
    });

    // Evento: PrevisaoAtualizada
    _hubConnection!.on('PrevisaoAtualizada', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final data = arguments[0] as Map<String, dynamic>;
        onPrevisaoAtualizada?.call(data);
        debugPrint('PrevisaoAtualizada: $data');
      }
    });

    // Evento: DespensaAtualizada
    _hubConnection!.on('DespensaAtualizada', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final data = arguments[0] as Map<String, dynamic>;
        onDespensaAtualizada?.call(data);
        debugPrint('DespensaAtualizada: $data');
      }
    });

    // Evento: MembroAdicionado
    _hubConnection!.on('MembroAdicionado', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final data = arguments[0] as Map<String, dynamic>;
        onMembroAdicionado?.call(data);
        debugPrint('MembroAdicionado: $data');
      }
    });

    // Evento: MembroRemovido
    _hubConnection!.on('MembroRemovido', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final data = arguments[0] as Map<String, dynamic>;
        onMembroRemovido?.call(data);
        debugPrint('MembroRemovido: $data');
      }
    });
  }

  // Junta ao grupo de uma despensa específica
  Future<void> juntarAoGrupoDespensa(int despensaId) async {
    if (!_isConnected || _hubConnection == null) {
      await connect();
    }

    try {
      await _hubConnection!.invoke('JuntarAoGrupoDespensa', args: [despensaId]);
      debugPrint('Juntou ao grupo da despensa: $despensaId');
    } catch (e) {
      debugPrint('Erro ao juntar ao grupo da despensa: $e');
      throw Exception('Erro ao juntar ao grupo da despensa: $e');
    }
  }

  // Sai do grupo de uma despensa específica
  Future<void> sairDoGrupoDespensa(int despensaId) async {
    if (!_isConnected || _hubConnection == null) return;

    try {
      await _hubConnection!.invoke('SairDoGrupoDespensa', args: [despensaId]);
      debugPrint('Saiu do grupo da despensa: $despensaId');
    } catch (e) {
      debugPrint('Erro ao sair do grupo da despensa: $e');
    }
  }

  // Verifica se está conectado
  bool get isConnected => _isConnected;

  // Reconecta se necessário
  Future<void> ensureConnected() async {
    if (!_isConnected) {
      await connect();
    }
  }
} 