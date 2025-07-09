import 'package:signalr_netcore/signalr_client.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'api_service.dart';

class SignalRService {
  static const String hubUrl =
      'https://estoquemaxapi-acfwdye6g0bbdwb5.brazilsouth-01.azurewebsites.net/estoqueHub';

  final ApiService _apiService;
  HubConnection? _hubConnection;
  bool _isConnected = false;
  bool _isConnecting = false;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 5;

  // Callbacks para eventos usando listas para múltiplos listeners
  final List<Function(Map<String, dynamic>)> _onEstoqueItemAtualizado = [];
  final List<Function(Map<String, dynamic>)> _onListaDeComprasAtualizada = [];
  final List<Function(Map<String, dynamic>)> _onNovoConviteRecebido = [];
  final List<Function(Map<String, dynamic>)> _onPrevisaoAtualizada = [];
  final List<Function(Map<String, dynamic>)> _onDespensaAtualizada = [];
  final List<Function(Map<String, dynamic>)> _onMembroAdicionado = [];
  final List<Function(Map<String, dynamic>)> _onMembroRemovido = [];

  SignalRService(this._apiService);

  Future<void> connect() async {
    if (_isConnected || _isConnecting) return;

    _isConnecting = true;

    try {
      final token = await _apiService.getToken();
      if (token == null) {
        throw Exception('Token não encontrado');
      }

      _hubConnection = HubConnectionBuilder()
          .withUrl(
            hubUrl,
            options: HttpConnectionOptions(
              accessTokenFactory: () => Future.value(token),
            ),
          )
          .withAutomaticReconnect(retryDelays: [0, 2000, 10000, 30000])
          .build();

      // Configura os event handlers para conexão
      // TODO: Corrigir tipos de callback quando a biblioteca for atualizada
      // _hubConnection!.onclose((error) {
      //   _isConnected = false;
      //   debugPrint('SignalR: Conexão fechada - $error');

      //   // Agenda reconexão se não foi desconectado intencionalmente
      //   if (error != null) {
      //     _scheduleReconnect();
      //   }
      // });

      // _hubConnection!.onreconnecting((error) {
      //   _isConnected = false;
      //   debugPrint('SignalR: Reconectando - $error');
      // });

      // _hubConnection!.onreconnected((connectionId) {
      //   _isConnected = true;
      //   _reconnectAttempts = 0;
      //   debugPrint('SignalR: Reconectado - $connectionId');
      // });

      // Configura os event handlers para eventos do hub
      _setupEventHandlers();

      // Conecta ao hub
      await _hubConnection!.start();
      _isConnected = true;
      _isConnecting = false;
      _reconnectAttempts = 0;

      debugPrint('SignalR conectado com sucesso');
    } catch (e) {
      _isConnecting = false;
      debugPrint('Erro ao conectar SignalR: $e');

      // Tenta reconectar automaticamente
      _scheduleReconnect();
    }
  }

  Future<void> disconnect() async {
    if (!_isConnected || _hubConnection == null) return;

    try {
      _reconnectTimer?.cancel();
      await _hubConnection!.stop();
      _isConnected = false;
      debugPrint('SignalR desconectado');
    } catch (e) {
      debugPrint('Erro ao desconectar SignalR: $e');
    }
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= maxReconnectAttempts) {
      debugPrint('SignalR: Máximo de tentativas de reconexão atingido');
      return;
    }

    _reconnectAttempts++;
    final delay = Duration(seconds: _reconnectAttempts * 5);

