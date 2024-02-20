import 'dart:typed_data';

import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class DesktopSentStatusWidget extends StatefulWidget {
  final ShareStatus status;

  const DesktopSentStatusWidget({
    required this.status,
  });

  @override
  State<DesktopSentStatusWidget> createState() =>
      _DesktopSentStatusWidgetState();
}

class _DesktopSentStatusWidgetState extends State<DesktopSentStatusWidget> {
  late TrustedContactProvider _trustedProvider =
      context.read<TrustedContactProvider>();
  String nickname = '';
  Uint8List? image;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      nickname = await CommonUtilityFunctions()
          .getNickname(widget.status.atsign ?? '');
      image = CommonUtilityFunctions()
          .getCachedContactImage(widget.status.atsign ?? '');
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(41),
      ),
      child: Row(
        children: [
          (image ?? []).isNotEmpty
              ? CustomCircleAvatar(
                  byteImage: image,
                  nonAsset: true,
                  size: 24,
                )
              : ContactInitial(
                  size: 24,
                  initials: widget.status.atsign?.substring(1) ?? 'UG',
                ),
          SizedBox(width: 12),
          SizedBox(
            height: 16,
            child: RichText(
              text: TextSpan(
                children: [
                  if (nickname.isNotEmpty)
                    TextSpan(
                      text: '$nickname ',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  TextSpan(
                    text: widget.status.atsign ?? '',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8),
          if (_trustedProvider.trustedContacts
              .any((element) => element.atSign == widget.status.atsign))
            SizedBox(
              height: 16,
              width: 16,
              child: Center(
                child: SvgPicture.asset(
                  AppVectors.icBigTrustActivated,
                  width: 12,
                  height: 16,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Spacer(),
          SvgPicture.asset(
            widget.status.isNotificationSend ?? false
                ? AppVectors.icDone
                : AppVectors.icUndone,
            width: 24,
            height: 24,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }
}
