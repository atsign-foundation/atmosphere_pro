import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FilterHistoryWidget extends StatefulWidget {
  final Offset position;
  final Function(int) onSelected;
  final Function(bool) setOrder;

  FilterHistoryWidget({
    Key? key,
    required this.position,
    required this.onSelected,
    required this.setOrder,
  }) : super(key: key);

  @override
  State<FilterHistoryWidget> createState() => _FilterHistoryWidgetState();
}

class _FilterHistoryWidgetState extends State<FilterHistoryWidget> {
  bool isDesc = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Stack(
          children: [
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                color: Colors.transparent,
                height: double.infinity,
                width: double.infinity,
              ),
            ),
            Positioned(
              right: 15,
              top: widget.position.dy,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width - 30.toWidth,
                    height: 40,
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      color: Colors.black,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              isDesc
                                  ? AppVectors.icArrowDesc
                                  : AppVectors.icArrowAsc,
                              width: 8,
                              height: 12,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(width: 20),
                            Text(
                              'Date',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ],
                        ),
                        Switch(
                          trackColor: MaterialStateColor.resolveWith((states) {
                            if (states.contains(MaterialState.selected)) {
                              return Colors.white;
                            }
                            return ColorConstants.disableBackgroundColor;
                          }),
                          thumbColor: MaterialStateColor.resolveWith((states) {
                            if (states.contains(MaterialState.selected)) {
                              return ColorConstants.orange;
                            }
                            return Colors.white;
                          }),
                          value: isDesc,
                          onChanged: (value) {
                            setState(() {
                              isDesc = value;
                            });
                            widget.setOrder;
                          },
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 30.toWidth,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(12),
                      ),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        if (index > 2) {
                          return _buildFilterOptionItem(
                            icon: filterOptionsList.keys.elementAt(index),
                            title: filterOptionsList.values.elementAt(index),
                            isCheck: true,
                            isDisable: true,
                            index: index,
                          );
                        } else {
                          return _buildFilterOptionItem(
                            icon: filterOptionsList.keys.elementAt(index),
                            title: filterOptionsList.values.elementAt(index),
                            isCheck: false,
                            index: index,
                          );
                        }
                      },
                      separatorBuilder: (context, index) {
                        return Divider(
                          //TODO: add isDisable variable to check
                          color: (index > 2 && true)
                              ? ColorConstants.disableColor
                              : ColorConstants.lightSliver,
                          height: 0,
                          indent: 0,
                          thickness: 0.65,
                        );
                      },
                      itemCount: filterOptionsList.length,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOptionItem({
    required String icon,
    required String title,
    bool isDisable = false,
    required bool isCheck,
    required int index,
  }) {
    Color color =
        isDisable && index > 2 ? ColorConstants.disableColor : Colors.black;
    Color backgroundColor = isDisable && index > 2
        ? ColorConstants.disableBackgroundColor
        : Colors.white;
    return InkWell(
      onTap: () {},
      child: Container(
        height: 36,
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: index == filterOptionsList.length - 1
              ? BorderRadius.vertical(bottom: Radius.circular(12))
              : BorderRadius.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                icon.isNotEmpty
                    ? SvgPicture.asset(
                        icon,
                        color: color,
                        height: 16,
                        width: 12,
                        fit: BoxFit.cover,
                      )
                    : SizedBox(width: 12),
                SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SvgPicture.asset(
              isCheck ? AppVectors.icChecked : AppVectors.icUnchecked,
              width: 16,
              height: 16,
              color: color,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }

  Map<String, String> filterOptionsList = {
    AppVectors.icReceived: 'Received',
    AppVectors.icSent: 'Sent',
    '': 'All',
    AppVectors.icPhotos: 'Photos',
    AppVectors.icFiles: 'Files',
    AppVectors.icAudio: 'Audio',
    AppVectors.icVideos: 'Videos',
    AppVectors.icZips: 'Zips',
    AppVectors.icOther: 'Other'
  };
}
