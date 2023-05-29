import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/data_models/enums/file_category_type.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/filter_option_item.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';

class FilterHistoryWidget extends StatefulWidget {
  final Offset? position;
  final Function(HistoryType historyType)? onSelectedFilter;
  final Function(List<FileType> fileTypes)? onSelectedOptionalFilter;
  final HistoryType? typeSelected;
  final List<FileType>? listFileType;

  FilterHistoryWidget({
    Key? key,
    this.position,
    this.onSelectedFilter,
    this.typeSelected,
    this.onSelectedOptionalFilter,
    this.listFileType,
  }) : super(key: key);

  @override
  State<FilterHistoryWidget> createState() => _FilterHistoryWidgetState();
}

class _FilterHistoryWidgetState extends State<FilterHistoryWidget> {
  bool isShowOptional = false;
  List<FileType> listFileType = [];

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
  void initState() {
    listFileType = widget.listFileType ?? [];
    super.initState();
  }

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
                      if (historyTypes[index] == HistoryType.all) {
                        return FilterOptionItem(
                          icon: historyTypes[index].icon,
                          title: historyTypes[index].text,
                          isCheck: historyTypes[index] == widget.typeSelected,
                          isAllOption: true,
                          isShowOptional: isShowOptional,
                          allOptionOnTap: () {
                            setState(() {
                              isShowOptional = !isShowOptional;
                            });
                          },
                          borderRadius: isShowOptional
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
                        borderRadius: index == 0
                            ? BorderRadius.vertical(
                                top: Radius.circular(13),
                              )
                            : null,
                        onTap: () {
                          widget.onSelectedFilter?.call(
                            historyTypes[index],
                          );
                        },
                      );
                    },
                  ),
                ),
                if (isShowOptional) ...[
                  Divider(
                    color: ColorConstants.disableColor,
                    height: 0,
                    thickness: 1,
                    // thickness: 0.65,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 30.toWidth,
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: optionalHistoryTypes.length,
                      separatorBuilder: (context, index) {
                        return Divider(
                          color: listFileType
                              .contains(optionalHistoryTypes[index])
                              ? ColorConstants.orange
                              : ColorConstants.disableColor,
                          height: 0,
                          thickness: 1,
                          // thickness: 0.65,
                        );
                      },
                      itemBuilder: (context, index) {
                        return FilterOptionItem(
                          icon: optionalHistoryTypes[index].icon,
                          title: optionalHistoryTypes[index].text,
                          isOptional: true,
                          isCheck: listFileType
                              .contains(optionalHistoryTypes[index]),
                          borderRadius: index == optionalHistoryTypes.length - 1
                              ? BorderRadius.vertical(
                                  bottom: Radius.circular(13),
                                )
                              : null,
                          onTap: () {
                            final fileType = optionalHistoryTypes[index];
                            if (listFileType.isNotEmpty &&
                                listFileType.contains(fileType)) {
                              listFileType.remove(fileType);
                            } else {
                              listFileType.add(fileType);
                            }
                            widget.onSelectedOptionalFilter?.call(listFileType);
                          },
                        );
                      },
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}
