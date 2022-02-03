import 'package:at_common_flutter/services/size_config.dart';
import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  final String title;
  final Function() onTap;
  final Color buttonColor;
  const CommonButton(this.title, this.onTap, {this.buttonColor = Colors.black});

  @override
  Widget build(BuildContext context) {
    double deviceTextFactor = MediaQuery.of(context).textScaleFactor;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 120.toWidth,
        height: 45.toHeight * deviceTextFactor,
        padding: EdgeInsets.symmetric(
          vertical: 10.toHeight,
          horizontal: 30.toWidth,
        ),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(20.toFont),
        ),
        child: Center(
          child: Text(
            title ?? '',
            style: TextStyle(
                color: Colors.white, fontSize: 15.toFont, letterSpacing: 0.1),
          ),
        ),
      ),
    );
  }
}
