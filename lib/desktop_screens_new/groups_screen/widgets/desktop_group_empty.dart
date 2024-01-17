import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:flutter/material.dart';

class DesktopGroupEmpty extends StatelessWidget {
  final VoidCallback onTap;

  const DesktopGroupEmpty({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 122,
          width: 226,
          child: Image.asset(
            ImageConstants.emptyBox,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            "No Groups",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: ColorConstants.grey,
            ),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(46),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: ColorConstants.orange,
              borderRadius: BorderRadius.circular(46),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 8,
            ),
            child: Text(
              "Add Group",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        SizedBox(height: 100),
      ],
    );
  }
}
