import 'package:flutter/material.dart';
import 'package:msk_widgets/msk_widgets.dart';

import 'base_sync_strategy_page.dart';
import 'register/models/validation_required_data.dart';

abstract class BaseRequiredDataPage<T extends StatefulWidget>
    extends BaseSyncStrategyPage<T> {
  Future<bool> validationRequiredData(Map<String, dynamic>? args) async {
    List<RequiredData> checkers = await listRequiredData(args);
    if (checkers.isNotEmpty) {
      for (RequiredData data in checkers) {
        if (!(await data.validate())) {
          showSnack(context, data.messageError,
              dismiss: data.dismiss, delayPop: false);
          return false;
        }
      }
    }
    return true;
  }

  void checkRequiredData(BuildContext context) async {
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    dataRequiredChecked(
        await validationRequiredData(args as Map<String, dynamic>?), args);
  }

  @override
  void syncFinished(BuildContext context) {
    checkRequiredData(context);
  }

  void dataRequiredChecked(bool sucess, Map<String, dynamic>? args);
}
