# Msk Lib
Este README destina-se a documentar instruções de procedimentos comuns durante o trabalho com os apps, como estruturações, adição de funcionalidades, versionamento e deploy.

## Antes de começar
Para que seja possível executar os projetos em sua máquina, é necessário primeiramente preparar o ambiente.
- Baixe e instale o Flutter na versão 2.10.4 e todos os softwares que são requisito do mesmo (Android Studio, Xcode, Visual Studio, etc). Ao final, execute o comando `flutter doctor --android-licenses` para validar a instalação.
- Baixe e configure seu github. Por utilizarmos bibliotecas privadas (como esta) nos projetos, precisamos configurar nosso SHH no github para conseguirmos utilizar de forma segura as bibliotecas. Verifique a documentação oficial de como fazer isso em https://docs.github.com/pt/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account.
- Baixe o projeto https://github.com/aynova-tecnologia/scripts e deixe em uma pasta acessível publicamente.

## Resumo
Esta biblioteca destina-se a conter código compartilhado entre as aplicações da Aynova, contendo módulos de autenticação, sincronização de dados, versionamento do app, entre outros.

Para adicionar essa biblioteca em uma nova aplicação, você deve adicionar a arvore de widgets o módulo AppBaseWidget da seguinte forma:

```
Future<void> main() async {
  await initDependencies();
  WidgetsFlutterBinding.ensureInitialized();
  runZonedGuarded<Future<void>>(() async {
    runApp(AppBaseModule(getApp));
    UtilsSentry.configureSentry();
  }, UtilsSentry.reportError);
}


App get getApp => App(
      'Compras', // Nome do App
      'br.com.aynova.compras2', // Nome do Pacote
      getEstrutura(), // Estrutura da sync (Classe Sync())
      AppDatabase(), // Banco de dados (gerado por sqfentity)
      AuthServiceBase(
          package: 'br.com.aynova.compras2',
          iAuthNetwork: AuthNetworkDio(() => Constants.BASE_URL + getPorta()),
          iPersistDataStorage: UtilsPlatform.isMobile
              ? PersistDataStorageSecure()
              : PersistDataStorageHive(),
          logAuth: (_) {},
          sendConfirmToken: false),
      Portas(Constants.PORTA_DEBUG, Constants.PORTA_RELEASE),
      (BuildContext context) {
        // Função acionada ao login ser finalizado
        // Chamar a tela de home
        Navigator.maybeOf(context)?.pushReplacement(new MaterialPageRoute(
            builder: (BuildContext context) => HomeModule()));
      },
      'compras_flutter',
      migratedApp: true,
      zerarVersoesSync: [],
      querys: [],
      enableSpecifySync: true,
      firebaseFunction: messageHandler,
      endPoints: const EndPoints(Constants.END_POINT_SYNC_V2,
          Constants.END_POINT_MENU, Constants.END_POINT_TOKEN),
    );

/// lib/app/core/di/injection_container.dart
final get = GetIt.instance;

initDependencies() {
  get.registerSingleton<LocalDataStore>(LocalDataStoreSQL());
  get.registerSingleton<DataSourceProductsSelect>(
      DataSourceProductsSelectSql());
}


```

### Como usar as bibliotecas
Para realizar testes na biblioteca e utilizar o código localmente, você deve fazer o clone dela e apontar o path para o caminho onde ela estiver localizada. Por exemplo:
```
midia_select:
  path: "C:/Users/reni/Downloads/Projetos/flutter/libs/midia_select"
```

As bibliotecas usadas a partir do GitHub usam um modelo diferente de versionamento, sendo necessário especificar o commit que deseja ser usado.
Depois de alterada/testada a biblioteca, você deve subir as alterações para o GitHub, capturar o commit da alteração e atualizar a dependencia, como no exemplo:

```
midia_select:
    git:
      url: https://github.com/ReniDelonzek/midia_select.git
      ref: 0c61132fd65a9351d90ed6fa721f946b71fa81b4
```

