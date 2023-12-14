import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_pro/screens/contact_new_version/widget/contact_attachment_card.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:flutter/material.dart';

class ReceiveItemsList extends StatefulWidget {
  final AtContact atContact;

  const ReceiveItemsList({
    required this.atContact,
  });

  @override
  State<ReceiveItemsList> createState() => _ReceiveItemsListState();
}

class _ReceiveItemsListState extends State<ReceiveItemsList> {
  List<FileTransfer> filterReceivedFiles(
      String atSign, List<FileTransfer> receivedFiles) {
    List<FileTransfer> tempFiles = [];

    for (var file in receivedFiles) {
      if (file.sender == atSign) {
        tempFiles.add(file);
      }
    }

    return tempFiles;
  }

  @override
  Widget build(BuildContext context) {
    return ProviderHandler<HistoryProvider>(
      functionName: HistoryProvider().RECEIVED_HISTORY,
      showError: false,
      successBuilder: (provider) {
        var files = filterReceivedFiles(
            widget.atContact.atSign ?? "", provider.receivedHistoryLogs);

        return ListView.builder(
          shrinkWrap: true,
          itemCount: files.length,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            List<Widget> list = [];
            for (var file in files[index].files ?? []) {
              list.add(
                ContactAttachmentCard(
                  fileTransfer: files[index],
                  singleFile: file,
                  fromContact: true,
                  margin: EdgeInsets.zero,
                ),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: list,
            );
          },
        );
      },
      // errorBuilder: (provider) => Center(
      //   child: Text(TextStrings().errorOccured),
      // ),
      load: (provider) async {
        await provider.getReceivedHistory();
      },
    );
  }
}
