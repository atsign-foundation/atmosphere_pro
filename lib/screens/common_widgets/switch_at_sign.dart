import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AtSignBottomSheet extends StatefulWidget {
  final List<String>? atSignList;

  const AtSignBottomSheet({Key? key, this.atSignList}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AtSignBottomSheetState createState() => _AtSignBottomSheetState();
}

class _AtSignBottomSheetState extends State<AtSignBottomSheet> {
  BuildContext? myContext;

  String currentAtSign =
      AtClientManager.getInstance().atClient.getCurrentAtSign()!;

  BackendService backendService = BackendService.getInstance();
  bool isLoading = false;
  var atClientPrefernce;

  @override
  Widget build(BuildContext context) {
    backendService
        .getAtClientPreference()
        .then((value) => atClientPrefernce = value);

    return FractionallySizedBox(
      heightFactor: widget.atSignList!.length > 2 ? 0.75 : 0.6,
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 30.toWidth,
          vertical: 20.toHeight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildIconButton(
              icon: AppVectors.icBack,
              title: "Back",
              onTap: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(
              height: 18.toHeight,
            ),
            Text(
              "Switch atSign",
              style: TextStyle(
                fontSize: 25.toFont,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: 10.toHeight,
            ),
            Text(
              "Select atSign (${widget.atSignList!.length})",
              style: TextStyle(
                fontSize: 16.toFont,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              height: 10.toHeight,
            ),
            Expanded(
              child: ListView.separated(
                  scrollDirection: Axis.vertical,
                  physics: const ClampingScrollPhysics(),
                  itemCount: widget.atSignList!.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  separatorBuilder: (context, index) => SizedBox(
                        height: 15.toHeight,
                      ),
                  itemBuilder: (context, index) {
                    bool isCurrentAtSign =
                        widget.atSignList![index] == currentAtSign;
                    return GestureDetector(
                      onTap: isLoading
                          ? () {}
                          : () async {
                              return await backendService.checkToOnboard(
                                  atSign: widget.atSignList![index]);
                            },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.toWidth, vertical: 15.toHeight),
                        decoration: BoxDecoration(
                          color: isCurrentAtSign
                              ? ColorConstants.optionalFilterBackgroundColor
                              : ColorConstants.fadedGrey,
                          border: Border.all(
                            width: 1,
                            color: isCurrentAtSign
                                ? ColorConstants.orange
                                : ColorConstants.lightGray2,
                          ),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "@",
                              style: TextStyle(
                                fontSize: 16.toFont,
                                fontWeight: FontWeight.w500,
                                color: ColorConstants.orange,
                              ),
                            ),
                            SizedBox(
                              width: 10.toWidth,
                            ),
                            Text(
                              widget.atSignList![index].substring(1),
                              style: TextStyle(
                                fontSize: 16.toFont,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            ),
            SizedBox(
              height: 10.toHeight,
            ),
            Divider(thickness: 2, color: Colors.grey.shade300),
            SizedBox(
              height: 10.toHeight,
            ),
            Text(
              "Can't find your atSign?",
              style: TextStyle(
                fontSize: 18.toFont,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              height: 20.toHeight,
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  backgroundColor: Colors.black),
              onPressed: () async {
                setState(() {
                  isLoading = true;
                  Navigator.pop(context);
                });
                await backendService.checkToOnboard(
                  atSign: "",
                  isSwitchAccount: true,
                );

                setState(() {
                  isLoading = false;
                });
              },
              child: Text(
                "Add a new atSign",
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.toFont,
                    color: Colors.white),
              ),
            ),
            SizedBox(
              height: 20.toHeight,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildIconButton({
    Function()? onTap,
    required String icon,
    required String title,
  }) {
    return InkWell(
      onTap: () {
        onTap?.call();
      },
      child: Container(
        padding:
            EdgeInsets.fromLTRB(12.toWidth, 9.toHeight, 16.toWidth, 8.toHeight),
        decoration: BoxDecoration(
          color: ColorConstants.lightGray2,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SvgPicture.asset(icon),
            SizedBox(width: 8.toWidth),
            Text(
              title,
              style: TextStyle(
                color: ColorConstants.darkGray2,
                fontSize: 14.toFont,
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ),
      ),
    );
  }
}
