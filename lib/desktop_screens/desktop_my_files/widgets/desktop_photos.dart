import 'dart:io';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_my_files/widgets/desktop_file_card.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

class DesktopPhotos extends StatefulWidget {
  @override
  _DesktopPhotosState createState() => _DesktopPhotosState();
}

class _DesktopPhotosState extends State<DesktopPhotos> {
  HistoryProvider provider = HistoryProvider();
  @override
  void initState() {
    print('in PHOTOS');
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Align(
            alignment: Alignment.topLeft,
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
