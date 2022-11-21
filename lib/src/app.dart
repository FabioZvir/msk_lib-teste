import 'package:bloc_pattern/bloc_pattern.dart' as bp;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:msk/msk.dart';
import 'package:sqfentity/sqfentity.dart';

class App extends bp.Disposable {
  // Nome de exibição do App
  final String nome;
  // Id do App na AppStore, caso exista
  final String? appId;
  // Nome do package (identificador do app Android)
  final String package;
  // Definir um tema customizado
  final ThemeData? theme;
  // Função invocada ao processo de login ser concluído
  final LoginFinalizado loginFinalizado;
  // Objeto com a estrutura da sincronização
  final Sync estrutura;
  // Instancia do banco de dados
  final SqfEntityModelProvider dataBase;
  // Lista utilizada para zerar versões da sync das listas especificadas
  final List<ZerarVersaoSync>? zerarVersoesSync;
  // Serviço de autenticação, para apps que não sejam o Timber Track, usar AuthServiceBase
  final IAuthService authService;
  // Portas que o app deve usar para se conectar ao servidor na versão debug/release
  final Portas portas;
  // Endpoints para algumas ações específicas, quando estes diferem do padrão
  final EndPoints endPoints;
  // Callback invocado pelas funções do Firebase
  final Future<dynamic> Function(
      RemoteMessage remoteMessage, bool isbackground)? firebaseFunction;
  // Lista de menus padrão
  final List<MenusDefault> menusDefault;
  // Callback acionado pelas alterações na sync
  final Function(AuthState)? authStateChanges;

  /// Lista de que serão executadas somente uma vez após a instalação/atualização do app
  final List<RunQueryNextVersion>? querys;
  // Indica se o módulo padrão do firebase está disponível e inicializado na sessão corrente
  bool? firebaseIsInitialize;

  final bool enableExperimentalSizeScreen;

  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey(debugLabel: "Main Navigator");

  /// Indica que o app já foi migrado para a estrutura uniqueKey
  final bool migratedApp;

  /// Indica o nome do arquivo executável no windows
  /// sem a extensão
  final String nameExe;

  /// Indica se a sync por registros específicos está ativada para o app
  final bool enableSpecifySync;

  App(this.nome, this.package, this.estrutura, this.dataBase, this.authService,
      this.portas, this.loginFinalizado, this.nameExe,
      {this.appId,
      this.theme,
      this.zerarVersoesSync,
      this.endPoints = const EndPoints(Constants.END_POINT_SYNC_V2,
          Constants.END_POINT_MENU, Constants.END_POINT_TOKEN),
      this.firebaseFunction,
      this.querys,
      this.menusDefault = const [
        MenusDefault(codMenu: 128, menu: MenusDefaultEnum.SAIR),
        MenusDefault(codMenu: 127, menu: MenusDefaultEnum.DEV),
      ],
      this.firebaseIsInitialize,
      this.enableExperimentalSizeScreen = false,
      this.authStateChanges,
      this.migratedApp = true,
      this.enableSpecifySync = false}) {
    if (!estrutura.tabelas
            .any((element) => element.nome == 'RegistroAtividade') &&
        !estrutura.tabelas
            .any((element) => element.nome == 'RegistroAtividades')) {
      estrutura.tabelas.add(Tabela('RegistroAtividade',
          endPoint: 'api/servicos/cadastro/lista/log/geral'));
    }
    if (!estrutura.tabelas
        .any((element) => element.nome == 'ArquivoRegistroAtividade')) {
      estrutura.tabelas.add(Tabela(
        'ArquivoRegistroAtividade',
        arquivos: [ColumnFileServer('path', 'arquivo')],
        endPoint: 'api/servicos/cadastro/lista/log/geral/arquivo',
        fks: [FK('registroAtividade', 'RegistroAtividade', obrigatoria: true)],
      ));
    }
    if (!estrutura.tabelas
        .any((element) => element.nome == 'FeedbackUsuario')) {
      estrutura.tabelas.add(Tabela('FeedbackUsuario',
          endPoint: 'api/servicos/cadastro/lista/feedback'));
    }
    if (!estrutura.tabelas
        .any((element) => element.nome == 'ArquivoFeedback')) {
      estrutura.tabelas.add(Tabela(
        'ArquivoFeedback',
        endPoint: 'api/servicos/cadastro/lista/feedback/arquivo',
        fks: [FK('feedbackUsuario', 'FeedbackUsuario', obrigatoria: true)],
        arquivos: [
          ColumnFileFirebase('path', 'url', (data) async {
            /// Retorna o path do firebase
            return "Feedbacks/${data['uniqueKey']}" +
                "/${UtilsFileMSK.getFileName(data['path']) ?? '${DateTime.now().millisecondsSinceEpoch}'}";
          })
        ],
      ));
    }
    if (firebaseIsInitialize == null) {
      firebaseIsInitialize =
          !(UtilsPlatform.isWindows || UtilsPlatform.isLinux);
    }
    IAuthService.authStateChanges = (AuthState authState) async {
      authStateChanges?.call(authState);
      if (authState.authStateEnum == AuthStateEnum.LOGIN) {
        API.invalidToken = false;
        UtilsFirebaseMessaging.saveTokenNewUser();
      } else if (authState.authStateEnum == AuthStateEnum.LOGOUT) {
        API.invalidToken = true;
        bool b = authState.checkUpData
            ? (await UtilsSync.checkUpDataLogout())
            : true;
        if (b) {
          await UtilsFirebaseMessaging.clearToken();
          AppBaseModule.to.bloc<MenuController>().menusCarregados = false;
          AppBaseModule.to.bloc<MenuController>().menus.clear();
          Box box = await hiveService.getBox('sync');
          await box.clear();

          /// Limpa dados do menu
          await (await hiveService.getBox(Constants.MENU_BOX_NAME)).clear();
        } else
          return false;
      } else if (authState.authStateEnum == AuthStateEnum.TOKEN_401) {
        API.invalidToken = true;
      }

      return true;
    };
  }

  @override
  void dispose() {}
}

IAuthService authService = GetIt.I.get<App>().authService;

App app = GetIt.I.get<App>();

typedef LoginFinalizado = void Function(BuildContext);

enum MenusDefaultEnum { SAIR, DEV }

class MenusDefault {
  final int codMenu;
  final MenusDefaultEnum menu;
  const MenusDefault({required this.codMenu, required this.menu});
}
