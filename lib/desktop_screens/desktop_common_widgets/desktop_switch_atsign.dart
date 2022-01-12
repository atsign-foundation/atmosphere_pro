import 'dart:typed_data';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/common_functions.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';

class DesktopSwitchAtsign extends StatefulWidget {
  String atsign;
  DesktopSwitchAtsign({Key key, @required this.atsign}) : super(key: key);

  @override
  State<DesktopSwitchAtsign> createState() => _DesktopSwitchAtsignState();
}

class _DesktopSwitchAtsignState extends State<DesktopSwitchAtsign> {
  BackendService backendService = BackendService.getInstance();
  bool isCurrentAtsign = false;
  var atClientPrefernce;
  AtClient atClient = AtClientManager.getInstance().atClient;
  String atsignName = '';
  Uint8List atsignImage;

  @override
  void initState() {
    if (widget.atsign == atClient.getCurrentAtSign()) {
      isCurrentAtsign = true;
    }
    getAtsignDetails();
    super.initState();
  }

  getAtsignDetails() {
    atsignImage = CommonFunctions().getCachedContactImage(widget.atsign);
    atsignName = CommonFunctions().getCachedContactName(widget.atsign);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.atsign == 'add_new_atsign'
        ? addNewContactRow()
        : _contactRow(widget.atsign, atsignName ?? '',
            isCurrentAtsign: isCurrentAtsign, image: atsignImage);
  }

  Widget _contactRow(String _atsign, String _name,
      {bool isCurrentAtsign = false, Uint8List image}) {
    return Row(
      children: <Widget>[
        image != null
            ? CustomCircleAvatar(
                byteImage: image,
                nonAsset: true,
                size: isCurrentAtsign ? 40 : 40,
              )
            : ContactInitial(
                initials: _atsign ?? ' ',
                size: isCurrentAtsign ? 40 : 40,
                maxSize: isCurrentAtsign ? 50 : 40,
                minSize: isCurrentAtsign ? 40 : 30,
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
    );
  }

  Widget addNewContactRow() {
    return Row(
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
    );
  }
}
