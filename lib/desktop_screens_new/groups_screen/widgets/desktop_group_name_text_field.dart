import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';

class DesktopGroupNameTextField extends StatelessWidget {
  final TextEditingController groupNameController;
  final Function(String?)? onChanged;

  const DesktopGroupNameTextField({
    Key? key,
    required this.groupNameController,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Group Name',
        enabledBorder: const UnderlineInputBorder(),
        filled: true,
        fillColor: ColorConstants.textFieldFillColor,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        border: const UnderlineInputBorder(),
        hintStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: ColorConstants.light_grey,
        ),
      ),
      controller: groupNameController,
    );
  }
}
