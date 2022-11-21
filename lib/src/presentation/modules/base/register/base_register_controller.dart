import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:msk/src/data/data_access/local/sql/model.dart';
import 'package:msk/msk.dart';

import 'package:screenshot/screenshot.dart';

part 'base_register_controller.g.dart';

abstract class BaseRegisterController = _BaseRegisterController
    with _$BaseRegisterController;

abstract class _BaseRegisterController with Store {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @observable
  int statusEdition = BaseCadastroConst.REGISTRO_SALVAR;

  /// 1 = Salvar, 2 retornar objeto, 3 salvar dados servidor, 4 onAction
  @observable
  int typeRegister = 1;

  /// Indica se os dados devem ser salvos na base local ou enviados para um servidor externo
  bool saveLocalBase = true;

  /// Indica que é uma duplicata
  bool isDuplicate = false;

  ScreenshotController screenshotController = ScreenshotController();

  // Faz a inicialização dos dados
  Future initData(Map<String, dynamic>? map, String? tabela) async {
    assert(
        tabela == null ||
            app.estrutura.tabelas.any((element) =>
                element.nome == tabela && !element.endPoint.isNullOrBlank),
        'Tabela ${tabela} não adicionado endpoint');
    if (map != null) {
      typeRegister = (map['tipo'] ?? map['typeRegister'] ?? typeRegister);
      isDuplicate = (map['isDuplicate'] ?? false);

      if (map.containsKey('cod_obj') &&
          map['cod_obj'] != null &&
          tabela != null &&
          typeRegister != 3) {
        var obj = await loadFromDb(
            map['cod_obj'], tabela, map['columnPkObj'] ?? 'id');
        if (obj != null) {
          statusEdition = BaseCadastroConst.REGISTRO_DELETAR_ALTERAR;
        }
        await setDataControllers(obj);
      } else if (map.containsKey('obj') && map['obj'] != null) {
        var obj = map['obj'];
        if (obj != null) {
          statusEdition = BaseCadastroConst.REGISTRO_DELETAR_ALTERAR;
        }
        await setDataControllers(map['obj']);
      } else if (map.containsKey('obj_class') && map['obj_class'] != null) {
        var obj = map['obj_class'];
        if (obj != null) {
          statusEdition = BaseCadastroConst.REGISTRO_DELETAR_ALTERAR;
        }
        await setDataControllersObj(map['obj_class']);
      } else {
        statusEdition = BaseCadastroConst.REGISTRO_SALVAR;
      }
      statusEdition = map['statusEdicao'] ?? statusEdition;
    } else {
      statusEdition = BaseCadastroConst.REGISTRO_SALVAR;
    }

    /// Caso seja do tipo cadastro 2 (retornar) e seja uma edição, remove a possibilidade de deletar por padrão
    if (typeRegister == 2 &&
        statusEdition == BaseCadastroConst.REGISTRO_DELETAR_ALTERAR) {
      statusEdition = BaseCadastroConst.REGISTRO_ALTERAR;
    }

    if (isDuplicate) {
      statusEdition = BaseCadastroConst.REGISTRO_SALVAR;
    }
    return;
  }

  ///Carrega os dados do banco de dados conforme [pk], [tabela] e [colunaPk] especificadas
  Future<dynamic> loadFromDb(int? pk, String tabela, String columnPk) async {
    return (await AppDatabase()
            .execDataTable("select t.* from $tabela t where t.$columnPk = $pk"))
        .firstOrNull;
  }

  /// Faz a validação dos dados inseridos na tela
  /// Não sobreescrever essa função, usar validateData para validações
  Future<String?> validateDataForm() async {
    if (!formKey.currentState!.validate()) {
      return 'Por favor, verifique os dados incompletos';
    } else {
      String? msg = await validateData();
      if (msg != null) {
        return msg;
      }
      return validateDuplicateData();
    }
  }

  /// Sobreescrever para retornar uma lista de ModelValidationDuplicate
  /// Com lógicas para validação de duplicatas
  Future<List<ModelValidationDuplicate>> getValidationDuplicate() async {
    return [];
  }

  Future<String?> validateDuplicateData() async {
    try {
      final validations = await getValidationDuplicate();
      LocalDataStore store = GetIt.I.get<LocalDataStore>();
      for (final validation in validations) {
        int i = 1;
        if (store is LocalDataStoreSQL) {
          final String where = validation.fields.map((e) {
            if (e.applyLowerCase) {
              return 'LOWER(${e.field}) = \$${i++}';
            } else {
              return '${e.field} = \$${i++}';
            }
          }).join(' AND ');
          var res = await store.getDataMap(GetDataArgsSql(
              query: 'SELECT 1 FROM ${validation.table} t0 '
                  'WHERE t0.id <> ${validation.id ?? 0} AND t0.ISDELETED = 0 AND '
                  '$where',
              args: validation.fields.map((e) {
                if (e.applyLowerCase) {
                  return e.value.toString().toLowerCase().trim();
                } else {
                  return e.value;
                }
              }).toList()));
          if (res != null) {
            return validation.message;
          }
        }
      }
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
    }
    return null;
  }

