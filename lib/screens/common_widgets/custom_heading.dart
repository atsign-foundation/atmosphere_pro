import 'package:flutter/material.dart';

import '../../utils/images.dart';

class Customheading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: SizedBox(
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
