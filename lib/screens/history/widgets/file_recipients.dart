import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer_status.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/person_vertical_tile.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FileRecipients extends StatefulWidget {
  final List<ShareStatus> filesharedWith;
  FileRecipientSection fileRecipientSection;
  FileRecipients(this.filesharedWith, {this.fileRecipientSection});

  @override
  _FileRecipientsState createState() => _FileRecipientsState();
}

class _FileRecipientsState extends State<FileRecipients> {
  List<ShareStatus> deliveredToList = [];
  List<ShareStatus> downloadedByList = [];
  List<ShareStatus> filedInDeliveringList = [];

  Color color = Colors.white;
  @override
  void initState() {
    sortAtsigns();

    if (widget.fileRecipientSection == FileRecipientSection.DOWNLOADED) {
      color = ColorConstants.blueText.withOpacity(0.5);
    } else if (widget.fileRecipientSection == FileRecipientSection.DELIVERED) {
      color = ColorConstants.successGreen.withOpacity(0.5);
    } else if (widget.fileRecipientSection == FileRecipientSection.FAILED) {
      color = ColorConstants.redAlert.withOpacity(0.5);
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        color = Colors.white;
      });
    });
    super.initState();
  }

  sortAtsigns() {
    deliveredToList = [];
    downloadedByList = [];
    filedInDeliveringList = [];

    widget.filesharedWith.forEach((element) {
      if (element.isNotificationSend) {
        deliveredToList.add(element);
      } else {
        filedInDeliveringList.add(element);
      }

      if (element.isFileDownloaded) {
        downloadedByList.add(element);
      }
    });
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
                    ? Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: ColorConstants.blueText,
                            size: 15.toFont,
                          ),
                          SizedBox(width: 5),
                          Text('Downloaded by', style: CustomTextStyles.grey15),
                        ],
                      )
                    : SizedBox(),
                downloadedByList.isNotEmpty
                    ? SizedBox(height: 15.toHeight)
                    : SizedBox(),
                AnimatedContainer(
                  width: double.infinity,
                  duration: const Duration(seconds: 1),
                  color: widget.fileRecipientSection ==
                          FileRecipientSection.DOWNLOADED
                      ? color
                      : Colors.white,
                  curve: Curves.fastOutSlowIn,
                  child: Align(
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
                ),
                downloadedByList.isNotEmpty ? Divider() : SizedBox(),
                SizedBox(height: 18.toHeight),
                deliveredToList.isNotEmpty
                    ? Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: ColorConstants.successGreen,
                            size: 15.toFont,
                          ),
                          SizedBox(width: 5),
                          Text('Delivered to', style: CustomTextStyles.grey15),
                        ],
                      )
                    : SizedBox(),
                deliveredToList.isNotEmpty
                    ? SizedBox(height: 15.toHeight)
                    : SizedBox(),
                AnimatedContainer(
                  width: double.infinity,
                  duration: const Duration(seconds: 1),
                  color: widget.fileRecipientSection ==
                          FileRecipientSection.DELIVERED
                      ? color
                      : Colors.white,
                  curve: Curves.fastOutSlowIn,
                  child: Align(
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
                ),
                deliveredToList.isNotEmpty ? Divider() : SizedBox(),
                SizedBox(height: 18.toHeight),
                filedInDeliveringList.isNotEmpty
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.error,
                                color: ColorConstants.redAlert,
                                size: 15.toFont,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Failed to send to',
                                style: CustomTextStyles.grey15,
                              ),
                            ],
                          ),
                          Text(
                            'Retry(${filedInDeliveringList.length})',
                            style: CustomTextStyles.red15,
                          ),
                        ],
                      )
                    : SizedBox(),
                filedInDeliveringList.isNotEmpty
                    ? SizedBox(height: 15.toHeight)
                    : SizedBox(),
                AnimatedContainer(
                  width: double.infinity,
                  duration: const Duration(seconds: 1),
                  color:
                      widget.fileRecipientSection == FileRecipientSection.FAILED
                          ? color
                          : Colors.white,
                  curve: Curves.fastOutSlowIn,
                  child: Align(
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
                ),
                filedInDeliveringList.isNotEmpty ? Divider() : SizedBox(),
              ],
            );
          })),
    );
  }
}
