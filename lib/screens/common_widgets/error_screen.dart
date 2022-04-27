import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';

class ErrorScreen extends StatefulWidget {
  final String title;

  ErrorScreen(this.title);

  @override
  _ErrorScreenState createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(ImageConstants.emptyGroup),
            Text(
              widget.title,
              style: CustomTextStyles.greyText16,
            ),
          ],
        ),
      ),
    );
  }
}
