/// This is a custom widget to handle states from view models
/// This takes in a [functionName] as a String to render only function which is called,
/// a [successBuilder] which tells what to render is status is [Status.Done]
/// [Status.Loading] renders a CircularProgressIndicator whereas
/// [Status.Error] renders [errorBuilder]

import 'package:atsign_atmosphere_app/view_models/base_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProviderHandler<T extends BaseModel> extends StatelessWidget {
  final Widget Function(T) successBuilder;
  final Widget Function(T) errorBuilder;
  final String functionName;

  const ProviderHandler(
      {Key key, this.successBuilder, this.errorBuilder, this.functionName})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Consumer<T>(builder: (context, _provider, __) {
      print(
          '_provider?.status[function]=======>${_provider?.status[functionName]}');
      if (_provider?.status[functionName] == Status.Loading) {
        return CircularProgressIndicator();
      } else if (_provider?.status[functionName] == Status.Error) {
        return errorBuilder(_provider);
      } else {
        return successBuilder(_provider);
      }
    });
  }
}
