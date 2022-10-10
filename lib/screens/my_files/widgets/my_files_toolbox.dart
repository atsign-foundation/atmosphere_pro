import 'dart:developer';

import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:flutter/material.dart';

import '../../../utils/colors.dart';
import '../../../utils/images.dart';
import '../../../utils/text_strings.dart';
import '../../../utils/text_styles.dart';
import 'file_format_dropdown_button.dart';

class MyFilesToolbox extends StatelessWidget {
  const MyFilesToolbox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.toWidth),
      decoration: BoxDecoration(
        color: ColorConstants.textBoxBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: RefreshButton()),
          SizedBox(width: 10.toWidth),
          Expanded(child: SearchButton()),
          SizedBox(width: 10.toWidth),
          Expanded(
            flex: SizeConfig().screenWidth > 400 ? 4 : 3,
            child: FileFormatDropDownButton(),
          ),
        ],
      ),
    );
  }
}

class RefreshButton extends StatelessWidget {
  const RefreshButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TextStrings().refresh,
          style: CustomTextStyles.primaryBold14
              .copyWith(color: ColorConstants.myFilesBtn),
        ),
        const SizedBox(height: 5),
        SquareRoundedIconButton(
          onTap: () {
            log('refresh button tapped');
          },
          icon: ImageConstants.refreshIcon,
        ),
      ],
    );
  }
}

class SearchButton extends StatelessWidget {
  const SearchButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TextStrings().searchFile,
          style: CustomTextStyles.primaryBold14
              .copyWith(color: ColorConstants.myFilesBtn),
        ),
        const SizedBox(height: 5),
        SquareRoundedIconButton(
          onTap: () {
            log('Search button tapped');
          },
          icon: ImageConstants.searchIcon,
        ),
      ],
    );
  }
}

class SquareRoundedIconButton extends StatelessWidget {
  const SquareRoundedIconButton({
    Key? key,
    required this.onTap,
    required this.icon,
  }) : super(key: key);

  final Function() onTap;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.toHeight,
      child: RawMaterialButton(
        onPressed: onTap,
        fillColor: Colors.white,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: ColorConstants.light_grey2),
        ),
        child: Image.asset(
          icon,
          width: 16.toWidth,
        ),
      ),
    );
  }
}
