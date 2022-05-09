import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';

class PermissionDeniedMessage extends StatefulWidget {
  final String title;

  PermissionDeniedMessage(this.title);

  @override
  _PermissionDeniedMessageState createState() =>
      _PermissionDeniedMessageState();
}

class _PermissionDeniedMessageState extends State<PermissionDeniedMessage> {
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
              height: 10.toHeight,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                    child: Text(TextStrings().ok,
                        style: TextStyle(fontSize: 16.toFont))),
              ],
            )
          ],
        ),
      ),
    );
  }
}
