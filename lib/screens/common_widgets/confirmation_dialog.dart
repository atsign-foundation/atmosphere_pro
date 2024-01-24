import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';

class ConfirmationDialog extends StatefulWidget {
  final String title;
  final Function onConfirmation;
  ConfirmationDialog(this.title, this.onConfirmation);

  @override
  _ConfirmationDialogState createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<ConfirmationDialog> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300.toWidth,
      padding: EdgeInsets.all(15.toFont),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: CustomTextStyles.grey15),
            SizedBox(
              height: 20.toHeight,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    TextStrings().buttonCancel,
                    style: TextStyle(
                      fontSize: 16.toFont,
                      fontWeight: FontWeight.normal,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                TextButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).primaryColor)),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      widget.onConfirmation.call();
                    },
                    child: Text(TextStrings().yes,
                        style: TextStyle(
                            fontSize: 16.toFont,
                            fontWeight: FontWeight.normal,
                            color: Colors.white))),
              ],
            )
          ],
        ),
      ),
    );
  }
}
