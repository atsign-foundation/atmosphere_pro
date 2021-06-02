import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contact/at_contact.dart';

import 'package:flutter/material.dart';

import 'package:atsign_atmosphere_pro/data_models/file_transfer_status.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/bordered_contact.dart';

class FileTransferContacts extends StatelessWidget {
  final AtContact contact;
  final TransferStatus status;

  const FileTransferContacts({
    Key key,
    this.contact,
    this.status,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        BorderedContact(
          contact: contact,
          transferStatus: status,
        ),
        // SizedBox(height: 10.toHeight),
        Expanded(
          child: Text(
            contact.tags != null && contact.tags['name'] != null
                ? contact.tags['name']
                : contact.atSign.substring(1),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 5.toFont, color: Colors.black),
          ),
        ),
        SizedBox(height: 10.toHeight),
        Expanded(
          child: Text(
            contact.atSign,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 5.toFont),
          ),
        )
      ],
    );
  }
}
