class Constants {
  static const String BASE_URL = "https://webserver.agrosepac.com.br:";
  static const String BASE_URL_INTERNO = "192.68.20.11:";

  static const PORTA_RELEASE = "4618/";
  //static const PORTA_DEBUG = "4618/"; //falso
  //static const PORTA_RELEASE = "4522/"; //falso
  static const PORTA_DEBUG = "4522/";

  static const OBJECT1 = 'obj1';
  static const OBJECT2 = 'obj2';
  static const OBJECT3 = 'obj3';

  static const END_POINT_TOKEN = "api/user/token/";
  static const END_POINT_GET_PROFILE = "api/servicos/usuario/dados";
  static const END_POINT_VERSAO = 'api/versao/compare';
  static const END_POINT_FAVORITAR_MENU = 'api/servicos/cadastro/menu/favorito';
  static const END_POINT_SYNC_V2 = "api/v2/servicos/sincronizacao/listar";

  static const END_POINT_UPDATE_PHOTO_PROFILE = "api/user/foto";
  static const END_POINT_UPDATE_SIGNATURE_PROFILE =
      "api/servicos/usuario/cadastro/assinatura";
  static const END_POINT_UPDATE_PROFILE = "api/user/update";
  static const END_POINT_MENU = "api/menu";

  static const END_POINT_CADASTRO_ESTOQUE = 'api/cadastro/estoque';

  static const DEFAULT_PATTERN_DATE = "yyyy-MM-dd HH:mm:ss";
  static const DEFAULT_PATTERN_DATE_DAY = "yyyy-MM-dd";

  static const EXECUTAR_QUERY_UPDATE = 1;
  static const EXECUTAR_QUERY_ENVIAR_RESPOSTA = 2;
  static const DELETAR_SHARED_PREFERENCES = 3;
  static const SETAR_SHARED_PREFERENCES = 4;
  static const OBTER_SHARED_PREFERENCES = 5;
  static const SINCRONIZAR_DADOS = 6;
  static const NOTIFICAR_E_SINCRONIZAR = 7;
  static const ATUALIZAR_DADOS_DISPOSITIVO = 8;
  static const OBTER_LOCALIZACAO_USUARIO = 10;

  static const SHARED_PREFERENCES_TYPE_STRING = 1;
  static const SHARED_PREFERENCES_TYPE_INT = 2;
  static const SHARED_PREFERENCES_TYPE_BOOLEAN = 3;
  static const SHARED_PREFERENCES_TYPE_FLOAT = 4;
  static const SHARED_PREFERENCES_TYPE_LONG = 5;

  static const STATUS_SAIU_DA_AGRO = 0;
  static const STATUS_RECEBIDO_NA_TRANPORTADORA = 1;
  static const STATUS_ENVIADO_PARCIALMENTE_TRANSPORTADORA = 2;
  static const STATUS_ENVIADO_TOTALMENTE_TRANSPORTADORA = 3;
  static const STATUS_RECEBIDO_CLIENTE_PARCIALMENTE = 4;
  static const STATUS_RECEBIDO_CLIENTE_TOTALMENTE = 5;

  static const double LARGURA_PADRAO_FOTO = 1200;
  static const double ALTURA_PADRAO_FOTO = 2124;

  static const String MENU_BOX_NAME = 'menu2';
}
