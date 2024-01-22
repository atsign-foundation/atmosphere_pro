import 'dart:convert';
import 'dart:io';

import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/file_utils.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:open_file/open_file.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HistoryImagePreview extends StatefulWidget {
  final List<FileData> data;
  final int index;
  final String? fileTransferId;
  final String nickname;
  final String sender;
  final String notes;
  final String shortDate;
  final String time;
  final HistoryType? type;
  final Function() onDelete;

  const HistoryImagePreview({
    required this.data,
    required this.index,
    required this.fileTransferId,
    required this.nickname,
    required this.sender,
    required this.notes,
    required this.shortDate,
    required this.time,
    required this.type,
    required this.onDelete,
  });

  @override
  State<HistoryImagePreview> createState() => _HistoryImagePreviewState();
}

class _HistoryImagePreviewState extends State<HistoryImagePreview> {
  late ValueNotifier<int> currentIndex = ValueNotifier<int>(widget.index);

  late PageController pageController =
      PageController(initialPage: widget.index);

  String imageToBase64(String imagePath) {
    File imageFile = File(imagePath);
    List<int> imageBytes = imageFile.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);
    return base64Image;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 32),
            child: InkWell(
              onTap: () {
                Navigator.pop(NavService.navKey.currentContext!);
              },
              child: Icon(
                Icons.clear,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Expanded(
          child: InkWell(
            onTap: () async {
              await OpenFile.open(
                BackendService.getInstance().downloadDirectory!.path +
                    Platform.pathSeparator +
                    (widget.data[currentIndex.value].name ?? ''),
              );
            },
            child: PageView.builder(
              itemCount: widget.data.length,
              scrollDirection: Axis.horizontal,
              controller: pageController,
              physics: ClampingScrollPhysics(),
              onPageChanged: (value) {
                currentIndex.value = value;
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 33),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        base64Decode(
                          imageToBase64(widget.data[index].path ?? ''),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(
          height: 40,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: SvgPicture.asset(
                AppVectors.icCloudDownloaded,
                height: 50,
                width: 50,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
                  await FileUtils.moveToSendFile(
                      BackendService.getInstance().downloadDirectory!.path +
                          Platform.pathSeparator +
                          (widget.data[currentIndex.value].name ?? ''));
                },
                child: SvgPicture.asset(
                  AppVectors.icSendFile,
                  height: 50,
                  width: 50,
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: GestureDetector(
                onTap: () async {
                  await FileUtils.deleteFile(
                    widget.data[currentIndex.value].path ?? '',
                    fileTransferId: widget.fileTransferId,
                    onComplete: () {
                      Navigator.pop(context);
                      widget.onDelete.call();
                    },
                    type: widget.type ?? HistoryType.send,
                  );
                },
                child: SvgPicture.asset(
                  AppVectors.icDeleteFile,
                  height: 50,
                  width: 50,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 40,
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.symmetric(horizontal: 25),
          width: double.infinity,
          child: Column(
            children: [
              ValueListenableBuilder<int>(
                  valueListenable: currentIndex,
                  builder: (context, value, child) {
                    return AnimatedSmoothIndicator(
                      count: widget.data.length,
                      activeIndex: value,
                      effect: ColorTransitionEffect(
                        activeDotColor: ColorConstants.orange,
                        spacing: 12,
                      ),
                      onDotClicked: (index) {
                        currentIndex.value = index;
                        pageController.animateToPage(
                          index,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    );
                  }),
              SizedBox(height: 12),
              SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            widget.shortDate,
                            style: TextStyle(
                              fontSize: 12,
                              color: ColorConstants.oldSliver,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 8,
                            color: Color(0xFFD7D7D7),
                            margin: EdgeInsets.symmetric(
                              horizontal: 3,
                            ),
                          ),
                          Text(
                            widget.time,
                            style: TextStyle(
                              fontSize: 12,
                              color: ColorConstants.oldSliver,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    ValueListenableBuilder<int>(
                        valueListenable: currentIndex,
                        builder: (context, value, child) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (widget.data[value].name ?? ''),
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5),
                              Text(
                                double.parse(widget.data[value].size
                                            .toString()) <=
                                        1024
                                    ? '${widget.data[value].size} ' +
                                        TextStrings().kb
                                    : '${((widget.data[value].size ?? 0) / (1024 * 1024)).toStringAsFixed(2)} ' +
                                        TextStrings().mb,
                                style: TextStyle(
                                  color: ColorConstants.grey,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ],
                          );
                        }),
                    SizedBox(height: 10),
                    widget.nickname.isNotEmpty
                        ? Text(
                            widget.nickname,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          )
                        : SizedBox(),
                    SizedBox(height: 5),
                    Text(
                      widget.sender,
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 10),
                    // fileDetail.message.isNotNull
                    //     ?
                    if (widget.notes.isNotEmpty) ...[
                      Text(
                        "Message",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      // : SizedBox(),
                      SizedBox(height: 5),
                      Text(
                        widget.notes,
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
