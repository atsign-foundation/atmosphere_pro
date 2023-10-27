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

class DesktopSwitchAtsign extends StatefulWidget {
  final String atsign;
  const DesktopSwitchAtsign({Key? key, required this.atsign}) : super(key: key);

  @override
  State<DesktopSwitchAtsign> createState() => _DesktopSwitchAtsignState();
}

class _DesktopSwitchAtsignState extends State<DesktopSwitchAtsign> {
  BackendService backendService = BackendService.getInstance();
  bool isCurrentAtsign = false;
  AtClient atClient = AtClientManager.getInstance().atClient;
  String? atsignName = '';

  @override
  void initState() {
    if (widget.atsign == atClient.getCurrentAtSign()) {
      isCurrentAtsign = true;
    }
    getAtsignDetails();
    super.initState();
  }

  getAtsignDetails() {
    atsignName = CommonUtilityFunctions().getCachedContactName(widget.atsign);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.atsign == TextStrings().addNewAtsign) {
      return addNewContactRow();
    } else if (widget.atsign == TextStrings().saveBackupKey) {
      return saveBackupKeyRow();
    } else {
      return _contactRow(widget.atsign, atsignName ?? '',
          isCurrentAtsign: isCurrentAtsign);
    }
  }

  Widget _contactRow(String atsign, String name,
      {bool isCurrentAtsign = false}) {
    Uint8List? image =
        CommonUtilityFunctions().getCachedContactImage(widget.atsign);

    return Row(
      children: <Widget>[
        image != null
            ? CustomCircleAvatar(
                byteImage: image,
                nonAsset: true,
                size: isCurrentAtsign ? 40 : 40,
              )
            : ContactInitial(
                initials: atsign,
                size: isCurrentAtsign ? 40 : 40,
                maxSize: isCurrentAtsign ? 50 : 40,
                minSize: isCurrentAtsign ? 40 : 30,
              ),
        const SizedBox(width: 10),
        Tooltip(
          message: atsign,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 180,
                child: Text(
                  atsign,
                  style: isCurrentAtsign
                      ? CustomTextStyles.blackBold()
                      : CustomTextStyles.desktopSecondaryRegular14,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 5),
              (name != '')
                  ? SizedBox(
                      width: 180,
                      child: Text(
                        name,
                        style: isCurrentAtsign
                            ? CustomTextStyles.greyText16
                            : CustomTextStyles.desktopSecondaryRegular14,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
        Expanded(
          child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                  onTap: () {
                    Navigator.of(NavService.navKey.currentContext!)
                        .pop(); // this is to close the popup menu button
                    CommonUtilityFunctions().deleteAtSign(widget.atsign);
                  },
                  child: const Icon(Icons.delete))),
        )
      ],
    );
  }

  Widget addNewContactRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
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
            child: const Icon(
              Icons.add,
              color: ColorConstants.fadedText,
              size: 35,
            ),
          ),
          const SizedBox(
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
    return const Column(
      children: [
        Divider(height: 1),
        SizedBox(
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
