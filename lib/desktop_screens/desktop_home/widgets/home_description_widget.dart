import 'package:at_common_flutter/services/size_config.dart';
import 'package:flutter/material.dart';

class HomeDescriptionWidget extends StatelessWidget {
  const HomeDescriptionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Your app, your data',
          style: TextStyle(
            color: Colors.black,
            fontSize: 31.toFont,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          'Free, Encrypted File Transfer.',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.toFont,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
