import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';

class ContactSearchField extends StatelessWidget {
  final Function(String) onChanged;
  final String hintText;
  ContactSearchField(this.hintText, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.toFont),
      child: TextField(
        textInputAction: TextInputAction.search,
        onChanged: onChanged,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 16.toFont,
            color: ColorConstants.greyText,
          ),
          filled: true,
          fillColor: ColorConstants.inputFieldColor,
          contentPadding: EdgeInsets.symmetric(vertical: 15.toHeight),
          prefixIcon: Icon(
            Icons.search,
            color: ColorConstants.greyText,
            size: 20.toFont,
          ),
        ),
      ),
    );
  }
}
