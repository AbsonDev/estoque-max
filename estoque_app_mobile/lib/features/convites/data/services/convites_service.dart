import '../../../../core/services/api_service.dart';
import '../models/convite_models.dart';

class ConvitesService {
  final ApiService _apiService;

  ConvitesService(this._apiService);

  Future<List<Convite>> getConvitesRecebidos() async {
    try {
      final response = await _apiService.get('/convites');
      return (response.data as List)
          .map((convite) => Convite.fromJson(convite))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar convites recebidos: ${e.toString()}');
    }
  }

  Future<List<Convite>> getConvitesEnviados() async {
    try {
      final response = await _apiService.get('/convites/enviados');
      return (response.data as List)
          .map((convite) => Convite.fromJson(convite))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar convites enviados: ${e.toString()}');
    }
  }

  Future<void> enviarConvite(int despensaId, ConviteRequest request) async {
    try {
      await _apiService.post(
        '/despensas/$despensaId/convidar',
        data: request.toJson(),
      );
    } catch (e) {
      throw Exception('Erro ao enviar convite: ${e.toString()}');
    }
  }

  Future<void> aceitarConvite(int conviteId) async {
    try {
      await _apiService.post('/convites/$conviteId/aceitar');
    } catch (e) {
      throw Exception('Erro ao aceitar convite: ${e.toString()}');
    }
  }

  Future<void> recusarConvite(int conviteId) async {
    try {
      await _apiService.post('/convites/$conviteId/recusar');
    } catch (e) {
      throw Exception('Erro ao recusar convite: ${e.toString()}');
    }
  }

  Future<void> deletarConvite(int conviteId) async {
    try {
      await _apiService.delete('/convites/$conviteId');
    } catch (e) {
      throw Exception('Erro ao deletar convite: ${e.toString()}');
    }
  }

  Future<List<MembroDespensa>> getMembros(int despensaId) async {
    try {
      final response = await _apiService.get('/despensas/$despensaId/membros');
      return (response.data as List)
          .map((membro) => MembroDespensa.fromJson(membro))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar membros da despensa: ${e.toString()}');
    }
  }

  Future<void> removerMembro(int despensaId, int membroId) async {
    try {
      await _apiService.delete('/despensas/$despensaId/membros/$membroId');
    } catch (e) {
      throw Exception('Erro ao remover membro: ${e.toString()}');
    }
  }

  Future<void> alterarRoleMembro(
    int despensaId,
    int membroId,
    String novoRole,
  ) async {
    try {
      await _apiService.put(
        '/despensas/$despensaId/membros/$membroId/role',
        data: {'role': novoRole},
      );
    } catch (e) {
      throw Exception('Erro ao alterar role do membro: ${e.toString()}');
    }
  }
}
