import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/history_screen/widgets/desktop_history_file_item.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/history_screen/widgets/desktop_history_status_badges.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/widgets/atsign_card_widget.dart';
import 'package:atsign_atmosphere_pro/widgets/sent_status_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class DetailHistoryCard extends StatelessWidget {
  final VoidCallback onPop;
  final FileHistory fileHistory;
  final bool isMobile;

  const DetailHistoryCard({
    required this.onPop,
    required this.fileHistory,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!isMobile)
          Expanded(
            child: InkWell(
              onTap: onPop,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
            ),
          ),
        Container(
          width: isMobile ? MediaQuery.sizeOf(context).width : 448,
          height: isMobile ? null : MediaQuery.sizeOf(context).width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: isMobile
                ? BorderRadius.vertical(
                    top: Radius.circular(20),
                  )
                : BorderRadius.horizontal(
                    left: Radius.circular(20),
                  ),
            boxShadow: [
              if (!isMobile)
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  offset: Offset(0, 4),
                  blurRadius: 44,
                )
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isMobile) ...[
                  SizedBox(height: 16),
                  Center(
                    child: Container(
                      width: 152,
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(38),
                        color: ColorConstants.dividerGrayColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                ] else ...[
                  SizedBox(height: 40),
                  InkWell(
                    onTap: onPop,
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: Center(
                        child: SvgPicture.asset(
                          AppVectors.icBack,
                          width: 8,
                          height: 20,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    physics: ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: buildTextWidgetWithTitle(
                                title: 'Sent on',
                                content: DateFormat("MMMM d, y 'at' HH:mm")
                                    .format(fileHistory.fileDetails?.date ??
                                        DateTime.now()),
                              ),
                            ),
                            buildWidgetWithTitle(
                              title: 'Status',
                              child: DesktopHistoryStatusBadges(
                                fileHistory: fileHistory,
                              ),
                              isStart: false,
                            )
                          ],
                        ),
                        SizedBox(height: 16),
                        if ((fileHistory.notes ?? '').isNotEmpty) ...[
                          buildTextWidgetWithTitle(
                            title: 'Message',
                            content: '"${fileHistory.notes}"',
                          ),
                          SizedBox(height: 16),
                        ],
                        if ((fileHistory.sharedWith ?? []).length == 1) ...[
                          buildWidgetWithTitle(
                            title: 'Sent To',
                            child: AtSignCardWidget(
                              atSign: fileHistory.sharedWith?[0].atsign,
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                        buildWidgetWithTitle(
                          title: 'Sent',
                          subTitle:
                              '${fileHistory.fileDetails?.files?.length} Files',
                          child: (fileHistory.sharedWith ?? []).length == 1
                              ? buildFileListWidget()
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return buildFileListStatusWidget(
                                        (fileHistory.fileDetails?.files ??
                                            [])[index]);
                                  },
                                  separatorBuilder: (context, index) {
                                    return SizedBox(height: 12);
                                  },
                                  itemCount:
                                      fileHistory.fileDetails?.files?.length ??
                                          0,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildWidgetWithTitle(
      {required String title,
      String? subTitle,
      required Widget child,
      bool isStart = true}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          isStart ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: title,
                style: CustomTextStyles.raisinBlackW50013,
              ),
              if ((subTitle ?? '').isNotEmpty)
                TextSpan(
                  text: ' $subTitle',
                  style: CustomTextStyles.orangeColorW50013,
                )
            ],
          ),
        ),
        SizedBox(height: 4),
        child,
      ],
    );
  }

  Widget buildTextWidgetWithTitle({
    required String title,
    required String content,
  }) {
    return buildWidgetWithTitle(
      title: title,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 8,
        ),
        child: Text(
          content,
          style: CustomTextStyles.darkSliverW40012,
        ),
      ),
    );
  }

  Widget buildFileListStatusWidget(FileData data) {
    return Container(
      padding: EdgeInsets.fromLTRB(6, 8, 6, 12),
      decoration: BoxDecoration(
        color: ColorConstants.fadedGreyN,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DesktopHistoryFileItem(
            data: data,
            fileTransfer: fileHistory.fileDetails!,
            type: HistoryType.send,
            isPreview: true,
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(6, 8, 6, 12),
            color: ColorConstants.dividerGrayColor,
            height: 3,
          ),
          ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 6),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return SentStatusWidget(
                status: (fileHistory.sharedWith ?? [])[index],
              );
            },
            separatorBuilder: (context, index) {
              return SizedBox(height: 4);
            },
            itemCount: fileHistory.sharedWith?.length ?? 0,
          ),
        ],
      ),
    );
  }

  Widget buildFileListWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: ColorConstants.fadedGreyN,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return DesktopHistoryFileItem(
            data: fileHistory.fileDetails!.files![index],
            fileTransfer: fileHistory.fileDetails!,
            type: HistoryType.send,
            isPreview: true,
            showStatus: true,
            isSent: fileHistory.sharedWith?[0].isNotificationSend,
          );
        },
        separatorBuilder: (context, index) {
          return SizedBox(height: 8);
        },
        itemCount: fileHistory.fileDetails?.files?.length ?? 0,
      ),
    );
  }
}
