import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/person_vertical_tile.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FileRecipients extends StatefulWidget {
  final List<ShareStatus> filesharedWith;

  FileRecipients(this.filesharedWith);

  @override
  _FileRecipientsState createState() => _FileRecipientsState();
}

class _FileRecipientsState extends State<FileRecipients> {
  List<ShareStatus> deliveredToList = [];
  List<ShareStatus> downloadedByList = [];
  List<ShareStatus> filedInDeliveringList = [];

  @override
  void initState() {
    sortAtsigns();
    super.initState();
  }

  sortAtsigns() {
    deliveredToList = [];
    downloadedByList = [];
    filedInDeliveringList = [];

    widget.filesharedWith.forEach((element) {
      print('filesharedWith : ${element.isSendingNotification}');
      if (element.isNotificationSend) {
        deliveredToList.add(element);
        // testing
        // filedInDeliveringList.add(element);
      } else {
        filedInDeliveringList.add(element);
      }

      if (element.isFileDownloaded) {
        downloadedByList.add(element);
      }
      // write condition for downloaded by atsigns
    });
    print('downloadedByList : ${downloadedByList}');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: 20.toHeight, vertical: 25.toHeight),
          child: Consumer<HistoryProvider>(builder: (context, provider, _) {
            sortAtsigns();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                downloadedByList.isNotEmpty
                    ? Text('Downloaded by', style: CustomTextStyles.grey15)
                    : SizedBox(),
                downloadedByList.isNotEmpty
                    ? SizedBox(height: 15.toHeight)
                    : SizedBox(),
                Align(
                  alignment: Alignment.topLeft,
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    runAlignment: WrapAlignment.start,
                    runSpacing: 10.0,
                    spacing: 15.0,
                    children: List.generate(downloadedByList.length, (index) {
                      return Container(
                        child: CustomPersonVerticalTile(
                          key: UniqueKey(),
                          shareStatus: downloadedByList[index],
                        ),
                      );
                    }),
                  ),
                ),
                downloadedByList.isNotEmpty ? Divider() : SizedBox(),
                SizedBox(height: 18.toHeight),
                deliveredToList.isNotEmpty
                    ? Text('Delivered to', style: CustomTextStyles.grey15)
                    : SizedBox(),
                deliveredToList.isNotEmpty
                    ? SizedBox(height: 15.toHeight)
                    : SizedBox(),
                Align(
                  alignment: Alignment.topLeft,
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    runAlignment: WrapAlignment.start,
                    runSpacing: 10.0,
                    spacing: 15.0,
                    children: List.generate(deliveredToList.length, (index) {
                      return Container(
                        child: CustomPersonVerticalTile(
                          key: UniqueKey(),
                          shareStatus: deliveredToList[index],
                        ),
                      );
                    }),
                  ),
                ),
                deliveredToList.isNotEmpty ? Divider() : SizedBox(),
                SizedBox(height: 18.toHeight),
                filedInDeliveringList.isNotEmpty
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Failed to send to',
                            style: CustomTextStyles.grey15,
                          ),
                          Text(
                            'Retry(3)',
                            style: CustomTextStyles.red15,
                          ),
                        ],
                      )
                    : SizedBox(),
                filedInDeliveringList.isNotEmpty
                    ? SizedBox(height: 15.toHeight)
                    : SizedBox(),
                Align(
                  alignment: Alignment.topLeft,
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    runAlignment: WrapAlignment.start,
                    runSpacing: 10.0,
                    spacing: 15.0,
                    children:
                        List.generate(filedInDeliveringList.length, (index) {
                      return Container(
                        child: CustomPersonVerticalTile(
                            key: UniqueKey(),
                            shareStatus: filedInDeliveringList[index],
                            isFailedAtsignList: true),
                      );
                    }),
                  ),
                ),
                filedInDeliveringList.isNotEmpty ? Divider() : SizedBox(),
              ],
            );
          })),
    );
  }
}
