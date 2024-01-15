import 'package:flutter/material.dart';

class BottomNavigationWidget extends StatelessWidget {
  final Function(int index)? onTap;
  final int index;
  final String iconActivate, iconInactivate;
  final int indexSelected;

  const BottomNavigationWidget({
    Key? key,
    this.onTap,
    required this.index,
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
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        child: Image.asset(
          indexSelected == index ? iconActivate : iconInactivate,
          height: 32,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
