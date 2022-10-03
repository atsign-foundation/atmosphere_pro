import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';

class SearchSender extends StatelessWidget {
  const SearchSender({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.toHeight,
      child: TextField(
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            horizontal: 13.toWidth,
            vertical: 16.toHeight,
          ),
          hintText: 'Search by atSign or nickname',
          hintStyle: CustomTextStyles.interRegular.copyWith(
            color: Color(0xff9B9B9B),
            fontStyle: FontStyle.italic,
          ),
          suffixIcon: Image.asset(
            ImageConstants.search,
            cacheHeight: 20,
            cacheWidth: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.toWidth),
            borderSide: BorderSide(
              color: Color(0xff9B9B9B),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.toWidth),
            borderSide: BorderSide(
              color: Color(0xff9B9B9B),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.toWidth),
            borderSide: BorderSide(
              color: Color(0xff9B9B9B),
            ),
          ),
        ),
      ),
    );
  }
}
