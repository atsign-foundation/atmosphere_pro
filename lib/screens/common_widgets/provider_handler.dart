/// This is a custom widget to handle states from view models
/// This takes in a [functionName] as a String to render only function which is called,
/// a [successBuilder] which tells what to render is status is [Status.Done]
/// [Status.Loading] renders a CircularProgressIndicator whereas
/// [Status.Error] renders [errorBuilder]
import 'package:atsign_atmosphere_app/screens/common_widgets/error_dialog.dart';
import 'package:atsign_atmosphere_app/view_models/base_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';

class ProviderHandler<T extends BaseModel> extends StatelessWidget {
  final Widget Function(T) successBuilder;
  final Widget Function(T) errorBuilder;
  final String functionName;
  final bool showError;
  final Function(T) load;

  const ProviderHandler(
      {Key key,
      this.successBuilder,
      this.errorBuilder,
      this.functionName,
      this.showError,
      this.load})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Consumer<T>(builder: (context, _provider, __) {
      //  String _statusString = functionName(_provider);
      print(
          '_provider?.status[functionName]=====>${_provider?.status[functionName]}========>$functionName=======>before');
      if (_provider?.status[functionName] == Status.Loading) {
        return Center(
          child: Container(
            height: 50.toHeight,
            width: 50.toHeight,
            child: CircularProgressIndicator(),
          ),
        );
      } else if (_provider?.status[functionName] == Status.Error) {
        print(
            '_provider?.status[functionName]=====>${_provider?.status[functionName]}========>$functionName');
        if (showError) {
          print('IN SHOW ERROR');
          ErrorDialog()
              .show(_provider.error[functionName].toString(), context: context);
          _provider.reset(functionName);
          return SizedBox();
        } else {
          _provider.reset(functionName);
          return errorBuilder(_provider);
        }
      } else if (_provider?.status[functionName] == Status.Done) {
        return successBuilder(_provider);
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await load(_provider);
        });
        return Center(
          child: Container(
            height: 50.toHeight,
            width: 50.toHeight,
            child: CircularProgressIndicator(),
          ),
        );
      }
    });
  }
}
