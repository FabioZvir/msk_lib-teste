import 'package:msk/msk.dart';
import 'package:msk/src/data/data_access/local/sql/model.dart';

class UtilsFeedback {
  static Future<int?> saveFeedback(
      int avaliacao, String texto, int tipoFeedback) async {
    FeedbackUsuario feedbackUsuario = FeedbackUsuario();
    feedbackUsuario.avaliacao = avaliacao;
    feedbackUsuario.texto = texto;
    feedbackUsuario.tipoFeedback = tipoFeedback;
    feedbackUsuario.package = app.package;
    try {
      return feedbackUsuario.saveOrThrow();
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
    }
    return null;
  }

  static Future<bool> saveArquivoFeedback(
      int feedbackUsuarioId, String? filePath,
      {String? url}) async {
    try {
      ArquivoFeedback arquivoFeedback = ArquivoFeedback();
      arquivoFeedback.feedbackUsuario_id = feedbackUsuarioId;
      arquivoFeedback.path = filePath;
      if (url != null) {
        arquivoFeedback.url = url;
      }
      await arquivoFeedback.saveOrThrow();
      return true;
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
    }
    return false;
  }
}
