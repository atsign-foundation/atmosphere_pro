import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DesktopSettingsCard extends StatelessWidget {
  const DesktopSettingsCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.vectorIcon,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final String vectorIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Container(
            height: 60,
            width: 60,
            clipBehavior: Clip.hardEdge,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Color(0xFF363636),
              borderRadius: BorderRadius.circular(5),
            ),
            child: SvgPicture.asset(
              vectorIcon,
              color: Colors.grey,
            ),
          ),
          SizedBox(
            width: 15,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
