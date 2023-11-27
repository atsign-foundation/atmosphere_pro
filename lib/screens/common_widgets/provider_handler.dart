/// This is a custom widget to handle states from view models
/// This takes in a [functionName] as a String to render only function which is called,
/// a [successBuilder] which tells what to render is status is [Status.Done]
/// [Status.Loading] renders a CircularProgressIndicator whereas
/// [Status.Error] renders [errorBuilder]
import 'package:atsign_atmosphere_pro/screens/common_widgets/error_dialog.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/history_skeleton_loading_widget.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/files_skeleton_loading_widget.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/view_models/base_model.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:at_common_flutter/services/size_config.dart';

class ProviderHandler<T extends BaseModel> extends StatelessWidget {
  final Widget Function(T)? successBuilder;
  final Widget Function(T)? errorBuilder;
  final String? functionName;
  final bool showError;
  final Function(T)? load;
  final bool showSkeletonLoading;

  const ProviderHandler({
    Key? key,
    this.successBuilder,
    this.errorBuilder,
    this.functionName,
    this.showError = true,
    this.load,
    this.showSkeletonLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<T>(builder: (context, _provider, __) {
      if (_provider.status[functionName!] == Status.Loading ||
          showSkeletonLoading) {
        return _buildSkeletonLoading(context);
      } else if (_provider.status[functionName!] == Status.Error) {
        if (showError) {
          print('IN SHOW ERROR');
          ErrorDialog().show(_provider.error[functionName!].toString(),
              context: context);
          return SizedBox();
        } else {
          return errorBuilder!(_provider);
        }
      } else if (_provider.status[functionName!] == Status.Done) {
        return successBuilder!(_provider);
      } else if (_provider.status[functionName!] == Status.Idle) {
        return successBuilder!(_provider);
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await load!(_provider);
        });
        return Center(
          child: Container(
            height: 50.toHeight,
            width: 50.toHeight,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                ColorConstants.orange,
              ),
            ),
          ),
        );
      }
    });
  }

  Widget _buildSkeletonLoading(BuildContext context) {
    if (functionName == context.read<HistoryProvider>().GET_ALL_FILE_HISTORY) {
      return HistorySkeletonLoadingWidget();
    } else if (functionName == context.read<MyFilesProvider>().ALL_FILES) {
      return FilesSkeletonLoadingWidget();
    } else {
      return Center(
        child: SizedBox(
          height: 50.toHeight,
          width: 50.toHeight,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              ColorConstants.orange,
            ),
          ),
        ),
      );
    }
  }
}
