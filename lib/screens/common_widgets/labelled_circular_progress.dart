import 'package:flutter/material.dart';

import '../../utils/colors.dart';

class LabelledCircularProgressIndicator extends StatelessWidget {
  double? value;
  LabelledCircularProgressIndicator({this.value});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Stack(
        children: [
          CircularProgressIndicator(value: value),
          value != null
              ? Positioned(
                  top: 10,
                  child: Padding(
                    padding: EdgeInsets.only(left: 7),
                    child: Text((value! * 100).toStringAsFixed(0) + '%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: ColorConstants.blueText,
                        )),
                  ),
                )
              : SizedBox()
        ],
      ),
    );
  }
}
