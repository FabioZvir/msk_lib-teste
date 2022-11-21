import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:msk/msk.dart';
import 'package:intl/intl.dart';

class PainelNotificacoesWidget extends StatelessWidget {
  final PainelNotificacoesController controller;
  final Function(TarefaServidor, Function) taskSelected;
  final Future<bool> Function(TarefaServidor)? showAction;
  final Future<int?> Function(ItemTarefaServidor, bool)? changeItemConclusion;
  final Function(TarefaServidor)? markCompleted;
  final Function()? addNewTask;
  final List<Widget> Function(BuildContext alertContext, TarefaServidor tarefa)?
      extraActions;
  final Future<PeopleTaskServer?> Function(TarefaServidor)? onAddTeam;
  final Future<bool> Function(TarefaServidor, PeopleTaskServer)?
      onPeopleRemoved;
  final Future<bool> Function(TarefaServidor task)? updateObs;
  final Future<bool> Function(TarefaServidor, HistoryExecutionTask)?
      updateHistory;

  /// Indica se os componentes de alteração de status ficaram visíveis
  final bool showChangeStatus;

  const PainelNotificacoesWidget(this.controller, this.taskSelected,
      {this.showChangeStatus = false,
      this.showAction,
      this.changeItemConclusion,
      this.markCompleted,
      this.addNewTask,
      this.extraActions,
      this.onAddTeam,
      this.onPeopleRemoved,
      this.updateObs,
      this.updateHistory});

