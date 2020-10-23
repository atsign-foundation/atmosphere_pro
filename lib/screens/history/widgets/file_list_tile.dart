import 'dart:io';

import 'package:atsign_atmosphere_app/data_models/file_modal.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_app/screens/history/widgets/%20add_contact_from_history.dart';
import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/images.dart';
import 'package:atsign_atmosphere_app/utils/text_styles.dart';
import 'package:atsign_atmosphere_app/view_models/contact_provider.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class FilesListTile extends StatefulWidget {
  final FilesModel sentHistory;
  final ContactProvider contactProvider;

  const FilesListTile({Key key, this.sentHistory, this.contactProvider})
      : super(key: key);
  @override
  _FilesListTileState createState() => _FilesListTileState();
}

class _FilesListTileState extends State<FilesListTile> {
  bool isOpen = false;
  DateTime sendTime;

  @override
  Widget build(BuildContext context) {
    sendTime = DateTime.parse(widget.sentHistory.date);
    return Column(
      children: [
        ListTile(
          leading: CustomCircleAvatar(image: ImageConstants.imagePlaceholder),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.sentHistory.name.substring(1),
                      style: CustomTextStyles.primaryRegular16,
                    ),
                  ),
                  widget.contactProvider.allContactsList
                          .contains(widget.sentHistory.name)
                      ? SizedBox()
                      : GestureDetector(
                          onTap: () async {
                            await showDialog(
                              context: context,
                              builder: (context) => AddHistoryContactDialog(
                                atSignName: widget.sentHistory.name,
                                contactProvider: widget.contactProvider,
                              ),
                            );
                            this.setState(() {});
                          },
                          child: Container(
                            height: 20.toHeight,
                            width: 20.toWidth,
                            child: Icon(
                              Icons.add,
                              color: Colors.black,
                            ),
                          ),
                        )
                ],
              ),
              SizedBox(height: 5.toHeight),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.sentHistory.name,
                      style: CustomTextStyles.secondaryRegular12,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 8.toHeight,
              ),
              Container(
                // width: 100.toWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.sentHistory.files.length} Files',
                      style: CustomTextStyles.secondaryRegular12,
                    ),
                    SizedBox(width: 10.toHeight),
                    Text(
                      '.',
                      style: CustomTextStyles.secondaryRegular12,
                    ),
                    SizedBox(width: 10.toHeight),
                    Text(
                      '${(widget.sentHistory.totalSize / 1024).toStringAsFixed(2)} Kb',
                      style: CustomTextStyles.secondaryRegular12,
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20.toHeight,
              ),
              Container(
                width: 150.toWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '${DateFormat('MM-dd-yyyy').format(sendTime)}',
                      style: CustomTextStyles.secondaryRegular12,
                    ),
                    SizedBox(width: 10.toHeight),
                    Container(
                      color: ColorConstants.fontSecondary,
                      height: 14.toHeight,
                      width: 1.toWidth,
                    ),
                    SizedBox(width: 10.toHeight),
                    Text(
                      '${DateFormat('kk:mm').format(sendTime)}',
                      style: CustomTextStyles.secondaryRegular12,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 3.toHeight,
              ),
              (!isOpen)
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          isOpen = !isOpen;
                        });
                      },
                      child: Container(
                        width: 140.toWidth,
                        child: Row(
                          children: [
                            Text(
                              'More Details',
                              style: CustomTextStyles.primaryBold14,
                            ),
                            Container(
                              width: 22.toWidth,
                              height: 22.toWidth,
                              child: Center(
                                child: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.black,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
        (isOpen)
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 66.0 * widget.sentHistory.files.length,
                    child: ListView.separated(
                      separatorBuilder: (context, index) => Divider(
                        indent: 80.toWidth,
                      ),
                      itemCount:
                          int.parse(widget.sentHistory.files.length.toString()),
                      itemBuilder: (context, index) => ListTile(
                        leading: Container(
                            height: 50.toHeight,
                            width: 50.toHeight,
                            child: Image.file(
                                File(
                                  widget.sentHistory.files[index].filePath,
                                ),
                                fit: BoxFit.cover)),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.sentHistory.files[index].fileName
                                        .toString(),
                                    style: CustomTextStyles.primaryRegular16,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 10.toHeight),
                            Container(
                              // width: 80.toWidth,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    '${(widget.sentHistory.files[index].size / 1024).toStringAsFixed(2)} Kb',
                                    style: CustomTextStyles.secondaryRegular12,
                                  ),
                                  SizedBox(width: 10.toHeight),
                                  Text(
                                    '.',
                                    style: CustomTextStyles.secondaryRegular12,
                                  ),
                                  SizedBox(width: 10.toHeight),
                                  Text(
                                    // 'JPG',
                                    widget.sentHistory.files[index].type
                                        .toString(),
                                    style: CustomTextStyles.secondaryRegular12,
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isOpen = !isOpen;
                      });
                    },
                    child: Container(
                      width: 140.toWidth,
                      margin: EdgeInsets.only(left: 85.toWidth),
                      child: Row(
                        children: [
                          Text(
                            'Lesser Details',
                            style: CustomTextStyles.primaryBold14,
                          ),
                          Container(
                            width: 22.toWidth,
                            height: 22.toWidth,
                            child: Center(
                              child: Icon(
                                Icons.keyboard_arrow_up,
                                color: Colors.black,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Container()
      ],
    );
  }
}
