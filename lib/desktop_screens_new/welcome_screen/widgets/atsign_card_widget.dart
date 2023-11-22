import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';

class AtSignCardWidget extends StatefulWidget {
  final String atSign;
  final Function(String) onSwitchAtSign;

  const AtSignCardWidget({
    Key? key,
    required this.atSign,
    required this.onSwitchAtSign,
  });

  @override
  State<AtSignCardWidget> createState() => _AtSignCardWidgetState();
}

class _AtSignCardWidgetState extends State<AtSignCardWidget> {
  late bool isCurrentAtSign;

  @override
  void initState() {
    super.initState();
    isCurrentAtSign =
        BackendService.getInstance().currentAtSign! == widget.atSign;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await BackendService.getInstance()
            .checkToOnboard(
          atSign: widget.atSign,
        )
            .then((value) {
          widget.onSwitchAtSign(widget.atSign);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        color: isCurrentAtSign ? ColorConstants.orange : Colors.white,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FutureBuilder<Map<String, dynamic>>(
                future: ContactService().getContactDetails(widget.atSign, null),
                builder: (context, snapshot) {
                  return SizedBox(
                    width: 48,
                    height: 48,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: snapshot.data?['image'] != null
                          ? Image.memory(
                              snapshot.data?['image'],
                              fit: BoxFit.cover,
                            )
                          : ContactInitial(
                              initials: widget.atSign.replaceFirst('@', ''),
                              borderRadius: 10,
                            ),
                    ),
                  );
                }),
            SizedBox(width: 16),
            Expanded(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.atSign,
                  style: isCurrentAtSign
                      ? CustomTextStyles.whiteW50015
                      : CustomTextStyles.desktopPrimaryW50015,
                ),
              ],
            ))
          ],
        ),
      ),
    );
  }
}