  /// Setar os campos da tela com o [obj]
  Future setDataControllers(Map<String, dynamic>? obj) async {
    return;
  }

  /// Setar os campos da tela com o [obj]
  Future setDataControllersObj(dynamic obj) async {
    return;
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
  Future<String?> validateData();

  /// Validação dos dados com possibilidade de retorno customizado
  Future<ResultValidate> advancedValidateData() async {
    return ResultValidate(msg: null);
  }

  /// Método onde a persistência dos dados deve ser executada
  /// ```@override
  ///   Future<bool> saveData() async {
  ///     try {
  ///       /// Inicia uma transação no banco de dados
  ///       /// Isso é necessário especialmente quando existe o cadastro de mais de uma tabela de uma vez
  ///       /// Pois com isso, caso alguma delas apresente falha, é possível reverter os cadastros já realizados
  ///       /// Evitando assim dados incompletos na base
  ///       await AppDatabase().execSQL('BEGIN');

  ///       /// Invoca a função responsável por preencher os dados no objeto a partir do input da tela
  ///       await setValuesObj();

  ///       /// Realiza a persistência dos dados
  ///       /// Usar saveOrThrow() ao invés de save()
  ///       /// Para que caso exista algum problema ao salvar os dados, seja lançada uma exception
  ///       /// E seja feito o devido tratamento no catch
  ///       transportadora!.id = await transportadora!.saveOrThrow();

//       /// Caso todas as operações tenham sido realizadas com sucesso, faz o commit no banco de dados
//       return (await AppDatabase().execSQL('COMMIT')).success;
//     } catch (error, stackTrace) {
//       /// Caso ocorra alguma exception ao salvar os dados,
//       await AppDatabase().execSQL('ROLLBACK');

  ///       /// Faz o rollback da PK,
  ///       /// Caso tenha sido uma inserção que teve falha, torna o id null novamente
  ///       transportadora?.rollbackPk();

  ///       /// Reporta o erro ao Sentry
  ///       UtilsSentry.reportError(error, stackTrace);
  ///       return false;
  ///     }
  ///   }```
  Future<bool> saveData() async {
    return false;
  }

  Future<bool> saveDataServer() async {
    return false;
  }

  // Seta os dados nos objetos a partir dos controllers
  Future setValuesObj() async {
    return null;
  }

  Future<Map<String, List<int?>>> getIdObjs();

  /// Retorna um map com os registros, sendo a chave o nome da tabela
  /// A primeira do map tabela SEMPRE DEVE SER a principal
  Future<Map<String, dynamic>>? getMapObjs() {
    return null;
  }

  @Deprecated('Use initData instead')
  Future inicializarDados(Map<String, dynamic>? map, String? tabela) async {
    return initData(map, tabela);
  }

  @Deprecated('Use loadFromDb instead')
  Future<dynamic> carregarBanco(int? pk, String tabela, String columnPk) async {
    return loadFromDb(pk, tabela, columnPk);
  }

  @Deprecated('Use validateDataForm instead')
  Future<String?> verificarDadosForm() async {
    return validateDataForm();
  }

  @Deprecated('Use setDataControllers instead')
  Future setarDados(Map<String, dynamic>? obj) async {
    return setDataControllers(obj);
  }

  @Deprecated('Use setDataControllersObj instead')
  Future setarDadosCamposObj(dynamic obj) async {
    return setDataControllersObj(obj);
  }

  @Deprecated('Use validateData instead')
  Future<String?> verificarDados() {
    return validateData();
  }

  @Deprecated('Use saveData instead')
  Future<bool> salvarDados() async {
    return saveData();
  }

  @Deprecated('Use saveDataServer instead')
  Future<bool> salvarDadosServidor() async {
    return saveDataServer();
  }

  @Deprecated('Use setValuesObj instead')
  Future setarDadosObj() async {
    return setValuesObj();
  }

  @Deprecated('Use idObjs instead')
  Future<Map<String, List<int?>>> idRegistros() {
    return getIdObjs();
  }

  @Deprecated('Use getMapObjs instead')
  Future<Map<String, dynamic>>? registros() {
    return getMapObjs();
  }
}
