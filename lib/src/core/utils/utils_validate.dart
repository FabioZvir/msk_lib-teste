import 'package:cpf_cnpj_validator/cnpj_validator.dart';
import 'package:cpf_cnpj_validator/cpf_validator.dart';
import 'package:msk/msk.dart';

class UtilsValidate {
  static bool validateData(String tableName, Map<String, dynamic> data) {
    Tabela? table = app.estrutura.tabelas
        .firstWhereOrNull((element) => element.nome == tableName);
    if (table == null || table.fks?.isNotEmpty != true) {
      return true;
    }
    for (FK fk in table.fks!) {
      if (fk.obrigatoria == true) {
        if (data['${fk.coluna}_id'] == null || data['${fk.coluna}_id'] == 0) {
          UtilsLog.saveLog(
              UtilsLog.REGISTRO_ATIVIDADE_FALHA_SALVAR_DADOS,
              'FK ${fk.coluna}:${data['${fk.coluna}_id']}, dados: $data',
              tableName);
          throw ('Validação com falha: Coluna ${fk.coluna} obrigatória ${data['${fk.coluna}_id']}, dados: $data, usuario: ${authService.user?.id}');
        }
      }
    }
    return true;
  }

  static bool validateCPFCNPJ(String text) {
    return CPFValidator.isValid(text) || CNPJValidator.isValid(text);
  }
}
