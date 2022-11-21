import 'package:get_it/get_it.dart';
import 'package:msk/msk.dart';
import 'package:msk/src/data/data_source/repository_sync_impl.dart';
import 'package:msk/src/domain/repository/datasource_sync.dart';
import 'package:msk/src/domain/repository/repository_sync.dart';

registrarSingletons(App app, HiveService hiveService,
    {bool registrarAppBaseController = false}) {
  try {
    if (!GetIt.I.isRegistered<App>()) {
      GetIt.I.registerSingleton<App>(app);
    }
    if (!GetIt.I.isRegistered<HiveService>()) {
      GetIt.I.registerSingleton<HiveService>(hiveService,
          dispose: (service) async {
        await service.dispose();
      });
    }
    if (!GetIt.I.isRegistered<DataSourceSyncSpecifyRows>()) {
      GetIt.I.registerSingleton<DataSourceSyncSpecifyRows>(
          DataSourceSyncSpecifyRowsImpl());
    }
    if (!GetIt.I.isRegistered<RepositorySync>()) {
      GetIt.I.registerSingleton<RepositorySync>(
          RepositorySyncSpecifyRowsImpl(dataSource: GetIt.I.get()));
    }
    if (!GetIt.I.isRegistered<AtualizarDados>()) {
      GetIt.I.registerSingleton<AtualizarDados>(AtualizarDados());
    }
    if (!GetIt.I.isRegistered<EnviarDados>()) {
      GetIt.I.registerSingleton<EnviarDados>(EnviarDados());
    }
    if (registrarAppBaseController &&
        !GetIt.I.isRegistered<AppBaseController>()) {
      GetIt.I.registerSingleton<AppBaseController>(AppBaseController());
    }

    authService = GetIt.I.get<App>().authService;
  } catch (error, stackTrace) {
    UtilsSentry.reportError(error, stackTrace);
  }
}
