import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import '../../utils/images.dart';

class Customheading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.toHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: Container(
              width: 90.toHeight,
              height: 90.toHeight,
              child: Image.asset(
                ImageConstants.logoIcon,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
