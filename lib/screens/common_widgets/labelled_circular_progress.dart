import 'package:at_common_flutter/services/size_config.dart';
import 'package:flutter/material.dart';

import '../../utils/colors.dart';

class LabelledCircularProgressIndicator extends StatelessWidget {
  final double? value;

  LabelledCircularProgressIndicator({this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Stack(
        children: [
          CircularProgressIndicator(
            value: value,
            valueColor: AlwaysStoppedAnimation<Color>(
              ColorConstants.orange,
            ),
          ),
          value != null
              ? Positioned(
                  top: 10,
                  child: Padding(
                    padding: EdgeInsets.only(left: 7),
                    child: Text((value! * 100).toStringAsFixed(0) + '%',
                        style: TextStyle(
                          fontSize: 12.toFont,
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
