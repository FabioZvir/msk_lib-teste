import 'dart:async';

import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';
import 'package:msk/msk.dart';

part 'painel_notificacoes_controller.g.dart';

class PainelNotificacoesController = _PainelNotificacoesBase
    with _$PainelNotificacoesController;

abstract class _PainelNotificacoesBase with Store {
  BaseFontDataTask fontDataTask;
  @observable
  ObservableList<TarefasDia> taskDeadline = ObservableList();

  @observable
  bool loading = true;
  String lastVersion = "0x0000000000000000";

  _PainelNotificacoesBase(this.fontDataTask) {
    loading = true;
    getNotifications().then((value) {
      loading = false;
      Timer.periodic(Duration(minutes: 10), (timer) {
        getNotifications();
      });
    });
  }

  Future getNotifications() async {
    try {
      ResponseNotification? responseNotification =
          await fontDataTask.getTasks(lastVersion);

      if (responseNotification != null &&
          responseNotification.tarefas?.isNotEmpty == true) {
        List<TarefasDia> tempList = List.from(taskDeadline);

        for (var task in responseNotification.tarefas!) {
          int indexDay = tempList.indexWhere((element) =>
              element.dataFormatada == task.dataPrazo.string('yyyy-dd-MM'));
          if (indexDay > -1) {
            int index = tempList[indexDay]
                .tarefas!
                .indexWhere((element) => element.idServer == task.idServer);
            if (index > -1) {
              if (removeTask(task)) {
                tempList[indexDay].tarefas!.removeAt(index);
              } else {
                // Atualiza os itens tmb
                if (task.itens != null) {
                  var itensAtuais = tempList[indexDay].tarefas![index].itens;
                  for (int i = 0; i < task.itens!.length; i++) {
                    int indexItem = itensAtuais!.indexWhere((element) =>
                        element.idServer == task.itens![i].idServer);
                    if (indexItem > -1) {
                      // Já existe
                      itensAtuais[indexItem] = task.itens![i];
                    } else {
                      // Cria um novo
                      itensAtuais.add(task.itens![i]);
                    }
                  }
                  task.itens = itensAtuais;
                }
                tempList[indexDay].tarefas![index] = task;
              }
            } else if (!removeTask(task)) {
              tempList[indexDay].tarefas!.add(task);
            }
          } else if (!removeTask(task)) {
            tempList.add(TarefasDia(
                dataFormatada: task.dataPrazo.string('yyyy-dd-MM'),
                prazo: task.dataPrazo,
                tarefas: [task]));
          }
        }

        /// Remove dias sem nenhuma tarefa
        tempList.removeWhere((element) => element.tarefas!.isEmpty);
        taskDeadline = ObservableList.of(
            tempList.sortedBy((TarefasDia? tarefa) => tarefa!.prazo));
        lastVersion = responseNotification.version ?? '';
      }
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
    }
  }

  bool removeTask(TarefaServidor task) {
    return task.status == TAREFA_CONCLUIDA ||
        task.status == TAREFA_ATRASADA ||
        task.deletado == true;
  }

  Future<bool> markIsRead(int? idServer, bool isRead) async {
    try {
      Response? response = await API.post('api/servicos/notificacao/marcarlida',
          data: {"idServer": idServer, "isRead": isRead});
      return response.sucesso();
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
    }
    return false;
  }

  List<SumDayTasks> resumeMyTask() {
    int qtdDelayed = 0,
        qtdToday = 0,
        qtdTomorrow = 0,
        qtdNext7Days = 0,
        qtdNext15Days = 0,
        qtdNext30Days = 0;
    for (TarefasDia tarefasDia in taskDeadline) {
      for (TarefaServidor tarefa in tarefasDia.tarefas!) {
        if (tarefa.deletado != true && tarefa.status != TAREFA_CONCLUIDA) {
          int differenceInDays =
              tarefa.dataPrazo!.difference(DateTime.now()).inDays;
          if (differenceInDays < 0) {
            qtdDelayed++;
          } else {
            if (differenceInDays == 0) {
              qtdToday++;
            }
            if (differenceInDays == 1) {
              qtdTomorrow++;
            }

            /// deixa sem else mesmo para incluir as
            if (differenceInDays <= 7) {
              qtdNext7Days++;
            }
            if (differenceInDays <= 15) {
              qtdNext15Days++;
            }
            if (differenceInDays <= 30) {
              qtdNext30Days++;
            }
          }
        }
      }
    }
    List<SumDayTasks> list = [];

    if (qtdDelayed > 0) {
      list.add(SumDayTasks(
          enumSumDaysTasks: EnumSumDaysTasks.DELAYED, qtdTasks: qtdDelayed));
    }
    if (qtdToday > 0) {
      list.add(SumDayTasks(
          enumSumDaysTasks: EnumSumDaysTasks.TODAY, qtdTasks: qtdToday));
    }
    if (qtdTomorrow > 0) {
      list.add(SumDayTasks(
          enumSumDaysTasks: EnumSumDaysTasks.TOMORROW, qtdTasks: qtdTomorrow));
    }
    if (qtdNext7Days > 0) {
      list.add(SumDayTasks(
          enumSumDaysTasks: EnumSumDaysTasks.NEXT7DAYS,
          qtdTasks: qtdNext7Days));
    }
    if (qtdNext15Days > 0) {
      list.add(SumDayTasks(
          enumSumDaysTasks: EnumSumDaysTasks.NEXT15DAYS,
          qtdTasks: qtdNext15Days));
    }
    if (qtdNext30Days > 0) {
      list.add(SumDayTasks(
          enumSumDaysTasks: EnumSumDaysTasks.NEXT30DAYS,
          qtdTasks: qtdNext30Days));
    }
    return list;
  }

