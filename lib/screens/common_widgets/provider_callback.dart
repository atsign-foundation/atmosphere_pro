import 'package:atsign_atmosphere_pro/screens/common_widgets/error_dialog.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/loading_widget.dart';
import 'package:atsign_atmosphere_pro/view_models/base_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future providerCallback<T extends BaseModel>(BuildContext context,
    {required final Function(T) task,
    required final String Function(T) taskName,
    required Function(T) onSuccess,
    bool showDialog = true,
    bool showLoader = true,
    Function? onErrorHandeling,
    Function? onError}) async {
  final T provider = Provider.of<T>(context, listen: false);
  String taskName0 = taskName(provider);

  if (showLoader) LoadingDialog().show();
  await Future.microtask(() => task(provider));
  if (showLoader) LoadingDialog().hide();
  print(
      'status before=====>_provider.status[_taskName]====>${provider.status[taskName0]}');
  if (provider.status[taskName0] == Status.Error) {
    if (showDialog && context.mounted) {
      ErrorDialog().show(
        provider.error[taskName0].toString(),
        context: context,
        onButtonPressed: onErrorHandeling,
      );
    }

    if (onError != null) onError(provider);

    provider.reset(taskName0);
    print(
        'status before=====>_provider.status[_taskName]====>${provider.status[taskName0]}');
  } else if (provider.status[taskName0] == Status.Done) {
    onSuccess(provider);
  }
}
