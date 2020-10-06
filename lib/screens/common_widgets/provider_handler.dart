/// This is a custom widget to handle states from view models
/// This takes in a [successBuilder] which tells what to render is status is [Status.Done]
/// [Status.Loading] renders a CircularProgressIndicator whereas
/// [Status.Error] renders [errorBuilder]

import 'package:atsign_atmosphere_app/view_models/base_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProviderHandler<T extends BaseModel> extends StatelessWidget {
  final Widget Function(T) successBuilder;
  final Widget Function(T) errorBuilder;

  const ProviderHandler({Key key, this.successBuilder, this.errorBuilder})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Consumer<T>(builder: (context, _provider, __) {
      if (_provider?.status == Status.Loading) {
        return CircularProgressIndicator();
      } else if (_provider?.status == Status.Error) {
        return errorBuilder(_provider);
      } else {
        return successBuilder(_provider);
      }
    });
  }
}
