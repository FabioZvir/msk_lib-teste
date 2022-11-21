import 'package:msk/msk.dart';

const TAREFA_PENDENTE = 1;
const TAREFA_ENVIADA = 2;
const TAREFA_ABERTA = 3;
const TAREFA_CONCLUIDA = 4;
const TAREFA_ATRASADA = 5;
const TAREFA_IGNORADA = 6;

class UtilsTarefas {
  static List<StatusTarefaServidor> get getAllStatus {
    return [
      StatusTarefaServidor(TAREFA_PENDENTE, 'Pendente'),
      StatusTarefaServidor(TAREFA_ENVIADA, 'Enviada'),
      StatusTarefaServidor(TAREFA_PENDENTE, 'Pendente'),
      StatusTarefaServidor(TAREFA_ABERTA, 'Aberta'),
      StatusTarefaServidor(TAREFA_CONCLUIDA, 'Concluída'),
      StatusTarefaServidor(TAREFA_ATRASADA, 'Atrasada'),
      StatusTarefaServidor(TAREFA_IGNORADA, 'Ignorada'),
    ];
  }

  static StatusTarefaServidor? getStatus(int? id) =>
      getAllStatus.firstWhereOrNull((element) => element.id == id);
}
