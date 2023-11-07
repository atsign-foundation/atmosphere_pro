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
    return Row(
      children: [
        Container(
          height: 60,
          width: 60,
          clipBehavior: Clip.hardEdge,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFF363636),
            borderRadius: BorderRadius.circular(5),
          ),
          child: SvgPicture.asset(
            vectorIcon,
            color: Colors.grey,
          ),
        ),
        const SizedBox(
          width: 15,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
              ),
            )
          ],
        )
      ],
    );
  }
}
