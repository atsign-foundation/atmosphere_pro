import 'dart:typed_data';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_common_widgets/dektop_custom_person_tile.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/triple_dot_loading.dart';
import 'package:atsign_atmosphere_pro/services/common_functions.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:provider/provider.dart';

class DesktopTranferOverlappingContacts extends StatefulWidget {
  final List<ShareStatus> selectedList;
  final FileHistory fileHistory;

  const DesktopTranferOverlappingContacts(
      {Key key, this.selectedList, this.fileHistory})
      : super(key: key);

  @override
  _DesktopTranferOverlappingContactsState createState() =>
      _DesktopTranferOverlappingContactsState();
}

class _DesktopTranferOverlappingContactsState
    extends State<DesktopTranferOverlappingContacts> {
  bool isExpanded = false;
  int noOfContactsRow = 0;
  List<bool> atsignResharing = [];

  @override
  void initState() {
    atsignResharing =
        List<bool>.generate(widget.selectedList.length, (i) => false);
    noOfContactsRow = (widget.selectedList.length / 5).ceil();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: Container(
        height: (isExpanded) ? 170.toHeight * noOfContactsRow : 80.toHeight,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Color(0xffF86060).withAlpha(0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Stack(
              children: List.generate(
                widget.selectedList.length,
                (index) {
                  Uint8List image = CommonFunctions().getCachedContactImage(
                      widget?.selectedList[index]?.atsign);

                  return Positioned(
                    left: 5 + double.parse((index * 10).toString()),
                    top: 5.toHeight,
                    child: Container(
                      height: 28.toHeight,
                      width: 28.toHeight,
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: image != null
                          ? CustomCircleAvatar(
                              byteImage: image,
                              nonAsset: true,
                            )
                          : ContactInitial(
                              initials:
                                  widget?.selectedList[index]?.atsign ?? '  ',
                            ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 5.toHeight,
              left: 60.toWidth,
              child: Row(
                // mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  (widget.selectedList.isEmpty)
                      ? Container()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: SizeConfig().screenWidth / 2,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      width: 100.toWidth,
                                      child: Text(
                                        '${widget?.selectedList[0]?.atsign}',
                                        style:
                                            CustomTextStyles.secondaryRegular14,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    // width: 100.toWidth,
                                    child: Text(
                                      widget.selectedList.length - 1 == 0
                                          ? ''
                                          : widget.selectedList.length - 1 == 1
                                              ? ' and ${widget.selectedList.length - 1} other'
                                              : ' and ${widget.selectedList.length - 1} others',
                                      style:
                                          CustomTextStyles.secondaryRegular14,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 10.toWidth,
                      ),
                      // Expanded(child: Container()),
                    ],
                  )
                ],
              ),
            ),
            Positioned(
              top: 10.toHeight,
              right: 0,
              child: Container(
                width: 20.toWidth,
                child: Icon(
                  (isExpanded)
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 25,
                ),
              ),
            ),
            (isExpanded)
                ? Positioned(
                    top: 50.toHeight,
                    child: Consumer<FileTransferProvider>(
                      builder: (context, provider, __) {
                        return Container(
                          height: 350,
                          width: 350,
                          child: GridView.count(
                            crossAxisCount:
                                SizeConfig().isTablet(context) ? 6 : 5,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5,
                            childAspectRatio: 1 / 1.7,
                            physics: NeverScrollableScrollPhysics(),
                            children: List.generate(
                              widget.selectedList.length,
                              (index) {
                                bool isNotified = widget
                                    .selectedList[index].isNotificationSend;

                                String name = CommonFunctions().getContactName(
                                    widget.selectedList[index].atsign);

                                Uint8List image = CommonFunctions()
                                    .getCachedContactImage(
                                        widget.selectedList[index].atsign);

                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(35.toHeight * 2),
                                  ),
                                  child: atsignResharing[index]
                                      ? TypingIndicator(
                                          showIndicator: true,
                                          flashingCircleBrightColor:
                                              ColorConstants.dullText,
                                          flashingCircleDarkColor:
                                              ColorConstants.fadedText,
                                        )
                                      : Stack(
                                          children: [
                                            Container(
                                                width: 80.toHeight,
                                                height: 160.toHeight,
                                                child: image != null
                                                    ? DesktopCustomPersonVerticalTile(
                                                        title: widget
                                                            .selectedList[index]
                                                            .atsign,
                                                        subTitle: name,
                                                        showCancelIcon: false,
                                                        showImage: true,
                                                        image: image)
                                                    : DesktopCustomPersonVerticalTile(
                                                        title: widget
                                                            .selectedList[index]
                                                            .atsign,
                                                        subTitle: name,
                                                        showCancelIcon: false)),
                                            Positioned(
                                                right: 0,
                                                child: Container(
                                                  height: SizeConfig()
                                                          .isDesktop(context)
                                                      ? 20
                                                      : null,
                                                  width: SizeConfig()
                                                          .isDesktop(context)
                                                      ? 20
                                                      : null,
                                                  decoration: BoxDecoration(
                                                    color: isNotified
                                                        ? Color(0xFF08CB21)
                                                        : Color(0xFFF86061),
                                                    border: Border.all(
                                                        color: isNotified
                                                            ? Color(0xFF08CB21)
                                                            : Color(0xFFF86061),
                                                        width: 5),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            35.toHeight),
                                                  ),
                                                  child: InkWell(
                                                    onTap: () async {
                                                      if (isNotified) {
                                                        return;
                                                      }

                                                      setState(() {
                                                        atsignResharing[index] =
                                                            true;
                                                      });
                                                      await Provider.of<
                                                                  FileTransferProvider>(
                                                              context,
                                                              listen: false)
                                                          .reSendFileNotification(
                                                              widget
                                                                  .fileHistory,
                                                              widget
                                                                  .selectedList[
                                                                      index]
                                                                  .atsign);

                                                      atsignResharing[index] =
                                                          false;
                                                    },
                                                    child: Icon(
                                                      isNotified
                                                          ? Icons.done
                                                          : Icons.refresh,
                                                      color: Colors.white,
                                                      size: SizeConfig()
                                                              .isDesktop(
                                                                  context)
                                                          ? 10.toFont
                                                          : 15.toFont,
                                                    ),
                                                  ),
                                                ))
                                          ],
                                        ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Positioned(
                    top: 20.toHeight,
                    child: Container(),
                  )
          ],
        ),
      ),
    );
  }
}
