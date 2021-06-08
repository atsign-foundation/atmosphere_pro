import 'package:atsign_atmosphere_pro/desktop_screens/desktop_my_files/widgets/desktop_file_card.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/downloads_folders.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/file_types.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:flutter/material.dart';

class DesktopUnknowns extends StatefulWidget {
  @override
  _DesktopUnknownsState createState() => _DesktopUnknownsState();
}

class _DesktopUnknownsState extends State<DesktopUnknowns> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Align(
            child: Wrap(
              alignment: WrapAlignment.start,
              runAlignment: WrapAlignment.start,
              runSpacing: 10.0,
              spacing: 30.0,
              children: List.generate(
                50,
                (index) => DesktopFileCard(
                  title: 'audio.mp3',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
