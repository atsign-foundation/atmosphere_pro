import 'dart:typed_data';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';

class DesktopSwitchAtSign extends StatefulWidget {
  final String atSign;

  DesktopSwitchAtSign({
    Key? key,
    required this.atSign,
  }) : super(key: key);

  @override
  State<DesktopSwitchAtSign> createState() => _DesktopSwitchAtSignState();
}

class _DesktopSwitchAtSignState extends State<DesktopSwitchAtSign> {
  BackendService backendService = BackendService.getInstance();
  bool isCurrentAtSign = false;
  var atClientPreference;
  AtClient atClient = AtClientManager.getInstance().atClient;
  String? atSignName = '';

  @override
  void initState() {
    if (widget.atSign == atClient.getCurrentAtSign()) {
      isCurrentAtSign = true;
    }
    getAtSignDetails();
    super.initState();
  }

  getAtSignDetails() {
    atSignName = CommonUtilityFunctions().getCachedContactName(widget.atSign);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.atSign == TextStrings().addNewAtSign) {
      return addNewContactRow();
    } else if (widget.atSign == TextStrings().saveBackupKey) {
      return saveBackupKeyRow();
    } else {
      return _contactRow(widget.atSign, atSignName ?? '',
          isCurrentAtSign: isCurrentAtSign);
    }
  }

  Widget _contactRow(String _atSign, String _name,
      {bool isCurrentAtSign = false}) {
    Uint8List? image =
        CommonUtilityFunctions().getCachedContactImage(widget.atSign);

    return Row(
      children: <Widget>[
        image != null
            ? CustomCircleAvatar(
                byteImage: image,
                nonAsset: true,
                size: isCurrentAtSign ? 40 : 40,
              )
            : ContactInitial(
                initials: _atSign,
                size: isCurrentAtSign ? 40 : 40,
                maxSize: isCurrentAtSign ? 50 : 40,
                minSize: isCurrentAtSign ? 40 : 30,
              ),
        SizedBox(width: 10),
        Container(
          child: Tooltip(
            message: _atSign,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 180,
                  child: Text(
                    _atSign,
                    style: isCurrentAtSign
                        ? CustomTextStyles.blackBold()
                        : CustomTextStyles.desktopSecondaryRegular14,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 5),
                _name.isNotEmpty
                    ? SizedBox(
                        width: 180,
                        child: Text(
                          _name,
                          style: isCurrentAtSign
                              ? CustomTextStyles.greyText16
                              : CustomTextStyles.desktopSecondaryRegular14,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    : SizedBox(),
              ],
            ),
          ),
        ),
        Expanded(
          child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                  onTap: () {
                    Navigator.of(NavService.navKey.currentContext!)
                        .pop(); // this is to close the popup menu button
                    CommonUtilityFunctions().deleteAtSign(widget.atSign);
                  },
                  child: Icon(Icons.delete))),
        )
      ],
    );
  }

  Widget addNewContactRow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
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
    );
  }

  Widget saveBackupKeyRow() {
    return Column(
      children: [
        Divider(height: 1),
        Container(
          height: 50,
          child: Row(
            children: [
              Icon(Icons.file_copy),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Backup your keys',
                  softWrap: true,
                  style: TextStyle(
                    color: ColorConstants.fadedText,
                    letterSpacing: 0.1,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
