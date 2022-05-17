import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:flutter/material.dart';

class AddTranscripts extends StatefulWidget {
  @override
  _AddTranscriptsState createState() => _AddTranscriptsState();
}

class _AddTranscriptsState extends State<AddTranscripts> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Theme(
      data: ThemeData(
        dividerColor: Colors.transparent,
        textTheme: TextTheme(
          subtitle1: TextStyle(
            color: ColorConstants.inputFieldColor,
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.toFont),
        child: Container(
            color: ColorConstants.inputFieldColor,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 15.toWidth, vertical: 5.toHeight),
              child: TextFormField(
                decoration: InputDecoration(
                    hintText: TextStrings().welcomeAddTranscripts,
                    border: InputBorder.none,
                    suffixIcon: Icon(Icons.edit, color: Colors.black)),
                style: TextStyle(
                  color: ColorConstants.fadedText,
                  fontSize: 14.toFont,
                  fontWeight: FontWeight.normal,
                ),
              ),
            )),
      ),
    );
  }
}
