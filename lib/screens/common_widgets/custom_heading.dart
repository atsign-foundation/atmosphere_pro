import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import '../../utils/images.dart';

class Customheading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.toHeight,
      color: Colors.white,
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
