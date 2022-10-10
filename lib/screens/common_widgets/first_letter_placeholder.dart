import 'package:at_backupkey_flutter/utils/size_config.dart';
import 'package:flutter/material.dart';

import '../../utils/colors.dart';
import '../../utils/text_styles.dart';

class FirstLetterPlaceholder extends StatelessWidget {
  const FirstLetterPlaceholder({
    Key? key,
    required this.letter,
  }) : super(key: key);

  final String letter;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.toWidth),
      child: Row(
        children: [
          Text(
            letter,
            style: CustomTextStyles.blackBold(size: 20),
          ),
          SizedBox(width: 20.toWidth),
          Expanded(
            child: Container(
              height: 1,
            ),
          )
        ],
      ),
    );
  }
}
