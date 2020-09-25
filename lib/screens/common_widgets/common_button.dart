import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  final String title;
  final Function() onTap;
  const CommonButton(this.title, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 10.toHeight,
          horizontal: 30.toWidth,
        ),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20.toFont),
        ),
        child: Text(
          title ?? '',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.toFont,
          ),
        ),
      ),
    );
  }
}
