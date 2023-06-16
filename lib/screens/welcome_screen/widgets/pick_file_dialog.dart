import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';

import '../../../utils/text_strings.dart';
import '../../../utils/text_styles.dart';

class PickFileDialog extends StatelessWidget {
  const PickFileDialog({Key? key, required this.selectFiles}) : super(key: key);

  final Function selectFiles;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () async {
              await selectFiles("MEDIA");
            },
            child: Row(children: <Widget>[
              Icon(
                Icons.camera,
                size: 30,
                color: ColorConstants.redText,
              ),
              Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    TextStrings().choice1,
                    style: CustomTextStyles.primaryBold14,
                  ))
            ]),
          ),
          const SizedBox(height: 15),
          InkWell(
            onTap: () async {
              await selectFiles("FILES");
            },
            child: Row(children: <Widget>[
              Icon(
                Icons.file_copy,
                size: 30,
                color: ColorConstants.redText,
              ),
              Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    TextStrings().choice2,
                    style: CustomTextStyles.primaryBold14,
                  ))
            ]),
          ),
        ],
      ),
    );
  }
}
