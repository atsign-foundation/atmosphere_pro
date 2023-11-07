import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

class Customheading extends StatelessWidget {
  const Customheading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.toHeight,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(
            width: 90.toHeight,
            height: 90.toHeight,
            child: Image.asset(
              ImageConstants.logoIcon,
            ),
          ),
        ],
      ),
    );
  }
}
