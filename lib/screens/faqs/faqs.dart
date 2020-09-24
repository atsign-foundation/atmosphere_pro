import 'package:atsign_atmosphere_app/screens/common_widgets/app_bar.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:flutter/material.dart';

class FaqsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        showTitle: true,
        title: 'FAQ',
      ),
      body: Container(
        margin:
            EdgeInsets.symmetric(horizontal: 16.toWidth, vertical: 16.toHeight),
        child: ListView.separated(
          itemCount: 10,
          separatorBuilder: (context, index) => SizedBox(
            height: 10.toHeight,
          ),
          itemBuilder: (context, index) => ClipRRect(
            borderRadius: BorderRadius.circular(10.toFont),
            child: Container(
              color: ColorConstants.inputFieldColor,
              child: Theme(
                data: ThemeData(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  title: Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit?',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12.toFont,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Icon(Icons.keyboard_arrow_down),
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(
                        16.toWidth,
                        0,
                        16.toWidth,
                        14.toHeight,
                      ),
                      child: Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                        style: TextStyle(
                          color: ColorConstants.fadedText,
                          fontSize: 12.toFont,
                          height: 1.7,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
