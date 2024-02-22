import 'dart:typed_data';

import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class AtSignCardWidget extends StatefulWidget {
  final String? atSign;

  const AtSignCardWidget({
    this.atSign,
  });

  @override
  State<AtSignCardWidget> createState() => _AtSignCardWidgetState();
}

class _AtSignCardWidgetState extends State<AtSignCardWidget> {
  late TrustedContactProvider _trustedProvider =
      context.read<TrustedContactProvider>();
  String nickname = '';
  Uint8List? image;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      nickname =
          await CommonUtilityFunctions().getNickname(widget.atSign ?? '');
      image =
          CommonUtilityFunctions().getCachedContactImage(widget.atSign ?? '');
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.culturedColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: ClipRRect(
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(10),
              ),
              child: (image ?? []).isNotEmpty
                  ? CustomCircleAvatar(
                      byteImage: image,
                      nonAsset: true,
                size: nickname.isNotEmpty ? 76 : 60,
                    )
                  : ContactInitial(
                      borderRadius: 0,
                      size: nickname.isNotEmpty ? 76 : 60,
                      initials: widget.atSign?.substring(1) ?? 'UG',
                    ),
            ),
          ),
          SizedBox(width: 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.atSign ?? '',
                    style: CustomTextStyles.blackW60013,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (nickname.isNotEmpty)
                    Text(
                      'nickname',
                      style: CustomTextStyles.blackW40012,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),
          SizedBox(width: 24),
          // if (_trustedProvider.trustedContacts
          //     .any((element) => element.atSign == widget.atSign)) ...[
            SizedBox(
              height: 28,
              width: 28,
              child: Center(
                child: SvgPicture.asset(
                  AppVectors.icBigTrustActivated,
                  width: 20,
                  height: 24,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 24),
          // ]
        ],
      ),
    );
  }
}
