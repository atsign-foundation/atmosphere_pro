import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';

class LabelledCircularProgressIndicator extends StatelessWidget {
  final double? value;

  const LabelledCircularProgressIndicator({Key? key, this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Stack(
        children: [
          CircularProgressIndicator(
            value: value,
            valueColor: const AlwaysStoppedAnimation<Color>(
              ColorConstants.orange,
            ),
          ),
          value != null
              ? Positioned(
                  top: 10,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 7),
                    child: Text('${(value! * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 8.toFont,
                          fontWeight: FontWeight.bold,
                          color: ColorConstants.blueText,
                        )),
                  ),
                )
              : const SizedBox()
        ],
      ),
    );
  }
}
