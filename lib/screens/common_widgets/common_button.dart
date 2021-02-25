import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  final String title;
  final Function() onTap;
  const CommonButton(this.title, this.onTap);

  @override
  Widget build(BuildContext context) {
    double deviceTextFactor = MediaQuery.of(context).textScaleFactor;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 120.toWidth,
        height: 40.toHeight * deviceTextFactor,
        padding: EdgeInsets.symmetric(
          vertical: 10.toHeight,
          horizontal: 30.toWidth,
        ),
        decoration: BoxDecoration(
          color: Colors.black,
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
