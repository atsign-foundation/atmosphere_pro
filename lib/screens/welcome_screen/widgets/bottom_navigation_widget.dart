import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/screens/welcome_screen/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomNavigationWidget extends StatelessWidget {
  final Function(int index)? onTap;
  final int index;
  final String icon;
  final String title;
  final int indexSelected;

  const BottomNavigationWidget({
    Key? key,
    this.onTap,
    required this.index,
    this.icon = '',
    this.title = '',
    required this.indexSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap?.call(index);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          SvgPicture.asset(
            icon,
            color: indexSelected == index ? Color(0xffEAA743) : Colors.black,
            height: 25,
          ),
          SizedBox(
            height: 3,
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 11.toFont,
              color: indexSelected == index ? Color(0xffEAA743) : Colors.black,
            ),
          ),
          // Spacer(),
          SizedBox(
            height: 10,
          ),
          if (indexSelected == index)
            Container(
              height: 2,
              width: 40,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0xffEAA743).withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: Offset(0, -1), // changes position of shadow
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: 2,
              width: 40,
            ),
          if (indexSelected == index)
            SizedBox(
              height: 4,
              width: 50,
              child: CustomPaint(
                painter: PainterOne(),
              ),
            )
          else
            SizedBox(
              height: 4,
              width: 50,
            )
        ],
      ),
    );
  }
}
