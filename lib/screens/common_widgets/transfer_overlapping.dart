import 'dart:typed_data';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:provider/provider.dart';

class TranferOverlappingContacts extends StatefulWidget {
  final List<ShareStatus> selectedList;
  final FileHistory fileHistory;

  const TranferOverlappingContacts(
      {Key key, this.selectedList, this.fileHistory})
      : super(key: key);

  @override
  _TranferOverlappingContactsState createState() =>
      _TranferOverlappingContactsState();
}

class _TranferOverlappingContactsState
    extends State<TranferOverlappingContacts> {
  bool isExpanded = false;
  int noOfContactsRow = 0;
  @override
  void initState() {
    widget.selectedList;
    noOfContactsRow = (widget.selectedList.length / 5).ceil();
    print('noOfContactsRow: ${noOfContactsRow}');
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
              children: List<Positioned>.generate(
                (widget.selectedList.length > 3)
                    ? 3
                    : widget.selectedList.length,
                (index) {
                  Uint8List image = getCachedContactImage(
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
                  size: 15.toFont,
                ),
              ),
            ),
            (isExpanded)
                ? Positioned(
                    top: 50.toHeight,
                    child: Consumer<FileTransferProvider>(
                      builder: (context, provider, __) {
                        return Container(
                          height: 200.toHeight,
                          width: SizeConfig().screenWidth - 20.toWidth,
                          child: GridView.count(
                            crossAxisCount:
                                SizeConfig().isTablet(context) ? 6 : 5,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5,
                            childAspectRatio: 1,
                            children: List.generate(
                              widget.selectedList.length,
                              (index) {
                                bool isNotified = widget
                                    .selectedList[index].isNotificationSend;

                                Uint8List image = getCachedContactImage(
                                    widget.selectedList[index].atsign);

                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: isNotified
                                            ? Color(0xFF08CB21)
                                            : Color(0xFFF86061),
                                        width: 5),
                                    borderRadius:
                                        BorderRadius.circular(35.toHeight * 2),
                                  ),
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 90.toHeight,
                                        height: 90.toHeight,
                                        child: image != null
                                            ? CustomCircleAvatar(
                                                byteImage: image,
                                                nonAsset: true,
                                              )
                                            : ContactInitial(
                                                initials: widget
                                                    .selectedList[index].atsign,
                                                size: 40,
                                              ),
                                      ),
                                      Positioned(
                                          right: 0,
                                          child: Container(
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
                                              onTap: () {
                                                if (isNotified) {
                                                  return;
                                                }
                                                Provider.of<FileTransferProvider>(
                                                        context,
                                                        listen: false)
                                                    .sendFileNotification(
                                                        widget.fileHistory,
                                                        widget
                                                            .selectedList[index]
                                                            .atsign);
                                              },
                                              child: Icon(
                                                isNotified
                                                    ? Icons.done
                                                    : Icons.sync_sharp,
                                                color: Colors.white,
                                                size: 15.toFont,
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

  getCachedContactImage(String atsign) {
    Uint8List image;
    AtContact contact = checkForCachedContactDetail(atsign);

    if (contact != null &&
        contact.tags != null &&
        contact.tags['image'] != null) {
      List<int> intList = contact.tags['image'].cast<int>();
      image = Uint8List.fromList(intList);
    }

    return image;
  }
}
