import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:flutter/material.dart';

class SwitchAtSignTile extends StatefulWidget {
  const SwitchAtSignTile({
    Key? key,
    required this.atSign,
    this.isExpanded = false,
  }) : super(key: key);

  final String atSign;
  final bool isExpanded;

  @override
  State<SwitchAtSignTile> createState() => _SwitchAtSignTileState();
}

class _SwitchAtSignTileState extends State<SwitchAtSignTile> {
  var image;
  String? nickname;
  String currentAtSign = "";

  @override
  void initState() {
    super.initState();
    getContactDetails();
    currentAtSign =
        AtClientManager.getInstance().atClient.getCurrentAtSign() ?? "";
  }

  void getContactDetails() {
    AtContact contact = checkForCachedContactDetail(widget.atSign);
    if (contact.tags?["image"] != null) {
      image = contact.tags?["image"];
    }
    if (contact.tags?["nickname"] != null) {
      nickname = contact.tags?["nickname"];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: currentAtSign == widget.atSign
          ? Theme.of(context).primaryColor
          : Colors.transparent,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      width: 300,
      child: Row(
        children: [
          Center(
            // child: image != null
            //     ? CustomCircleAvatar(
            //         image: image.toString(),
            //         size: 10,
            //       )
            //     : ContactInitialV2(initials: widget.atSign),
            child: ContactInitialV2(initials: widget.atSign),
          ),
          SizedBox(
            width: widget.isExpanded ? 20 : 0,
          ),
          widget.isExpanded
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nickname ?? widget.atSign,
                      style: TextStyle(
                        fontSize: 10,
                        color: currentAtSign == widget.atSign
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    Text(
                      widget.atSign,
                      style: TextStyle(
                        fontSize: 16,
                        color: currentAtSign == widget.atSign
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ],
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
