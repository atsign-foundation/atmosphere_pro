/// This is a custom widget to handle states from view models
/// This takes in a [functionName] as a String to render only function which is called,
/// a [successBuilder] which tells what to render is status is [Status.Done]
/// [Status.Loading] renders a CircularProgressIndicator whereas
/// [Status.Error] renders [errorBuilder]
import 'package:atsign_atmosphere_pro/screens/common_widgets/error_dialog.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/view_models/base_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:at_common_flutter/services/size_config.dart';

class ProviderHandler<T extends BaseModel> extends StatelessWidget {
  final Widget Function(T)? successBuilder;
  final Widget Function(T)? errorBuilder;
  final String? functionName;
  final bool showError;
  final Function(T)? load;

  const ProviderHandler(
      {Key? key,
      this.successBuilder,
      this.errorBuilder,
      this.functionName,
      this.showError = true,
      this.load})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<T>(builder: (context, provider, __) {
      if (provider.status[functionName!] == Status.Loading) {
        return Center(
          child: SizedBox(
            height: 50.toHeight,
            width: 50.toHeight,
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                ColorConstants.orange,
              ),
            ),
          ),
        );
      } else if (provider.status[functionName!] == Status.Error) {
        if (showError) {
          print('IN SHOW ERROR');
          ErrorDialog()
              .show(provider.error[functionName!].toString(), context: context);
          return const SizedBox();
        } else {
          return errorBuilder!(provider);
        }
      } else if (provider.status[functionName!] == Status.Done) {
        return successBuilder!(provider);
      } else if (provider.status[functionName!] == Status.Idle) {
        return successBuilder!(provider);
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await load!(provider);
        });
        return Center(
          child: SizedBox(
            height: 50.toHeight,
            width: 50.toHeight,
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                ColorConstants.orange,
              ),
            ),
          ),
        );
      }
    });
  }
}