  List<TasksType> createResumeTaksDay(EnumSumDaysTasks? enumSumDaysTasks) {
    List<TarefaServidor> tarefas = [];
    if (enumSumDaysTasks == EnumSumDaysTasks.DELAYED) {
      for (TarefasDia tarefasDia in taskDeadline) {
        if (tarefasDia.prazo!.difference(DateTime.now()).inDays < 0) {
          tarefas.addAll(tarefasDia.tarefas!);
        } else {
          /// Como as tarefas estão organizadas em ordem crescente,
          /// Caso a data do item seja maior que a de hoje, as demais também serão
          break;
        }
      }
    } else if (enumSumDaysTasks == EnumSumDaysTasks.TODAY) {
      for (TarefasDia tarefasDia in taskDeadline) {
        if (tarefasDia.prazo!.difference(DateTime.now()).inDays == 0) {
          tarefas.addAll(tarefasDia.tarefas!);
        }
      }
    } else if (enumSumDaysTasks == EnumSumDaysTasks.TOMORROW) {
      for (TarefasDia tarefasDia in taskDeadline) {
        if (tarefasDia.prazo!.difference(DateTime.now()).inDays == 1) {
          tarefas.addAll(tarefasDia.tarefas!);
        }
      }
    } else if (enumSumDaysTasks == EnumSumDaysTasks.NEXT7DAYS) {
      for (TarefasDia tarefasDia in taskDeadline) {
        if (tarefasDia.prazo!.difference(DateTime.now()).inDays <= 7 &&
            tarefasDia.prazo!.difference(DateTime.now()).inDays >= 0) {
          tarefas.addAll(tarefasDia.tarefas!);
        }
      }
    } else if (enumSumDaysTasks == EnumSumDaysTasks.NEXT15DAYS) {
      for (TarefasDia tarefasDia in taskDeadline) {
        if (tarefasDia.prazo!.difference(DateTime.now()).inDays <= 15 &&
            tarefasDia.prazo!.difference(DateTime.now()).inDays >= 0) {
          tarefas.addAll(tarefasDia.tarefas!);
        }
      }
    } else if (enumSumDaysTasks == EnumSumDaysTasks.NEXT30DAYS) {
      for (TarefasDia tarefasDia in taskDeadline) {
        if (tarefasDia.prazo!.difference(DateTime.now()).inDays <= 30 &&
            tarefasDia.prazo!.difference(DateTime.now()).inDays >= 0) {
          tarefas.addAll(tarefasDia.tarefas!);
        }
      }
    }
    List<TasksType> tasksType = [];

    /// Remove aqui todas as tarefas concluídas/deletadas
    tarefas.removeWhere((element) =>
        element.deletado == true || element.status == TAREFA_CONCLUIDA);
    for (TarefaServidor tarefa in tarefas) {
      int index = tasksType.indexWhere((element) =>
          element.typeTask!.idServer == tarefa.tipoTarefa!.idServer);
      if (index > -1) {
        tasksType[index].tasks!.add(tarefa);
      } else {
        tasksType.add(TasksType(tasks: [tarefa], typeTask: tarefa.tipoTarefa));
      }
    }
    return tasksType;
  }

  void updateTaskStatus(int uniqueKey, int statusIdServer) {
    taskDeadline.forEach((element) {
      element.tarefas?.forEach((element) {
        if (element.uniqueKey == uniqueKey) {
          element.status = statusIdServer;
        }
      });
    });
  }

  void reload() {
    getNotifications();
  }

  void updateHistoryTask(TarefaServidor tarefa) {
    for (var day in taskDeadline) {
      int index = day.tarefas
              ?.indexWhere((element) => element.idServer == tarefa.idServer) ??
          -1;
      if (index > -1) {
        day.tarefas![index].history = tarefa.history;
      }
    }
  }

  Future<bool> reloadSpecifyRow(int uniqueKey) async {
    TarefaServidor? newTask = await fontDataTask.getTaskById(uniqueKey);
    if (newTask != null) {
      updateHistoryTask(newTask);
      return true;
    }
    return false;
  }
}
