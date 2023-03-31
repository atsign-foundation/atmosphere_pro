import 'package:at_common_flutter/services/size_config.dart';
import 'package:flutter/material.dart';

class BottomNavigationWidget extends StatelessWidget {
  final Function(int index)? onTap;
  final int index;
  final String iconActivate, iconInactivate;
  final String title;
  final int indexSelected;

  const BottomNavigationWidget({
    Key? key,
    this.onTap,
    required this.index,
    this.title = '',
    required this.indexSelected,
    required this.iconActivate,
    required this.iconInactivate,
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
          Image.asset(
            indexSelected == index ? iconActivate : iconInactivate,
            height: 25,
          ),
          SizedBox(height: 3),
          Text(
            title,
            style: TextStyle(
              fontSize: 10.toFont,
              color: indexSelected == index ? Colors.black : Color(0xFFAEAEAE),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
