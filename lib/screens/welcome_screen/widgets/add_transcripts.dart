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
      child: ListTile(
       tileColor: ColorConstants.inputFieldColor,
       shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.toFont),
        ),
        title: TextFormField(
              decoration: InputDecoration(
                  hintText: TextStrings().welcomeAddTranscripts,
                  border: InputBorder.none,),
              style: TextStyle(
                color: ColorConstants.fadedText,
                fontSize: 14.toFont,
                fontWeight: FontWeight.normal,
              ),
            ),trailing: Icon(Icons.edit, color: Colors.black),),
    );
  }
}