    _reconnectTimer = Timer(delay, () {
      debugPrint('SignalR: Tentativa de reconexão $_reconnectAttempts');
      connect();
    });
  }

  void _setupEventHandlers() {
    if (_hubConnection == null) return;

    // Evento: EstoqueItemAtualizado
    _hubConnection!.on('EstoqueItemAtualizado', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final data = arguments[0] as Map<String, dynamic>;
        for (var callback in _onEstoqueItemAtualizado) {
          callback(data);
        }
        debugPrint('EstoqueItemAtualizado: $data');
      }
    });

    // Evento: ListaDeComprasAtualizada
    _hubConnection!.on('ListaDeComprasAtualizada', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final data = arguments[0] as Map<String, dynamic>;
        for (var callback in _onListaDeComprasAtualizada) {
          callback(data);
        }
        debugPrint('ListaDeComprasAtualizada: $data');
      }
    });

    // Evento: NovoConviteRecebido
    _hubConnection!.on('NovoConviteRecebido', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final data = arguments[0] as Map<String, dynamic>;
        for (var callback in _onNovoConviteRecebido) {
          callback(data);
        }
        debugPrint('NovoConviteRecebido: $data');
      }
    });

    // Evento: PrevisaoAtualizada
    _hubConnection!.on('PrevisaoAtualizada', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final data = arguments[0] as Map<String, dynamic>;
        for (var callback in _onPrevisaoAtualizada) {
          callback(data);
        }
        debugPrint('PrevisaoAtualizada: $data');
      }
    });

    // Evento: DespensaAtualizada
    _hubConnection!.on('DespensaAtualizada', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final data = arguments[0] as Map<String, dynamic>;
        for (var callback in _onDespensaAtualizada) {
          callback(data);
        }
        debugPrint('DespensaAtualizada: $data');
      }
    });

    // Evento: MembroAdicionado
    _hubConnection!.on('MembroAdicionado', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final data = arguments[0] as Map<String, dynamic>;
        for (var callback in _onMembroAdicionado) {
          callback(data);
        }
        debugPrint('MembroAdicionado: $data');
      }
    });

    // Evento: MembroRemovido
    _hubConnection!.on('MembroRemovido', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final data = arguments[0] as Map<String, dynamic>;
        for (var callback in _onMembroRemovido) {
          callback(data);
        }
        debugPrint('MembroRemovido: $data');
      }
    });
  }

  // Métodos para adicionar listeners
  void addEstoqueItemListener(Function(Map<String, dynamic>) callback) {
    _onEstoqueItemAtualizado.add(callback);
  }

  void addListaComprasListener(Function(Map<String, dynamic>) callback) {
    _onListaDeComprasAtualizada.add(callback);
  }

  void addConviteListener(Function(Map<String, dynamic>) callback) {
    _onNovoConviteRecebido.add(callback);
  }

  void addPrevisaoListener(Function(Map<String, dynamic>) callback) {
    _onPrevisaoAtualizada.add(callback);
  }

  void addDespensaListener(Function(Map<String, dynamic>) callback) {
    _onDespensaAtualizada.add(callback);
  }

  void addMembroAdicionadoListener(Function(Map<String, dynamic>) callback) {
    _onMembroAdicionado.add(callback);
  }

  void addMembroRemovidoListener(Function(Map<String, dynamic>) callback) {
    _onMembroRemovido.add(callback);
  }

  // Métodos para remover listeners
  void removeEstoqueItemListener(Function(Map<String, dynamic>) callback) {
    _onEstoqueItemAtualizado.remove(callback);
  }

  void removeListaComprasListener(Function(Map<String, dynamic>) callback) {
    _onListaDeComprasAtualizada.remove(callback);
  }

  void removeConviteListener(Function(Map<String, dynamic>) callback) {
    _onNovoConviteRecebido.remove(callback);
  }

  void removePrevisaoListener(Function(Map<String, dynamic>) callback) {
    _onPrevisaoAtualizada.remove(callback);
  }

  void removeDespensaListener(Function(Map<String, dynamic>) callback) {
    _onDespensaAtualizada.remove(callback);
  }

  void removeMembroAdicionadoListener(Function(Map<String, dynamic>) callback) {
    _onMembroAdicionado.remove(callback);
  }

  void removeMembroRemovidoListener(Function(Map<String, dynamic>) callback) {
    _onMembroRemovido.remove(callback);
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
  bool get isConnecting => _isConnecting;

  // Reconecta se necessário
  Future<void> ensureConnected() async {
    if (!_isConnected && !_isConnecting) {
      await connect();
    }
  }

  // Limpa recursos
  void dispose() {
    _reconnectTimer?.cancel();
    _onEstoqueItemAtualizado.clear();
    _onListaDeComprasAtualizada.clear();
    _onNovoConviteRecebido.clear();
    _onPrevisaoAtualizada.clear();
    _onDespensaAtualizada.clear();
    _onMembroAdicionado.clear();
    _onMembroRemovido.clear();
    disconnect();
  }
}