Sempre que possível utilize as bibliotecas nas suas versões mais recentes para incluir correções e features. Em algumas atualizações algumas interfaces são alteradas, portanto podem ser necessários atualizações no código do aplicativo após atualizar alguma biblioteca. Um exemplo é ter que migrar as interfaces de cadastro (migrar de BaseCadastroController para BaseRegisterController) e atualizar as funções/variáveis para a nova classe. O fluxo de funcionamento permanece exatamente o mesmo, a única alteração são os nomes que foram alterados de PT para EN.

## Estrutura
A estrutura utilizada nos projetos foi sendo melhorada conforme a evolução do projeto. Inicialmente, por conta do escasso material disponível para Flutter e pouca clareza sobre definições de estrutura, foi adotado o padrão de módulos proposto na cli [Slidy](https://pub.dev/packages/slidy).

Recentemente os projetos foram migrados em quase totalidade para seguir as regras do clean architecture, baseado em https://github.com/ResoCoder/flutter-tdd-clean-architecture-course. Você pode ver mais detalhes sobre a estrutura neste curso gratuito https://resocoder.com/flutter-clean-architecture-tdd/.

## Home page

A home page é a página principal do aplicativo, nela você adiciona os menus que encaminham o usuário para telas de cadastro ou relatórios por exemplo

```

class HomePage extends StatefulWidget {
  final String title;
  const HomePage({Key? key, this.title = "Bem Vindo"}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<MenuItem> menus = [];

  @override
  void initState() {
    super.initState();
    /// Exemplo de menu de cadastro
    menus.addAll([
      MenuItem(titulo: 'Cadastro', subMenus: [
        MenuItem(
            codSistema: 208,
            titulo: 'Avaliações',
            acao: ActionSelect(
              page: () => SelectAnyModule(SelectModel(
                  'Avaliações',
                  'id',
                  [
                    Line('empreiteira_nome',
                        name: 'Empreiteira', enclosure: 'Empreiteira: ???'),
                    Line('data', typeData: TDDateTimestamp()),
                    Line('equipe_nome',
                        name: 'Equipe', enclosure: 'Equipe: ???')
                  ],
                  FontDataDatabase((_) async =>
                      'select t0.*, e.nome as empreiteira_nome, ee.nome as equipe_nome from Avaliacao t0 '
                      'inner join empreiteira e on e.id = t0.empreiteira_id '
                      'left join equipeEmpreiteira ee on ee.id = t0.equipeEmpreiteira_id '
                      'where t0.isDeleted = 0 and t0.operacional = 0 '
                      'order by ifnull(t0.data, 0) desc'),
                  TypeSelect.ACTION,
                  actions: [
                    ActionSelect(
                        description: 'Ver detalhes',
                        icon: Icon(Icons.dashboard),
                        page: () => ResultadoAvaliacaoModule())
                  ],
                  buttons: [
                    ActionSelect(
                        description: 'Nova Avaliação',
                        icon: Icon(Icons.add),
                        page: () => CadastroAvaliacaoModule(false))
                  ])),
            )),
      ])
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            IconButton(
              icon: Icon(Icons.arrow_upward),
              tooltip: 'Enviar para o servidor',
              onPressed: () async {
                if (await UtilsSync.enviarDados()) {
                  showSnack(context, 'Sincronização concluída com sucesso');
                } else {
                  showSnack(
                      context, 'Ops, houve uma falha ao sincronizar os dados');
                }
              },
            ),
            IconButton(
              tooltip: 'Sincronizar dados',
              icon: Icon(Icons.sync),
              onPressed: () async {
                showSnack(context, 'Sincronizando dados...');
                var res = await AtualizarDados().sincronizar();
                if (res == ResultadoSincLocal.FALHA) {
                  showSnack(
                      context, 'Ops, houve uma falha ao sincronizar os dados');
                } else if (res == ResultadoSincLocal.EXECUTANDO) {
                  showSnack(
                      context, 'Já existe uma sincronização em andamento');
                } else {
                  showSnack(context, 'Dados sincronizados com sucesso');
                }
              },
            )
          ],
        ),
        // Adiciona o Drawer já construído para os apps
        drawer: MenuDrawerWidget(context, menus),
        // Adiciona o widget de menus favoritos na tela
        body: UtilsPlatform.isDesktop
            ? Align(
                alignment: Alignment.bottomCenter,
                child: MenuFavoritoWidget(context, menus: menus))
            : Align(
                alignment: Alignment.topCenter,
                child: MenuFavoritoWidget(context, menus: menus)));
  }
}
```

### Adicionando menus
Para adicionar um novo menu, basta incluí-lo dentro da lista de menus, como um menu principal ou um submenu. É permitido somente um nível de submenus, ou seja, um menu principal e dentro dele os menus não podem ter mais ramificações. Para obter o código do sistema de forma a identificar o mesmo, deve ser feita uma consulta ao responsável do banco de dados.



## Cadastros 
As telas de cadastro em sua maioria seguem um padrão estendendo classes base onde já existe várias funções utilitárias para serem utilizadas.
Durante a evolução do projeto, vários maneiras diferentes de realizar a persistência dos dados. Abaixo, seguem os modelos mais recentes do controlador e da pagina.

### Controller -> BaseRegisterController
#### Modelo mais comum e antigo
Este modelo é o mais utilizado, ele segue um fluxo sólido de e idêntico ao fluxo mais recente, e foi alterado pois não permite aplicar testes completos, além de quebrar algumas regras do clean architecture.

```
import 'package:flutter/widgets.dart';
import 'package:mobx/mobx.dart';
import 'package:msk/msk.dart';
import 'package:timber_cargo/app/data/datastore/local/sql/model.dart';

part 'cadastro_transportadora_controller.g.dart';

class CadastroTransportadoraController = _CadastroTransportadoraBase
    with _$CadastroTransportadoraController;

abstract class _CadastroTransportadoraBase extends BaseRegisterController
    with Store {
  /// Mantém uma instância global da tabela editada
  TransportadoraAuxiliar? transportadora;

  /// Controladores
  final TextEditingController ctlNome = TextEditingController();
  final TextEditingController ctlNomeFantasia = TextEditingController();
  final TextEditingController ctlCnpj = TextEditingController();

  // Aqui também são declaradas as variáveis observáveis (@observable) e computadas (@computed)

  _CadastroTransportadoraBase();

  /// Função usada para setar dados recebidos a partir da rota para os controllers da tela
  /// Veja também setDataControllersObj() para receber objetos como parâmetro, caso necessário
  @override
  Future setDataControllers(Map<String, dynamic>? obj) async {
    if (obj != null) {
      transportadora = TransportadoraAuxiliar.fromMap(obj);
      if (transportadora != null) {
        ctlNome.text = transportadora!.nome.toString();
        ctlNomeFantasia.text = transportadora!.nomeFantasia.toString();
        ctlCnpj.text = transportadora!.cnpj.toString();
      }
    }
    return;
  }

  /// Retorna um Map onde as keys são TODAS as tabelas alteradas
  /// Tendo uma lista com os ids dos registros (pode ser null)
  /// Usado para deleção de dados
  @override
  Future<Map<String, List<int?>>> getIdObjs() async {
    return {
      "TransportadoraAuxiliar": [transportadora?.id]
    };
  }

  /// Retorna um map com TODOS os objetos das tabelas editadas
  /// Usado para retorar dados para tela anterior e afins
  @override
  Future<Map<String, dynamic>>? getMapObjs() async {
    return {"TransportadoraAuxiliar": transportadora};
  }

  /// Validação dos dados
  /// Retorne a mensagem de erro que será exibida ao usuário
  /// Ou null, caso os dados estejam todos corretos
  /// Exemplo:
  ///
  /// ```Future<String?> validateData() async {
  ///   if (ctlName.text.trim().isEmpty) {
  ///     return 'Por favor, insira o nome';
  ///   }
  ///   return null;
  /// }```
  @override
  Future<String?> validateData() async {
    return null;
  }

  /// Seta os dados nos objetos a partir dos controllers
  @override
  Future<void> setValuesObj() async {
    transportadora ??= TransportadoraAuxiliar();
    transportadora!.nome = ctlNome.text;
    transportadora!.nomeFantasia = ctlNomeFantasia.text;
    transportadora!.cnpj = ctlCnpj.text;
  }

  /// Persiste os dados no banco/servidor
  @override
  Future<bool> saveData() async {
    try {
      /// Inicia uma transação no banco de dados
      /// Isso é necessário especialmente quando existe o cadastro de mais de uma tabela de uma vez
      /// Pois com isso, caso alguma delas apresente falha, é possível reverter os cadastros já realizados
      /// Evitando assim dados incompletos na base
      await AppDatabase().execSQL('BEGIN');

      /// Invoca a função responsável por preencher os dados no objeto a partir do input da tela
      await setValuesObj();

      /// Realiza a persistência dos dados
      /// Usar saveOrThrow() ao invés de save() 
      /// Para que caso exista algum problema ao salvar os dados, seja lançada uma exception
      /// E seja feito o devido tratamento no catch
      transportadora!.id = await transportadora!.saveOrThrow();

      /// Caso todas as operações tenham sido realizadas com sucesso, faz o commit no banco de dados
      return (await AppDatabase().execSQL('COMMIT')).success;
    } catch (error, stackTrace) {
      /// Caso ocorra alguma exception ao salvar os dados, 
      await AppDatabase().execSQL('ROLLBACK');

      /// Faz o rollback da PK, 
      /// Caso tenha sido uma inserção que teve falha, torna o id null novamente
      transportadora?.rollbackPk();

      /// Reporta o erro ao Sentry
      UtilsSentry.reportError(error, stackTrace);
      return false;
    }
  }
}
```
Tela de cadastro modelo mais recente. Este modelo é gerado pelo gerador de códigos (project_x).

```
import 'package:flutter/widgets.dart';
import 'package:mobx/mobx.dart';
import 'package:msk/msk.dart';

part 'register_transportadora_controller.g.dart';

class RegisterTransportadoraController = _RegisterTransportadoraBase with _$RegisterTransportadoraController;

abstract class _RegisterTransportadoraBase extends BaseRegisterController with Store {
  /// Usa um usecase para persistir os dados
  final TransportadoraUseCase useCase = TransportadoraUseCase(repository: get.get());
  /// Usa uma classe base para manter os modelos na memória 
  TableEntityBase<Transportadora>? baseEntity;

  // Controladores
  final TextEditingController ctlNome = TextEditingController();
  final TextEditingController ctlNomeFantasia = TextEditingController();
  final TextEditingController ctlCnpj = TextEditingController();
  

  @override
  Future setDataControllers(Map<String, dynamic>? obj) async {
    if (obj != null) {
      baseEntity = TableEntityBase(model: Transportadora.fromMap(obj));
        ctlNome.text = baseEntity!.model.nome?.toString() ?? '';
      ctlNomeFantasia.text = baseEntity!.model.nomeFantasia?.toString() ?? '';
      ctlCnpj.text = baseEntity!.model.cnpj?.toString() ?? ''; 
    }
    return;
  }


  @override
  Future<Map<String, List<int?>>> getIdObjs() async {
    return {"Transportadora": [baseEntity?.model.id]};
  }

  @override
  Future<Map<String, dynamic>> getMapObjs() async {
    return {"Transportadora": baseEntity?.model};
  }

  @override
  Future<String?> validateData() async {
   return null;
  }

  @override
  Future<void> setValuesObj() async {
    baseEntity ??= TableEntityBase(model: Transportadora());
    baseEntity!.model.nome = ctlNome.text;
    baseEntity!.model.nomeFantasia = ctlNomeFantasia.text;
    baseEntity!.model.cnpj = ctlCnpj.text;

  }

  /// Realiza as operações no banco através do usecase
  @override
  Future<bool> saveData() async {
    try {
      await useCase.repository.startTransaction();
      await setValuesObj();
      baseEntity!.model.sync = true;
      baseEntity!.model.id = await useCase.save(baseEntity!);
      
      return await useCase.repository.commitTransaction();
    } catch (error, stackTrace) {
      await useCase.repository.rollbackTransaction();
      useCase.repository.rollbakEntity(baseEntity!);
      
      UtilsSentry.reportError(error, stackTrace);
      return false;
    }
  }

}
```


### Page -> BaseRegisterPage
O arquivo responsável por desenhar o layout da página


```class RegisterClassificacaoDAPPage extends StatefulWidget {
  const RegisterClassificacaoDAPPage(
      {Key? key})
      : super(key: key);

  @override
  _RegisterClassificacaoDAPPageState createState() =>
      _RegisterClassificacaoDAPPageState();
}

class _RegisterClassificacaoDAPPageState
    extends BaseRegisterPage<RegisterClassificacaoDAPPage> {
  final RegisterClassificacaoDAPController _controller =
      RegisterClassificacaoDAPModule.to
          .bloc<RegisterClassificacaoDAPController>();

  /// Importante inicializar essas variáveis no construtor
  _RegisterClassificacaoDAPPageState() {
    controller = _controller;
    title = "Cadastrar Classificacao DAP";
    table = "ClassificacaoDAP";
    customContentSaveMessage =
        () async => Text('Atenção! Os dados não podem ser alterados depois');
  }

  /// Usar o método buildInterface no lugar do build
  /// Ele é responsável por acrescentar elementos importantes na arvore de widgets
  /// Como um Form, o botão de Salvar, Actions, etc.
  @override
  Widget buildInterface(BuildContext context) {
    return Column(
      children: <Widget>[
        InputTextField(
          controller: _controller.ctlNomeAlternativo,
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: "Nome Alternativo (Opcional)"),
          maxLength: 40,
        ),
        InputTextField(
          controller: _controller.ctlDiametroMinimo,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          textCapitalization: TextCapitalization.sentences,
          inputFormatters: [
            inputFormatterDecimal(maxDigits: 3, decimalPlaces: 1)
          ],
          decoration: InputDecoration(labelText: "Insira o Diâmetro Mínimo"),
          validator: (text) {
            if (text.isNullOrBlank) {
              return 'Você precisa inserir o Diâmetro Mínimo';
            } else
              return null;
          },
        ),
        InputTextField(
          controller: _controller.ctlDiametroMaximo,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: "Insira o Diâmetro Máximo"),
          inputFormatters: [
            inputFormatterDecimal(maxDigits: 3, decimalPlaces: 1)
          ],
          validator: (text) {
            if (text.isNullOrBlank) {
              return 'Você precisa inserir o Diâmetro Máximo';
            } else
              return null;
          },
        ),
        SelecionarDataWidget('Data Inicio', _controller.ctlDataInicio,
            dateMin: DateTime.now(),
            defaultTimeOfDay: TimeOfDay(hour: 0, minute: 0)),
        SelecionarDataWidget('Data Fim (Opcional)', _controller.ctlDataFim,
            dateMin: DateTime.now()),
        SelectFKWidget(
            'Selecione o Cliente',
            'id',
            [
              Line('nome'),
              Line('cpfCnpj', name: 'CPF/CNPJ', enclosure: 'CPF/CNPJ: ???')
            ],
            _controller.ctlCliente,
            FontDataDatabase((data) async =>
                'select * from Cliente where isDeleted = 0 '
                'order by CASE WHEN idserver = -2 THEN 1 else 2 end, nome')),
        SelectFKWidget(
            'Selecione a Unidade de Medida',
            'id',
            [Line('nome')],
            _controller.ctlUnidadeMedida,
            FontDataDatabase((data) async =>
                'select * from UnidadeMedida where isDeleted = 0 and idServer in (${UtilsRomaneio.ROMANEIO_CUBICO}, ${UtilsRomaneio.ROMANEIO_ESTEREO}, ${UtilsRomaneio.ROMANEIO_TONELADA}) '
                'order by CASE WHEN idserver = -2 THEN 1 else 2 end, nome')),
      ],
    );
  }
}
```

## Criar nova tabela
Para a adição de novas tabelas, é necessário adicionar ela ao schema do banco de dados e da sync

### Banco de dados
1. Localize o arquivo model.dart (normalmente localizado em lib\app\data\datastore\local\sql\model.dart), e acrescente uma nova tabela como o exemplo abaixo.
```
const veiculoTransportadora = SqfEntityTable(
    tableName: 'VeiculoTransportadora',
    primaryKeyName: 'id',
    primaryKeyType: PrimaryKeyType.integer_auto_incremental,
    useSoftDeleting: true,
    fields: [
      SqfEntityField('nome', DbType.text),
      SqfEntityField('placa', DbType.text),
      SqfEntityField('tipo', DbType.integer),
      SqfEntityFieldRelationship(
          fieldName: 'transportadora_id',
          parentTable: transportadora,
          deleteRule: DeleteRule.CASCADE,
          defaultValue: '0'),
    ]);
 ```

2. Adicione a tabela criada na lista de `databaseTables` dentro de `SqfEntityModel` no final do arquivo.
3. Rode o comando de geração de arquivos (`flutter pub run build_runner build --delete-conflicting-outputs`).

### Sync
1. Localize o arquivo sync.dart (geralmente localizado em lib\app\core\utils\sync.dart).
2. Insira a tabela na lista como no exemplo.  
```
    Tabela('VeiculoTransportadora',
        /// Caso tenha cadastro, insira o endpoint
        endPoint: 'api/servicos/cadastro/lista/transportadora/veiculo',
        /// Caso seja usada na sincronização, adicione a lista
        lista: 'veiculosTransportadora',
        fks: [
          /// Lista com todas as FKs, onde o primeiro parâmetro é o nome da coluna (sem o _id)]
          /// O segundo é o nome da tabela, e o terceiro (obrigatoria) indica se a coluna é obrigatória ou não
          /// Sendo aplicadas validações durante a sincronização e cadastro de colunas obrigatórias
          FK('transportadora', 'Transportadora', obrigatoria: true),
    ]),
 ```
A tabela deve ficar sempre APÓS as tabelas na qual ela tem dependência. Por exemplo a tabela VeiculoTransportadora possui a FK transportadora, então a tabela Transportadora deve ficar ANTES da tabela VeiculoTransportadora.
Caso a tabela esteja com uma ordenação errada, será impresso um log no console como 'Tabelas com problemas: xxx' durante o processo de sincronização no modo debug.

## Versionamento
Todos os repositórios são mantidos no github na conta oficial da empresa.
É utilizado o gitflow como fluxo de versão, tendo sempre a branch dev mais atualizada.

## Deploy
Para realizar o envio de uma nova versão os passos são os seguintes.
1. Depois de validadas todas as alterações, realize o commit e siga os processos de versionamento descritos acima.
2. Atualize a versão do pubspeck.yaml. O padrão utilizado é manter o version_code identico a version, como por exemplo `version: 24.6.0+246` vai virar `version: 24.7.0+247`.

### Android
1. Rode `flutter build appbundle`
2. Acesse https://play.google.com/console/u/0/developers/6168816167406086706/app-list?hl=pt-br e selecione o app em questão (Você pode certificar qual é pelo package).
3. Dentro da aba versões do menu lateral, clique em Produção -> Criar nova versão e siga os passos indicados.


### IOS
1. Abra o projeto no Xcode.
2. Dentro do navegador do projeto, selecione Runner na aba General.
3. Atualize tanto a Version quanto o build, seguindo o padrão existente (por exemplo, Version 14.6 vai para version 14.7 e o Build vai de 146 para 147).
4. Caso o produto não esteja assinado, vá para Signing & Capabilities e dentro de Signing selecione o Team Agro Florestal Sepac LTDA. Esse processo só precisa ser feito caso o app não esteja assinado ainda, geralmente é necessário fazer isso uma vez por máquina.
5. Caso não esteja selecionado, na aba de devices, selecione o device genérico.
6. Vai em Product -> Archive para gerar um novo IPA, siga as instruções da tela para finalizar o processo.
7. Em https://appstoreconnect.apple.com/apps siga as instruções para criar uma nova versão do app.

### Windows
1. Localize e copie a localização do arquivo up_windows_version.dart disponível no repositório de scripts da agro.
2. Abra o terminal na pasta do projeto e rode o seguinte comando `dart run C:\Users\reni\Desktop\up_windows_version.dart ; flutter build windows --profile ; cd build\windows\runner\Profile ; tar -caf ..\Profile.zip . ; cd ..\..\..\..\ ; flutter build windows --release ; cd build\windows\runner\Release ; tar -caf ..\Release.zip . ; cd ..\..\..\..\ ; start build\windows\runner` substituindo C:\Users\reni\Desktop\up_windows_version.dart pelo caminho do arquivo copiado na etapa anterior.
- Este utilitário dart atualiza a versão do Windows necessário para verificar atualizações. Com as versões mais recentes do Flutter a própria CLI dele faz o trabalho, porém isso não está disponível na versão corrente do projeto (2.10.4). Também é possível atualizar manualmente o arquivo windows/runner/Runner.rc em VERSION_AS_NUMBER e VERSION_AS_STRING.
3. Quando o buid finalizar, o explorador de arquivos será aberto e nele terá um zip nomeado Release.zip, este arquivo deverá ser enviado para o servidor através do aplicativo msk_developers no menu Cadastrar Versão App.



## Remover colunas banco
O sqlite não dispõem de uma maneira eficiente de remover colunas no banco de dados, sendo necessário criar tabelas temporárias replicando a estrutura, realizando o drop e depois recriando a tabela sem a coluna em questão.
Por esse motivo, não fazemos a remoção das colunas nas aplicações, apenas removes do schema do banco de dados e marcamos ela para ser ignorada na sync. Exemplo:

```
Tabela("MovimentacaoProduto",
        lista: "movimentacoesProduto",
        fks: [
          FK("movimentacao", "Movimentacao", obrigatoria: true),
          FK("unidadeMedidaProdutoMovimentacao", "UnidadeMedidaProduto"),
          FK("unidadeMedidaProdutoPrincipal", "UnidadeMedidaProduto"),
          FK("codigoFiscal", "CodigoFiscal"),
          FK("localDivisaoAlmoxarifadoEmpresa",
              "LocalDivisaoAlmoxarifadoEmpresa")
        ],
        colunasIgnoradas: [
          "comprimento",
          "codTipoMovimento",
          'localDivisao',
          'divisaoAlmoxarifadoEmpresa_id',
          'codDivisaoAlmoxarifadoEmpresa'
        ],
        endPoint: 'api/compras/cadastro/lista/movimentacao/produto'),
