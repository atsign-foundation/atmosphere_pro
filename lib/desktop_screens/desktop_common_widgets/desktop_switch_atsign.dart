import 'dart:typed_data';

import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_onboarding.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/common_functions.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';

class DesktopSwitchAtsign extends StatefulWidget {
  final List<String> atSignList;
  final Function showLoader;
  DesktopSwitchAtsign(
      {Key key, @required this.atSignList, @required this.showLoader})
      : super(key: key);

  @override
  State<DesktopSwitchAtsign> createState() => _DesktopSwitchAtsignState();
}

class _DesktopSwitchAtsignState extends State<DesktopSwitchAtsign> {
  BackendService backendService = BackendService.getInstance();
  bool isLoading = false;
  var atClientPrefernce;
  bool authenticating = false;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        width: 300,
        // height: ((100 * widget.atSignList.length).toDouble()) + 55,
        height: ((60 + (40 * widget.atSignList.length - 1).toDouble())) +
            (10 * widget.atSignList.length - 1) +
            55,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0.0, 1.0),
              blurRadius: 6.0,
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                scrollDirection: Axis.vertical,
                itemCount: widget.atSignList.length,
                itemBuilder: (context, index) {
                  Uint8List _image = CommonFunctions()
                      .getCachedContactImage(widget.atSignList[index]);
                  String _name = CommonFunctions()
                      .getCachedContactName(widget.atSignList[index]);
                  return _contactRow(widget.atSignList[index],
                      _name ?? widget.atSignList[index],
                      image: _image,
                      isCurrentAtsign: widget.atSignList[index] ==
                          backendService.currentAtsign);
                },
                separatorBuilder: (context, index) {
                  return SizedBox(height: 10);
                },
              ),
            ),
            SizedBox(
              height: 12,
            ),
            InkWell(
              onTap: () async {
                print('Add');
                setState(() {
                  isLoading = true;
                  // Navigator.pop(context);
                });

                if (atClientPrefernce == null) {
                  await backendService
                      .getAtClientPreference()
                      .then((value) => atClientPrefernce = value)
                      .catchError((e) => print(e));
                }

                await CustomOnboarding.onboard(
                    atSign: '',
                    atClientPrefernce: atClientPrefernce,
                    showLoader: widget.showLoader);

                setState(() {
                  isLoading = false;
                });
              },
              child: Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add,
                      color: ColorConstants.fadedText,
                      size: 35,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Add',
                    style: CustomTextStyles.desktopSecondaryRegular14,
                  )
                ],
              ),
            )
          ],
        ));
  }

  _contactRow(String _atsign, String _name,
      {bool isCurrentAtsign = false, Uint8List image}) {
    return InkWell(
      onTap: isLoading
          ? () {}
          : () async {
              if (atClientPrefernce == null) {
                await backendService
                    .getAtClientPreference()
                    .then((value) => atClientPrefernce = value)
                    .catchError((e) => print(e));
              }

              await CustomOnboarding.onboard(
                  atSign: _atsign,
                  atClientPrefernce: atClientPrefernce,
                  showLoader: widget.showLoader);

              // Provider.of<WelcomeScreenProvider>(context, listen: false)
              //     .selectedContacts = [];
              // Provider.of<FileTransferProvider>(context, listen: false)
              //     .selectedFiles = [];

              // Navigator.pop(context);
            },
      child: Row(
        children: <Widget>[
          image != null
              ? CustomCircleAvatar(
                  byteImage: image,
                  nonAsset: true,
                )
              : ContactInitial(
                  initials: _atsign ?? ' ',
                  size: isCurrentAtsign ? 60 : 40,
                  maxSize: isCurrentAtsign ? 60 : 40,
                  minSize: isCurrentAtsign ? 60 : 40,
                ),
          SizedBox(width: 10),
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _atsign,
                  style: isCurrentAtsign
                      ? CustomTextStyles.blackBold()
                      : CustomTextStyles.desktopSecondaryRegular14,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 5),
                Text(
                  _name,
                  style: isCurrentAtsign
                      ? CustomTextStyles.greyText16
                      : CustomTextStyles.desktopSecondaryRegular14,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
