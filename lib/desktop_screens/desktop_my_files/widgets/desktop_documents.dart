import 'package:atsign_atmosphere_pro/desktop_screens/desktop_my_files/widgets/desktop_file_card.dart';
import 'package:flutter/material.dart';

class DesktopDocuments extends StatefulWidget {
  @override
  _DesktopDocumentsState createState() => _DesktopDocumentsState();
}

class _DesktopDocumentsState extends State<DesktopDocuments> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
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
    );
  }
}
