import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/data_models/enums/file_category_type.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/filter_option_item.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';

class FilterHistoryWidget extends StatefulWidget {
  final Offset? position;
  final Function(HistoryType historyType)? onSelectedFilter;
  final Function(FileType fileType)? onSelectedOptionalFilter;
  final Function(bool)? setOrder;
  final bool isDesc;
  final HistoryType? typeSelected;

  FilterHistoryWidget({
    Key? key,
    this.position,
    this.onSelectedFilter,
    this.setOrder,
    this.isDesc = true,
    this.typeSelected,
    this.onSelectedOptionalFilter,
  }) : super(key: key);

  @override
  State<FilterHistoryWidget> createState() => _FilterHistoryWidgetState();
}

class _FilterHistoryWidgetState extends State<FilterHistoryWidget> {
  bool isShowOptional = false;
  final List<HistoryType> historyTypes = [
    HistoryType.received,
    HistoryType.send,
    HistoryType.all,
  ];

  final List<FileType> optionalHistoryTypes = [
    FileType.photo,
    FileType.file,
    FileType.audio,
    FileType.video,
    FileType.zips,
    FileType.other,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
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
            top: widget.position?.dy,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - 30.toWidth,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: historyTypes.length,
                    separatorBuilder: (context, index) {
                      return Divider(
                        color: ColorConstants.disableColor,
                        height: 0,
                        thickness: 1,
                        // thickness: 0.65,
                      );
                    },
                    itemBuilder: (context, index) {
                      if (index == 0 || index == historyTypes.length - 1) {
                        return FilterOptionItem(
                          icon: historyTypes[index].icon,
                          title: historyTypes[index].text,
                          isCheck: historyTypes[index] == widget.typeSelected,
                          isAllOption: historyTypes[index] == HistoryType.all,
                          allOptionOnTap: () {
                            setState(() {
                              isShowOptional = !isShowOptional;
                            });
                          },
                          borderRadius: index == 0
                              ? BorderRadius.vertical(
                                  top: Radius.circular(13),
                                )
                              : isShowOptional ||
                                      widget.typeSelected == HistoryType.all
                                  ? null
                                  : BorderRadius.vertical(
                                      bottom: Radius.circular(13),
                                    ),
                          onTap: () {
                            widget.onSelectedFilter?.call(
                              historyTypes[index],
                            );
                          },
                        );
                      }
                      return FilterOptionItem(
                        icon: historyTypes[index].icon,
                        title: historyTypes[index].text,
                        isCheck: historyTypes[index] == widget.typeSelected,
                        onTap: () {
                          widget.onSelectedFilter?.call(
                            historyTypes[index],
                          );
                        },
                      );
                    },
                  ),
                ),
                if (isShowOptional || widget.typeSelected == HistoryType.all)
                  Divider(
                    color: ColorConstants.disableColor,
                    height: 0,
                    thickness: 1,
                    // thickness: 0.65,
                  ),
                if (isShowOptional || widget.typeSelected == HistoryType.all)
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 30.toWidth,
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: optionalHistoryTypes.length,
                      separatorBuilder: (context, index) {
                        return Divider(
                          color: widget.typeSelected == HistoryType.all
                              ? ColorConstants.orange
                              : ColorConstants.disableColor,
                          height: 0,
                          thickness: 1,
                          // thickness: 0.65,
                        );
                      },
                      itemBuilder: (context, index) {
                        if (index == optionalHistoryTypes.length - 1) {
                          return FilterOptionItem(
                            icon: optionalHistoryTypes[index].icon,
                            title: optionalHistoryTypes[index].text,
                            isDisable: true,
                            isCheck: false,
                            borderRadius: index == 0
                                ? BorderRadius.vertical(
                                    top: Radius.circular(13),
                                  )
                                : BorderRadius.vertical(
                                    bottom: Radius.circular(13),
                                  ),
                            onTap: () {
                              widget.onSelectedOptionalFilter?.call(
                                optionalHistoryTypes[index],
                              );
                            },
                          );
                        }
                        return FilterOptionItem(
                          icon: optionalHistoryTypes[index].icon,
                          title: optionalHistoryTypes[index].text,
                          isDisable: true,
                          isCheck: false,
                          onTap: () {
                            widget.onSelectedOptionalFilter?.call(
                              optionalHistoryTypes[index],
                            );
                          },
                        );
                      },
                    ),
                  ),
                /*SizedBox(
                  width: MediaQuery.of(context).size.width - 30.toWidth,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: FileType.values.length,
                    itemBuilder: (context, index) {
                      return FilterOptionItem(
                        icon: FileType.values[index].icon,
                        title: FileType.values[index].text,
                        onTap: (){

                        },
                      );
                    },
                  ),
                ),*/
                /*Container(
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
                ),*/
              ],
            ),
          ),
        ],
      ),
    );
  }
}