```

No exemplo acima, várias colunas são ignoradas, entre elas estão FKs, para esse tipo de coluna, quando ela já existe na base do app, tanto {nome-fk}_id quanto cod{nome-fk} (como divisaoAlmoxarifadoEmpresa no exemplo) devem ser especificadas para ser ignoradas.
Em casos onde a coluna sequer foi adicionada no banco, mas por algum motivo retorna na sync (como em casos de classes reaproveitadas no servidor por exemplo), somente cod{nome-fk} já é o suficiente (como codTipoMovimento no exemplo).



## Erros comuns
- Target of URI doesn't exist: 'package:blue_thermal_printer/'.
Try creating the file referenced by the URI, or Try using a URI for a file that does exist.
1. Este erro ocorre por conta de uma má configuração de uma biblioteca utilizada, este porém não afetando seu uso, podendo executar a aplicação sem problemas. (Você pode ver mais detalhes do problema aqui https://github.com/kakzaki/blue_thermal_printer/issues/108).

- Crash no Android pela notificação
1. Problema ocasionado em alguns dispositivos pela biblioteca de notificações. Seguir https://github.com/MaikuB/flutter_local_notifications/issues/220


- A CupertinoLocalizations delegate that supports the pt_BR locale was not found.
1. Falta de configuração do Cupertino no delegate do MaterialApp. Atualize a versão dessa lib para resolver.

- The plugin camera_android requires a higher Android SDK version.
1. Atualize a minSdkVersion para 21 em `android\app\build.gradle`:                               │
│ android {                                                                                                  │
│   defaultConfig {                                                                                          │
│     minSdkVersion 21                                                                                       │
│   }                                                                                                        │
│ }                                                                                                          │