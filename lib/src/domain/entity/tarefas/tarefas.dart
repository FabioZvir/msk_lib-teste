import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

part 'tarefas.g.dart';

class ResponseNotification {
  String? version;
  List<TarefaServidor>? tarefas;
  ResponseNotification({
    this.version,
    this.tarefas,
  });

  ResponseNotification copyWith({
    String? version,
    List<TarefaServidor>? tarefas,
  }) {
    return ResponseNotification(
      version: version ?? this.version,
      tarefas: tarefas ?? this.tarefas,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'version': version,
      'tarefas': tarefas?.map((x) => x.toMap()).toList(),
    };
  }

  factory ResponseNotification.fromMap(Map<String, dynamic> map) {
    return ResponseNotification(
      version: map['version'],
      tarefas: List<TarefaServidor>.from(
          map['tarefas']?.map((x) => TarefaServidor.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory ResponseNotification.fromJson(String source) =>
      ResponseNotification.fromMap(json.decode(source));

  @override
  String toString() =>
      'ResponseNotification(version: $version, tarefas: $tarefas)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ResponseNotification &&
        other.version == version &&
        listEquals(other.tarefas, tarefas);
  }

  @override
  int get hashCode => version.hashCode ^ tarefas.hashCode;
}

class TarefasDia = _TarefasDiaBase with _$TarefasDia;

abstract class _TarefasDiaBase with Store {
  DateTime? prazo;

  /// Data no formato yyyy-mm-dd
  String? dataFormatada;
  List<TarefaServidor>? tarefas;
  @observable
  bool isExpanded;

  _TarefasDiaBase(
      {this.prazo, this.tarefas, this.dataFormatada, this.isExpanded = false});
}

class TipoTarefaServidor {
  int? idServer;
  String? nome;
  TipoTarefaServidor({
    this.idServer,
    this.nome,
  });

  TipoTarefaServidor copyWith({
    int? idServer,
    String? nome,
  }) {
    return TipoTarefaServidor(
      idServer: idServer ?? this.idServer,
      nome: nome ?? this.nome,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idServer': idServer,
      'nome': nome,
    };
  }

  factory TipoTarefaServidor.fromMap(Map<String, dynamic> map) {
    return TipoTarefaServidor(
      idServer: map['idServer'],
      nome: map['nome'],
    );
  }

  String toJson() => json.encode(toMap());

  factory TipoTarefaServidor.fromJson(String source) =>
      TipoTarefaServidor.fromMap(json.decode(source));

  @override
  String toString() => 'TipoTarefa(idServer: $idServer, nome: $nome)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TipoTarefaServidor &&
        other.idServer == idServer &&
        other.nome == nome;
  }

  @override
  int get hashCode => idServer.hashCode ^ nome.hashCode;
}

class TarefaServidor extends _TarefaServidorBase with _$TarefaServidor {
  TarefaServidor(int uniqueKey,
      {int? idServer,
      String? titulo,
      String? descricao,
      DateTime? dataCriacao,
      DateTime? dataPrazo,
      int? prioridade,
      int? status,
      List<ItemTarefaServidor>? itens,
      bool deletado = false,
      TarefaComprasServidor? tarefaCompras,
      TipoTarefaServidor? tipoTarefa,
      dynamic obj,
      List<TarefaLocalServidor>? locais,
      required ObservableList<PeopleTaskServer> team,
      MachineServer? machineServer,
      String? obs,
      List<HistoryExecutionTask> history = const []})
      : super(uniqueKey,
            idServer: idServer,
            titulo: titulo,
            descricao: descricao,
            dataCriacao: dataCriacao,
            dataPrazo: dataPrazo,
            prioridade: prioridade,
            status: status,
            itens: itens,
            tarefaCompras: tarefaCompras,
            tipoTarefa: tipoTarefa,
            obj: obj,
            locais: locais,
            team: team,
            deletado: deletado,
            machineServer: machineServer,
            obs: obs,
            history: history);

  factory TarefaServidor.fromMap(Map<String, dynamic> map) {
    return TarefaServidor(map['uniqueKey'] ?? map['idServer'],
        idServer: map['idServer'],
        titulo: map['titulo'].replaceAll('\\n', '\n'),
        descricao: map['descricao'].replaceAll('\\n', '\n'),
        dataCriacao: DateTime.fromMillisecondsSinceEpoch(map['dataCriacao']),
        dataPrazo: DateTime.fromMillisecondsSinceEpoch(map['dataPrazo']),
        prioridade: map['prioridade'],
        status: map['status'],
        tarefaCompras: TarefaComprasServidor.fromMap(map['tarefaCompras']),
        deletado: map['deletado'] ?? false,
        tipoTarefa: TipoTarefaServidor.fromMap(map['tipoTarefa']),
        team: map['equipe'] != null
            ? ObservableList.of(List<PeopleTaskServer>.from(map['equipe']
                ?.map((x) => PeopleTaskServer(
                    idServer: x['idServer'],
                    uniqueKey: x['uniqueKey'],
                    peopleServer: PeopleServer(
                        idServer: x['pessoa']['idServer'],
                        name: x['pessoa']['nome'].toString().trim(),
                        uniqueKey: x['pessoa']['uniqueKey'])))
                .toList()))
            : ObservableList(),
        itens: List<ItemTarefaServidor>.from(
          map['itens']?.map(
            (x) => ItemTarefaServidor.fromMap(x),
          ),
        ),
        history: map['history'] != null
            ? List<HistoryExecutionTask>.from(map['history']?.map(
                (x) => HistoryExecutionTask.fromMap(x),
              ))
            : []);
  }
}

abstract class _TarefaServidorBase with Store {
  int? idServer;
  String? titulo;
  String? descricao;
  DateTime? dataCriacao;
  DateTime? dataPrazo;
  int? prioridade;
  @observable
  int? status;
  @observable
  bool? deletado;
  TarefaComprasServidor? tarefaCompras;
  List<ItemTarefaServidor>? itens;
  TipoTarefaServidor? tipoTarefa;
  int uniqueKey;
  dynamic obj;
  List<TarefaLocalServidor>? locais;
  @observable
  ObservableList<PeopleTaskServer> team;
  MachineServer? machineServer;
  String? obs;
  @observable
  bool showInputObs = false;
  List<HistoryExecutionTask> history;

  final TextEditingController ctlObs = TextEditingController();

  _TarefaServidorBase(this.uniqueKey,
      {this.idServer,
      this.titulo,
      this.descricao,
      this.dataCriacao,
      this.dataPrazo,
      this.prioridade,
      this.status,
      this.itens,
      this.deletado,
      this.tarefaCompras,
      this.tipoTarefa,
      this.obj,
      this.locais,
      required this.team,
      this.machineServer,
      this.obs,
      this.history = const []}) {
    ctlObs.text = obs ?? '';
  }

  Map<String, dynamic> toMap() {
    return {
      'idServer': idServer,
      'titulo': titulo,
      'descricao': descricao,
      'dataCriacao': dataCriacao!.millisecondsSinceEpoch,
      'dataPrazo': dataPrazo!.millisecondsSinceEpoch,
      'prioridade': prioridade,
      'status': status,
      'itens': itens?.map((x) => x.toMap()).toList(),
      'history': history.map((e) => e.toMap()).toList()
    };
  }

  @override
  String toString() {
    return 'Tarefa(idServer: $idServer, title: $titulo, descricao: $descricao, dataCriacao: $dataCriacao, dataPrazo: $dataPrazo, prioridade: $prioridade, status: $status, itens: $itens)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TarefaServidor &&
        other.idServer == idServer &&
        other.titulo == titulo &&
        other.descricao == descricao &&
        other.dataCriacao == dataCriacao &&
        other.dataPrazo == dataPrazo &&
        other.prioridade == prioridade &&
        other.status == status &&
        listEquals(other.itens, itens);
  }

  @override
  int get hashCode {
    return idServer.hashCode ^
        titulo.hashCode ^
        descricao.hashCode ^
        dataCriacao.hashCode ^
        dataPrazo.hashCode ^
        prioridade.hashCode ^
        status.hashCode ^
        itens.hashCode;
  }
}

class EmployeeHistoryExecutionTask {
  String name;
  EmployeeHistoryExecutionTask({
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }

  factory EmployeeHistoryExecutionTask.fromMap(Map<String, dynamic> map) {
    return EmployeeHistoryExecutionTask(
      name: map['name'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory EmployeeHistoryExecutionTask.fromJson(String source) =>
      EmployeeHistoryExecutionTask.fromMap(json.decode(source));
}

class HistoryExecutionTask {
  int id;
  String description;
  int hours;
  double displacement;
  String obs;
  List<EmployeeHistoryExecutionTask> employees;
  List<ItemTarefaServidor> itens;
  DateTime date;
  dynamic obj;
  HistoryExecutionTask(
      {required this.id,
      required this.description,
      required this.hours,
      required this.displacement,
      required this.obs,
      required this.employees,
      required this.itens,
      required this.date,
      this.obj});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'hours': hours,
      'displacement': displacement,
      'obs': obs,
      'employees': employees.map((x) => x.toMap()).toList(),
      'itens': itens.map((x) => x.toMap()).toList(),
      'date': date.millisecondsSinceEpoch
    };
  }

  factory HistoryExecutionTask.fromMap(Map<String, dynamic> map) {
    return HistoryExecutionTask(
      id: map['id'],
      description: map['description'] ?? '',
      hours: map['hours']?.toDouble() ?? 0.0,
      displacement: map['displacement']?.toDouble() ?? 0.0,
      obs: map['obs'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      employees: List<EmployeeHistoryExecutionTask>.from(map['employees']
          ?.map((x) => EmployeeHistoryExecutionTask.fromMap(x))),
      itens: List<ItemTarefaServidor>.from(
          map['itens']?.map((x) => ItemTarefaServidor.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory HistoryExecutionTask.fromJson(String source) =>
      HistoryExecutionTask.fromMap(json.decode(source));
}

class TarefaComprasServidor {
  int? idServer;
  int? acao;
  String? descricao;

  TarefaComprasServidor({this.idServer, this.acao, this.descricao});

  factory TarefaComprasServidor.fromMap(Map<String, dynamic> map) {
    return TarefaComprasServidor(
        idServer: map['idServer'],
        acao: map['acao'],
        descricao: map['descricao']);
  }
}

class ItemTarefaServidor extends _ItemTarefaServidorBase
    with _$ItemTarefaServidor {
  ItemTarefaServidor(
      {int? idServer,
      String? descricao,
      int? status,
      bool? concluido,
      bool? deletado,
      dynamic obj,
      List<ItemMaterialRequisition>? itemsRequisicaoMaterial})
      : super(
            idServer: idServer,
            descricao: descricao,
            status: status,
            concluido: concluido,
            deletado: deletado,
            obj: obj,
            itemsRequisicaoMaterial: itemsRequisicaoMaterial);

  factory ItemTarefaServidor.fromMap(Map<String, dynamic> map) {
    return ItemTarefaServidor(
        idServer: map['idServer'],
        descricao: map['descricao'],
        status: map['status'],
        concluido: map['concluido'],
        deletado: map['deletado']);
  }
}

abstract class _ItemTarefaServidorBase with Store {
  int? idServer;
  String? descricao;
  int? status;
  @observable
  bool? concluido;
  bool? deletado;
  dynamic obj;
  List<ItemMaterialRequisition>? itemsRequisicaoMaterial;

  _ItemTarefaServidorBase(
      {this.idServer,
      this.descricao,
      this.status,
      this.concluido,
      this.deletado,
      this.obj,
      this.itemsRequisicaoMaterial});

  Map<String, dynamic> toMap() {
    return {
      'idServer': idServer,
      'descricao': descricao,
      'status': status,
      'concluido': concluido,
      'deletado': deletado,
    };
  }

  @override
  String toString() {
    return 'ItemTarefa(idServer: $idServer, descricao: $descricao, status: $status, concluido: $concluido, deletado: $deletado)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ItemTarefaServidor &&
        other.idServer == idServer &&
        other.descricao == descricao &&
        other.status == status &&
        other.concluido == concluido &&
        other.deletado == deletado;
  }

  @override
  int get hashCode {
    return idServer.hashCode ^
        descricao.hashCode ^
        status.hashCode ^
        concluido.hashCode ^
        deletado.hashCode;
  }
}

class TarefaLocalServidor {
  int? idServer;
  String local;
  dynamic obj;

  TarefaLocalServidor({required this.idServer, required this.local, this.obj});
}

class StatusTarefaServidor {
  int id;
  String nome;

  StatusTarefaServidor(this.id, this.nome);
}

class SumDayTasks {
  EnumSumDaysTasks? enumSumDaysTasks;
  int? qtdTasks;
  SumDayTasks({this.enumSumDaysTasks, this.qtdTasks});
}

enum EnumSumDaysTasks {
  DELAYED,
  TODAY,
  TOMORROW,
  NEXT7DAYS,
  NEXT15DAYS,
  NEXT30DAYS
}

extension ExEnumSumDaysTasks on EnumSumDaysTasks? {
  String getDescription() {
    switch (this) {
      case EnumSumDaysTasks.DELAYED:
        return 'Atrasadas';
      case EnumSumDaysTasks.TODAY:
        return 'Hoje';
      case EnumSumDaysTasks.TOMORROW:
        return 'Amanhã';
      case EnumSumDaysTasks.NEXT7DAYS:
        return 'Próximos 7 dias';
      case EnumSumDaysTasks.NEXT15DAYS:
        return 'Próximos 15 dias';
      case EnumSumDaysTasks.NEXT30DAYS:
        return 'Próximos 30 dias';
      default:
        return '';
    }
  }
}

class TasksType {
  List<TarefaServidor>? tasks;
  TipoTarefaServidor? typeTask;
  TasksType({
    this.tasks,
    this.typeTask,
  });
}

class PeopleTaskServer {
  int? uniqueKey;
  int? idServer;
  PeopleServer peopleServer;
  dynamic obj;

  PeopleTaskServer(
      {required this.uniqueKey,
      required this.idServer,
      required this.peopleServer,
      this.obj});
}

class PeopleServer {
  String? name;
  int? uniqueKey;
  int? idServer;

  PeopleServer({
    required this.name,
    required this.uniqueKey,
    required this.idServer,
  });
}

class MachineServer {
  String? name;
  int? uniqueKey;
  int? idServer;
  dynamic obj;

  MachineServer(
      {required this.name,
      required this.uniqueKey,
      required this.idServer,
      this.obj});
}

class ItemMaterialRequisition {
  int idServer;
  int uniqueKey;
  String resumeProduct;
  ItemMaterialRequisition({
    required this.idServer,
    required this.uniqueKey,
    required this.resumeProduct,
  });
}