  @override
  Widget build(BuildContext context) {
    /// Atualiza os dados a cada build
    if (!controller.loading) {
      controller.getNotifications();
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              'Tarefas',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Row(children: [
              if (addNewTask != null)
                IconButton(
                    tooltip: 'Nova',
                    icon: Icon(Icons.add),
                    onPressed: () {
                      addNewTask!();
                    }),
              IconButton(
                  tooltip: 'Resumo',
                  icon: Icon(Icons.info_outline),
                  onPressed: () {
                    showDialogResume(context);
                  }),
              IconButton(
                  tooltip: 'Atualizar',
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    controller.getNotifications();
                    showSnack(context, 'Atualizando tarefas...');
                  })
            ]),
          ]),
        ),
        Observer(builder: (_) {
          if (controller.loading) {
            return Center(child: CircularProgressIndicator());
          }
          return controller.taskDeadline.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                      child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Nenhuma tarefa pendente'),
                      Icon(
                        Icons.done,
                        color: Colors.green,
                      )
                    ],
                  )),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: controller.taskDeadline.length,
                  itemBuilder: (_, index) {
                    Widget widgetDeadline = SizedBox();
                    if (controller.taskDeadline[index].prazo != null) {
                      widgetDeadline = Container(
                        width: 80,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              controller.taskDeadline[index].prazo.string('dd'),
                              style: TextStyle(fontSize: 22),
                            ),
                            Text(
                                DateFormat(DateFormat.MONTH, 'pt_Br')
                                    .format(
                                        controller.taskDeadline[index].prazo!)
                                    .toUpperCase(),
                                style: TextStyle(fontSize: 8))
                          ],
                        ),
                      );
                    }
                    return Observer(builder: (_) {
                      if (!controller.taskDeadline[index].isExpanded) {
                        return Row(
                          children: [
                            widgetDeadline,
                            Expanded(
                              child: Card(
                                child: ListTile(
                                  onTap: () {
                                    controller.taskDeadline[index].isExpanded =
                                        !controller
                                            .taskDeadline[index].isExpanded;
                                  },
                                  title: Text(
                                      '${controller.taskDeadline[index].tarefas?.length ?? 0} tarefa${(controller.taskDeadline[index].tarefas?.length ?? 0) > 1 ? 's' : ''}'),
                                  trailing: Tooltip(
                                      message: 'Expandir',
                                      child: Icon(Icons.expand_more)),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      return Padding(
                        padding:
                            const EdgeInsets.only(top: 8, bottom: 8, right: 8),
                        child: Row(
                          children: [
                            widgetDeadline,
                            Expanded(
                                child: Wrap(
                                    runAlignment: WrapAlignment.center,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: controller
                                        .taskDeadline[index].tarefas!
                                        .map((element) =>
                                            buildItem(index, element, context))
                                        .toList())),
                            IconButton(
                                tooltip: 'Recolher',
                                icon: Icon(Icons.expand_less),
                                onPressed: () {
                                  controller.taskDeadline[index].isExpanded =
                                      !controller
                                          .taskDeadline[index].isExpanded;
                                })
                          ],
                        ),
                      );
                    });
                  });
        })
      ],
    );
  }

  Widget buildItem(int indexDay, TarefaServidor tarefa, BuildContext context) {
    return Card(
        color: !isDarkMode(context) ? Colors.grey.shade50 : null,
        child: InkWell(
          onTap: () {
            _showDialogDetails(context, tarefa);
          },
          child: Container(
            width: 250,
            height: 200,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 16, bottom: 8),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  child: Text(
                                tarefa.titulo ?? '',
                                maxLines: 2,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                              if (showChangeStatus)
                                IconButton(
                                    tooltip: 'Marcar como Feita',
                                    onPressed: () async {
                                      if (markCompleted != null) {
                                        markCompleted!(tarefa);
                                      } else {
                                        MyPR progressDialog =
                                            await showProgressDialog(context,
                                                'Marcando como concluída');
                                        bool success = await controller
                                            .markIsRead(tarefa.idServer, true);
                                        await progressDialog.hide();
                                        if (success) {
                                          controller
                                              .taskDeadline[indexDay].tarefas!
                                              .removeWhere((e) =>
                                                  e.idServer ==
                                                  tarefa.idServer);
                                          showSnack(context,
                                              'Notificação removida com sucesso');
                                        } else {
                                          showSnack(
                                              context, 'Ops, algo saiu errado');
                                        }
                                      }
                                    },
                                    icon: Icon(Icons.done)),
                            ],
                          ),
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text("${tarefa.descricao}",
                                style: TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 7),
                          )),
                        ]),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, bottom: 12, top: 8),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: showChangeStatus
                              ? () {
                                  _showDialogChangeStatus(context, tarefa);
                                }
                              : null,
                          child: Container(
                            constraints: BoxConstraints(
                                minWidth: 45,
                                maxWidth: 500,
                                minHeight: 35,
                                maxHeight: 60),
                            decoration: BoxDecoration(
                                color: Color(0xFFf5f5f5),
                                borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 8, bottom: 8, left: 16, right: 16),
                              child: Observer(builder: (_) {
                                if (tarefa.status == 4) {
                                  return Text('Concluída',
                                      style: TextStyle(color: Colors.black));
                                }
                                return Text('Pendente',
                                    style: TextStyle(color: Colors.black));
                              }),
                            ),
                          ),
                        ),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (tarefa.dataPrazo != null)
                              _getTextDeadLine(tarefa, context)
                          ],
                        ))
                      ]),
                ),
                _getLine(tarefa)
              ],
            ),
          ),
        ));
  }

  Widget _getTextDeadLine(TarefaServidor tarefa, BuildContext context) {
    return Observer(builder: (_) {
      if (tarefa.status == 4) {
        return Text(
          'Prazo: ${tarefa.dataPrazo!.string('dd/MM/yyyy')}',
          style: TextStyle(color: Theme.of(context).textTheme.caption?.color),
        );
      }
      int daysDelayed = DateTime.now().difference(tarefa.dataPrazo!).inDays;
      if (daysDelayed < 0) {
        return Text(
          'Prazo: ${tarefa.dataPrazo.string('dd/MM/yyyy')}',
          style: TextStyle(color: Theme.of(context).textTheme.caption?.color),
          maxLines: 2,
          textAlign: TextAlign.right,
        );
      } else if (daysDelayed == 0) {
        return Text('O prazo é hoje',
            style: TextStyle(color: Colors.green), textAlign: TextAlign.right);
      } else {
        // Cotação
        if (tarefa.tarefaCompras != null && tarefa.tarefaCompras!.acao == 109) {
          return Text(
              'Expirada em $daysDelayed dia${daysDelayed > 1 ? 's' : ''}',
              style: TextStyle(color: Colors.red),
              maxLines: 2,
              textAlign: TextAlign.right);
        }
        return Text('Atrasada em $daysDelayed dia${daysDelayed > 1 ? 's' : ''}',
            style: TextStyle(color: getColorDelayed(daysDelayed)),
            maxLines: 2,
            textAlign: TextAlign.right);
      }
    });
  }

  Widget _getLine(TarefaServidor tarefa) {
    if (tarefa.dataPrazo == null) return SizedBox();
    Duration duration = DateTime.now().difference(tarefa.dataPrazo!);
    return Container(
        width: double.maxFinite,
        color: getColorDelayed(duration.inDays),
        height: 2);
  }

  Color getColorDelayed(int daysDelayed) {
    Color color = Colors.green;
    if (daysDelayed > 0) {
      if (daysDelayed < 3) {
        color = Colors.orange;
      } else {
        color = Colors.red;
      }
    }
    return color;
  }

  void _showDialogChangeStatus(BuildContext context, TarefaServidor tarefa) {
    showDialog(
        context: context,
        builder: (alertContext) => AlertDialog(
              title: Text('Selecione o novo status'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: UtilsTarefas.getAllStatus
                    .map((e) => ListTile(
                          title: Text(e.nome),
                          onTap: () {
                            Navigator.maybeOf(context)?.pop();
                            _changeStatus(context, tarefa);
                          },
                        ))
                    .toList(),
              ),
            ));
  }

  Future<void> _changeStatus(
      BuildContext context, TarefaServidor tarefa) async {
    var progress = await showProgressDialog(context, 'Alterando status');
    progress.hide();
  }

  void _showDialogDetails(BuildContext context, TarefaServidor tarefa) async {
    Widget _title(Widget icon, String text) {
      return Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        child: Row(
          children: [
            icon,
            SizedBox(width: 8),
            Text(text,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    Widget _buildHistoryTask() {
      return Column(
          mainAxisSize: MainAxisSize.min,
          children: tarefa.history
              .map(
                (e) => Card(
                    color:
                        isDarkMode(context) ? Colors.black26 : Colors.white60,
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(),
                                    Text(e.description,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                        'Data: ${e.date.string('dd/MM/yyyy HH:mm')}'),
                                    Text(
                                        'Tempo gasto: ${e.hours.toInt().toHourMinuteFromRawMinute()}'),
                                    Text(
                                        'Funcionários: ${e.employees.map((e) => e.name).join(', ')}'),
                                    Text(
                                        'Tarefas: ${e.itens.map((e) => e.descricao).join(', ')}'),
                                    Text(
                                        'Distância percorrida: ${e.displacement}'),
                                  ]),
                            ),
                            if (updateHistory != null)
                              IconButton(
                                  onPressed: () {
                                    updateHistory!(tarefa, e);
                                  },
                                  icon: Icon(Icons.edit))
                          ],
                        ))),
              )
              .toList());
    }

    Widget _buildTaskItens(TarefaServidor tarefa) {
      void onItemChecked(ItemTarefaServidor itemTarefaServidor) {
        changeItemConclusion!(
                itemTarefaServidor, !(itemTarefaServidor.concluido ?? false))
            .then((value) {
          if (value != null) {
            tarefa.status = value;
          }
        });
      }

      if (tarefa.itens?.isNotEmpty != true) {
        return SizedBox();
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(Icon(Icons.list), 'Itens'),
          Padding(
              padding: const EdgeInsets.only(left: 26),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: tarefa.itens!
                      .where((element) => element.deletado != true)
                      .map((e) => Observer(builder: (_) {
                            return InkWell(
                              onTap: changeItemConclusion != null
                                  ? () {
                                      onItemChecked(e);
                                    }
                                  : null,
                              child: Row(
                                children: [
                                  if (changeItemConclusion != null)
                                    Checkbox(
                                        value: e.concluido ?? false,
                                        onChanged: (newValue) {
                                          onItemChecked(e);
                                        }),
                                  Expanded(
                                    child: Text(
                                      '${changeItemConclusion != null ? '' : '* '}${e.descricao}',
                                      style: e.concluido == true
                                          ? TextStyle(
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  ?.color)
                                          : TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  ?.color),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }))
                      .toList())),
        ],
      );
    }

    Widget _descricaoRequisicao() {
      if (tarefa.tarefaCompras != null &&
          tarefa.tarefaCompras!.descricao?.isNotEmpty == true) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Text('Descrição da requisição'),
            Text(
              tarefa.tarefaCompras!.descricao!,
              style:
                  TextStyle(color: Theme.of(context).textTheme.caption?.color),
            )
          ],
        );
      }
      return SizedBox();
    }

    Widget _taskMachine() {
      if (tarefa.machineServer != null) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: 16),
          _title(Icon(Icons.settings), 'Máquina'),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Text(
              '${tarefa.machineServer!.name}',
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.caption?.color),
            ),
          ),
          SizedBox(height: 16),
        ]);
      }
      return SizedBox();
    }

    Widget _taskLocation() {
      if (tarefa.locais != null) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: tarefa.locais!
                .map((e) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16),
                          _title(Icon(Icons.pin_drop), 'Local'),
                          Padding(
                            padding: const EdgeInsets.only(left: 32),
                            child: Text(
                              '${e.local}',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context)
                                      .textTheme
                                      .caption
                                      ?.color),
                            ),
                          ),
                        ]))
                .toList());
      }
      return SizedBox();
    }

    bool _showAction = showAction != null ? (await showAction!(tarefa)) : false;
    Size? size = MediaQuery.maybeOf(context)?.size;
    showDialog(
        context: context,
        builder: (alertContext) => GestureDetector(
              onTap: () {
                Navigator.pop(alertContext);
              },
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: GestureDetector(
                  /// Captura os gestos feitos dentro do Scaffold, de modo a evitar que eles sejam transmitidos para baixo
                  /// Fazendo com que o alerta feche em qlq clique nele
                  onTap: () {},
                  child: AlertDialog(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(tarefa.titulo!),
                            Row(
                              children: [
                                Observer(builder: (_) {
                                  return Expanded(
                                    child: Text(
                                        '${tarefa.tipoTarefa?.nome != null ? '${tarefa.tipoTarefa!.nome!} - ' : ''}${UtilsTarefas.getStatus(tarefa.status)?.nome}',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .textTheme
                                                .caption
                                                ?.color)),
                                  );
                                }),
                              ],
                            )
                          ],
                        )),
                        IconButton(
                            onPressed: () {
                              Navigator.maybeOf(alertContext)?.pop();
                            },
                            tooltip: 'Fechar',
                            icon: Icon(Icons.close)),
                      ],
                    ),
                    content: Scrollbar(
                      isAlwaysShown: true,
                      child: SingleChildScrollView(
                        child: Container(
                          constraints: BoxConstraints(
                              minWidth: size!.width * .8 < 820
                                  ? size.width * 0.8
                                  : 800,
                              maxWidth: 820),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Data de criação: ${tarefa.dataCriacao.string('dd/MM/yyyy')}',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .caption
                                        ?.color),
                              ),
                              _getTextDeadLine(tarefa, context),
                              _buildTeam(tarefa, context),
                              SizedBox(height: 8),
                              LineWidget(
                                  padding:
                                      const EdgeInsets.only(top: 8, right: 8)),
                              _title(Icon(Icons.dashboard), 'Descrição'),
                              Padding(
                                padding: const EdgeInsets.only(left: 32),
                                child: Text(
                                  '${tarefa.descricao}',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .textTheme
                                          .caption
                                          ?.color),
                                ),
                              ),
                              _taskMachine(),
                              _taskLocation(),
                              _descricaoRequisicao(),
                              SizedBox(height: 16),
                              _buildTaskItens(tarefa),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _title(Icon(Icons.assignment), 'Observações'),
                                  if (updateObs != null)
                                    Observer(builder: (_) {
                                      if (tarefa.showInputObs) {
                                        return IconButton(
                                            onPressed: () {
                                              updateObs!(tarefa).then((value) {
                                                if (value) {
                                                  tarefa.showInputObs = false;
                                                }
                                              });
                                            },
                                            icon: Icon(Icons.done));
                                      }
                                      return IconButton(
                                          onPressed: () {
                                            tarefa.showInputObs = true;
                                          },
                                          icon: Icon(Icons.edit));
                                    })
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 32),
                                child: Observer(
                                  builder: (_) {
                                    if (updateObs != null &&
                                        tarefa.showInputObs) {
                                      return TextFormField(
                                          maxLength: 2000,
                                          controller: tarefa.ctlObs,
                                          decoration: InputDecoration(
                                              labelText: 'Observações'));
                                    }
                                    return Text('${tarefa.obs ?? ''}');
                                  },
                                ),
                              ),
                              _title(Icon(Icons.history), 'Histórico'),
                              _buildHistoryTask()
                            ],
                            mainAxisSize: MainAxisSize.min,
                          ),
                        ),
                      ),
                    ),
                    actions: (extraActions != null
                        ? extraActions!(alertContext, tarefa)
                        : [])
                      ..addAll([
                        if (_showAction)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: IconButton(
                                onPressed: () {
                                  Navigator.maybeOf(alertContext)?.pop();
                                  taskSelected(tarefa, () {
                                    controller.getNotifications();
                                  });
                                },
                                tooltip: 'Ir para a tela',
                                icon: Icon(Icons.arrow_forward_ios)),
                          ),
                      ]),
                  ),
                ),
              ),
            ));
  }

  showDialogResume(BuildContext context) {
    if (controller.taskDeadline.isEmpty) {
      showSnack(context, 'Nenhuma tarefa encontrada');
      return;
    }
    showDialog(
      context: context,
      builder: (alertContext) => AlertDialog(
          title: Text('Resumo das tarefas'),
          content: Wrap(
            children: controller
                .resumeMyTask()
                .map((e) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ButtonChip(
                        '${e.enumSumDaysTasks.getDescription()}: ${e.qtdTasks}',
                        onTap: () {
                          Navigator.pop(alertContext);
                          showDialogResumeDay(context, e);
                        },
                        textStyle: TextStyle(color: Colors.black87),
                        padding: const EdgeInsets.only(
                            top: 8, bottom: 8, left: 16, right: 16),
                      ),
                    ))
                .toList(),
          )),
    );
  }

  showDialogResumeDay(BuildContext context, SumDayTasks dayTasks) {
    showDialog(
        context: context,
        builder: (alertDialog) => AlertDialog(
              title:
                  Text('Resumo ${dayTasks.enumSumDaysTasks.getDescription()}'),
              content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: controller
                      .createResumeTaksDay(dayTasks.enumSumDaysTasks)
                      .map((e) => Padding(
                            padding: const EdgeInsets.all(2),
                            child: Text(
                              '- ${e.typeTask!.nome!.replaceAll('Tarefa de ', '')}: ${e.tasks!.length} tarefa(s)',
                            ),
                          ))
                      .toList()),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(alertDialog);
                    },
                    child: Text('Fechar'))
              ],
            ));
  }

  Widget _buildTeam(TarefaServidor tarefa, BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: 16),
      Text('Equipe'),
      SizedBox(height: 4),
      Observer(builder: (_) {
        Tooltip btAdd = Tooltip(
          message: 'Adicionar',
          child: InkWell(
            onTap: () {
              onAddTeam!(tarefa).then((value) {
                if (value != null) {
                  tarefa.team.add(value);
                }
              });
            },
            child: Padding(
                padding: const EdgeInsets.all(2),
                child: Container(
                    child: Icon(Icons.add, size: 12),
                    alignment: Alignment.center,
                    height: 30,
                    width: 30,
                    decoration: new BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.all(Radius.circular(24.0)),
                    ))),
          ),
        );
        if (tarefa.team.isEmpty) {
          if (onAddTeam == null) {
            return Text(
              'Nenhum membro adicionado',
              style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).textTheme.caption?.color),
            );
          }
          return btAdd;
        }

        return Wrap(
            children: tarefa.team.map((e) {
          String abrevPeople = 'E';
          try {
            if (e.peopleServer.name?.trim().isNotEmpty == true) {
              /// Caso contenha mais de um nome, pega a inicial do primeiro e último
              if (e.peopleServer.name!.contains(' ')) {
                abrevPeople =
                    '${e.peopleServer.name!.split(' ').first[0]}${e.peopleServer.name!.split(' ').last[0]}';
              } else if (e.peopleServer.name!.length > 1) {
                /// Caso contrário, tenta pegar a primeira e segunda letra
                abrevPeople =
                    '${e.peopleServer.name![0]}${e.peopleServer.name![1]}';
              } else if (e.peopleServer.name!.isNotEmpty) {
                // Em últmo caso, pega somente a primeira letra
                abrevPeople = e.peopleServer.name![0];
              }
            }
          } catch (error, stackTrace) {
            UtilsSentry.reportError(error, stackTrace);
          }
          return Tooltip(
            message: e.peopleServer.name ?? 'Sem nome',
            child: InkWell(
              onTap: onPeopleRemoved != null
                  ? () {
                      _showDialogRemovePerson(context, tarefa, e);
                    }
                  : null,
              child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Container(
                      child: Text(
                        abrevPeople.toUpperCase(),
                        style: TextStyle(fontSize: 11),
                      ),
                      alignment: Alignment.center,
                      height: 30,
                      width: 30,
                      decoration: new BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.all(Radius.circular(24.0)),
                      ))),
            ),
          );
        }).toList()
              ..addAll(onAddTeam != null ? [btAdd] : []));
      })
    ]);
  }

  void _showDialogRemovePerson(
      BuildContext context, TarefaServidor tarefa, PeopleTaskServer e) {
    showDialog(
        context: context,
        builder: (alertContext) => AlertDialog(
              title: Text('Por favor confirme'),
              content: Text(
                  'Deseja remover o funcionário ${e.peopleServer.name} da tarefa?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(alertContext);
                  },
                  child: Text('Não'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(alertContext);
                    onPeopleRemoved!(tarefa, e).then((value) {
                      if (value) {
                        tarefa.team.remove(e);
                        showSnack(context,
                            '${e.peopleServer.name} removido da tarefa');
                      }
                    });
                  },
                  child: Text('Sim'),
                )
              ],
            ));
  }
}
