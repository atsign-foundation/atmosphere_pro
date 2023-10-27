import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';

class ErrorScreen extends StatefulWidget {
  final String title;

  const ErrorScreen(this.title, {Key? key}) : super(key: key);

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(ImageConstants.emptyGroup),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              widget.title,
              style: CustomTextStyles.greyText16,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
