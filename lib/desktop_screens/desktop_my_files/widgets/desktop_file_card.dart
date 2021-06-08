import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:flutter/material.dart';

class DesktopFileCard extends StatelessWidget {
  final String title;
  DesktopFileCard({this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        child: Column(
          children: <Widget>[
            Container(
              width: 180,
              height: 120,
              child: ClipRect(
                child: Image.asset(ImageConstants.emptyTrustedSenders,
                    fit: BoxFit.fill),
              ),
            ),
            title != null
                ? Container(
                    width: 180,
                    height: 30,
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: ColorConstants.light_border_color),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Text(
                        'audio.mp3',
                        style: TextStyle(color: Color(0xFF8A8E95)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : SizedBox()
          ],
        ),
      ),
    );
  }
}
