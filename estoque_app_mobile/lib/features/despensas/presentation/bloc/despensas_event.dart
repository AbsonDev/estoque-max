import 'package:equatable/equatable.dart';
import '../../data/models/despensa_dto.dart';

abstract class DespensasEvent extends Equatable {
  const DespensasEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para carregar todas as despensas do usuário
class LoadDespensas extends DespensasEvent {
  const LoadDespensas();
}

/// Evento para recarregar as despensas (pull-to-refresh)
class RefreshDespensas extends DespensasEvent {
  const RefreshDespensas();
}

/// Evento para criar uma nova despensa
class CreateDespensa extends DespensasEvent {
  final CriarDespensaDto dto;

  const CreateDespensa(this.dto);

  @override
  List<Object> get props => [dto];
}

/// Evento para atualizar uma despensa existente
class UpdateDespensa extends DespensasEvent {
  final int id;
  final CriarDespensaDto dto;

  const UpdateDespensa(this.id, this.dto);

  @override
  List<Object> get props => [id, dto];
}

/// Evento para deletar uma despensa
class DeleteDespensa extends DespensasEvent {
  final int id;

  const DeleteDespensa(this.id);

  @override
  List<Object> get props => [id];
}

/// Evento para carregar detalhes de uma despensa específica
class LoadDespensaDetalhes extends DespensasEvent {
  final int id;

  const LoadDespensaDetalhes(this.id);

  @override
  List<Object> get props => [id];
}

/// Evento para convidar um membro para a despensa
class ConvidarMembro extends DespensasEvent {
  final int despensaId;
  final ConvidarMembroDto dto;

  const ConvidarMembro(this.despensaId, this.dto);

  @override
  List<Object> get props => [despensaId, dto];
}

/// Evento para remover um membro da despensa
class RemoverMembro extends DespensasEvent {
  final int despensaId;
  final int membroId;

  const RemoverMembro(this.despensaId, this.membroId);

  @override
  List<Object> get props => [despensaId, membroId];
}

/// Evento para limpar mensagens de erro/sucesso
class ClearDespensaMessage extends DespensasEvent {
  const ClearDespensaMessage();
}

/// Evento para atualização em tempo real de despensas
class DespensaUpdatedRealTime extends DespensasEvent {
  final Map<String, dynamic> data;

  const DespensaUpdatedRealTime(this.data);

  @override
  List<Object> get props => [data];
}

/// Evento para membro adicionado em tempo real
class MembroAdicionadoRealTime extends DespensasEvent {
  final Map<String, dynamic> data;

  const MembroAdicionadoRealTime(this.data);

  @override
  List<Object> get props => [data];
}

/// Evento para membro removido em tempo real
class MembroRemovidoRealTime extends DespensasEvent {
  final Map<String, dynamic> data;

  const MembroRemovidoRealTime(this.data);

  @override
  List<Object> get props => [data];
} 