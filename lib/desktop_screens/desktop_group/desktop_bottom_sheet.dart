// ignore: import_of_legacy_library_into_null_safe
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:atsign_atmosphere_pro/services/size_config.dart';

class DesktopGroupBottomSheet extends StatefulWidget {
  final Function onPressed;
  final String buttontext, message;
  const DesktopGroupBottomSheet({
    this.onPressed,
    this.buttontext,
    this.message = '',
  });

  @override
  _DesktopGroupBottomSheetState createState() =>
      _DesktopGroupBottomSheetState();
}

class _DesktopGroupBottomSheetState extends State<DesktopGroupBottomSheet> {
  bool isLoading;
  @override
  void initState() {
    super.initState();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.toWidth),
      height: 70.toHeight,
      decoration: BoxDecoration(
          color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey)]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Text(
              widget.message,
              style: CustomTextStyles.primaryMedium14,
            ),
          ),
          isLoading
              ? CircularProgressIndicator()
              : TextButton(
                  onPressed: () {},
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      return ColorConstants.orangeColor;
                    },
                  ), fixedSize: MaterialStateProperty.resolveWith<Size>(
                    (Set<MaterialState> states) {
                      return Size(120, 40);
                    },
                  )),
                  child: Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
