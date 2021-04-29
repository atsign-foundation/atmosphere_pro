import 'dart:typed_data';
import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer_status.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/file_transfer_contacts.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:provider/provider.dart';

class TranferOverlappingContacts extends StatefulWidget {
  final List<AtContact> selectedList;

  const TranferOverlappingContacts({
    Key key,
    this.selectedList,
  }) : super(key: key);

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
    widget.selectedList.removeAt(0);
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
              children: List<Positioned>.generate(
                (widget.selectedList.length > 3)
                    ? 3
                    : widget.selectedList.length,
                (index) {
                  Uint8List image;
                  if (widget?.selectedList[index]?.tags != null &&
                      widget?.selectedList[index]?.tags['image'] != null) {
                    List<int> intList =
                        widget?.selectedList[index]?.tags['image'].cast<int>();
                    image = Uint8List.fromList(intList);
                  }

                  return Positioned(
                    left: 5 + double.parse((index * 10).toString()),
                    top: 5.toHeight,
                    child: Container(
                      height: 28.toHeight,
                      width: 28.toHeight,
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: (widget?.selectedList[index]?.tags != null &&
                              widget?.selectedList[index]?.tags['image'] !=
                                  null)
                          ? CustomCircleAvatar(
                              byteImage: image,
                              nonAsset: true,
                            )
                          : ContactInitial(
                              initials: widget?.selectedList[index]?.atSign
                                      ?.substring(1, 3) ??
                                  'hello',
                            ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 5.toHeight,
              left: 40 +
                  double.parse((widget.selectedList.length * 25).toString()),
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
                              width: 160.toWidth,
                              child: Row(
                                children: [
                                  Container(
                                    width: 60.toWidth,
                                    child: Text(
                                      '${widget?.selectedList[0]?.atSign}',
                                      style:
                                          CustomTextStyles.secondaryRegular14,
                                      overflow: TextOverflow.ellipsis,
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
                            crossAxisCount: 5,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5,
                            children: List.generate(
                              widget.selectedList.length,
                              (index) {
                                // TransferStatus individualStatus =
                                //     provider.getStatus(widget.id,
                                //         widget.selectedList[index].atSign);
                                // return FileTransferContacts(
                                //   contact: widget.selectedList[index],
                                //   status: individualStatus,
                                // );
                                return ContactInitial(
                                  initials: widget.selectedList[index].atSign
                                      .substring(1, 3),
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
