import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:msk/msk.dart';

part 'avaliar_app_controller.g.dart';

class AvaliarAppController = _AvaliarAppBase with _$AvaliarAppController;

abstract class _AvaliarAppBase with Store {
  /// As fotos adicionadas pelo usuário.
  final SeletorMidiaController ctlFotos = SeletorMidiaController();

  // O texto escrito pelo usuário como feedback.
  final TextEditingController ctlTextoFeedback = TextEditingController();

  /// O valor enum que define o grau de satisfação; entre 'muitoRuim', 'ruim', 'bom', 'muitoBom' e 'otimo'.
  @observable
  GrauSatisfacao avaliacao = GrauSatisfacao.bom;

  /// O valor enum que define qual é o tipo de feedback; entre 'sugestao', 'problema' e 'duvida'.
  @observable
  TipoFeedback tipoFeedback = TipoFeedback.sugestao;

  /// Verifica e retorna true se houve alguma modificação nos campos: [avaliacao], [ctlTextoFeedback.text] e [ctlFotos.midia].
  Future<bool> verificarDadosUpdate() async {
    if (avaliacao != GrauSatisfacao.bom ||
        ctlTextoFeedback.text.isNotEmpty ||
        ctlFotos.midia.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  /// Armazena o feedback e os arquivos anexados no bd do aparelho, posteriormente tenta enviá-los para o servidor[sendData].
  Future<void> envioDados() async {
    int? feedbackUsuarioId = await UtilsFeedback.saveFeedback(
        avaliacao.index, ctlTextoFeedback.text, tipoFeedback.index + 1);
    // Certifica-se de que houve o armazenamento do [GrauSatisfacao], [TipoFeedback] e texto, bem como se foi anexado alguma captura de tela, uma vez que é opcional.
    if (feedbackUsuarioId != null && ctlFotos.midia.isNotEmpty) {
      for (ItemMidia midia in ctlFotos.midia) {
        if (!midia.isDeleted) {
          await UtilsFeedback.saveArquivoFeedback(
              feedbackUsuarioId, midia.path);
        }
      }
    }
    UtilsSync.enviarDados();
  }
}

/// Determina valores enumerados [muitoRuim], [ruim], [bom], [muitoBom] e [otimo] para serem utilizados com as estrelas.
enum GrauSatisfacao { muitoRuim, ruim, bom, muitoBom, otimo }

/// Determina valores enumerados [sugestao], [problema] e [duvida] para serem utilizados na seleção do tipo de feedback dado pelo usuário.
enum TipoFeedback { sugestao, problema, duvida }
