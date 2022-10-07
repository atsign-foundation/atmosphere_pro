import 'package:atsign_atmosphere_pro/routes/route_names.dart';
import 'package:atsign_atmosphere_pro/screens/welcome_screen/widgets/setting_page_button.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:flutter/material.dart';

class TermsAndConditionScreen extends StatefulWidget {
  @override
  State<TermsAndConditionScreen> createState() =>
      _TermsAndConditionScreenState();
}

class _TermsAndConditionScreenState extends State<TermsAndConditionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SettingPageButton(
          iconPath: ImageConstants.termsAndConditionsIcon,
          title: "Terms & Conditions",
          onTap: () {
            Navigator.pushNamed(context, Routes.WEBSITE_SCREEN, arguments: {
              "title": "Terms & Conditions",
              "url": "http://flutter.io/terms-and-conditions"
            });
          },
        ),
      ),
    );
  }
}
