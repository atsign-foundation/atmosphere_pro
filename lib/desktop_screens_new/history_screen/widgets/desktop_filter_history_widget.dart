import 'package:atsign_atmosphere_pro/data_models/enums/file_category_type.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/history_screen/widgets/desktop_filter_option_item.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';

class DesktopFilterHistoryWidget extends StatefulWidget {
  final Offset? position;
  final Function(List<FileType> fileTypes)? onSelectedOptionalFilter;
  final HistoryType? typeSelected;
  final List<FileType>? listFileType;

  DesktopFilterHistoryWidget({
    Key? key,
    this.position,
    this.typeSelected,
    this.onSelectedOptionalFilter,
    this.listFileType,
  }) : super(key: key);

  @override
  State<DesktopFilterHistoryWidget> createState() =>
      _DesktopFilterHistoryWidgetState();
}

class _DesktopFilterHistoryWidgetState
    extends State<DesktopFilterHistoryWidget> {
  bool isShowOptional = false;
  List<FileType> listFileType = [];

  final List<FileType> optionalHistoryTypes = [
    FileType.photo,
    FileType.document,
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
            ),
          ),
          Positioned(
            right: 80,
            top: 100,
            child: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DesktopFilterOptionItem(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                    isAllOption: true,
                    title: 'All File Types',
                    isCheck: optionalHistoryTypes
                        .every((element) => listFileType.contains(element)),
                    onTap: () {
                      if (optionalHistoryTypes
                          .every((element) => listFileType.contains(element))) {
                        listFileType.clear();
                      } else {
                        optionalHistoryTypes.forEach(
                          (element) {
                            if (!listFileType.contains(element)) {
                              listFileType.add(element);
                            }
                          },
                        );
                      }
                      widget.onSelectedOptionalFilter?.call(listFileType);
                    },
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: optionalHistoryTypes.length,
                    separatorBuilder: (context, index) {
                      return Divider(
                        color: ColorConstants.orange,
                        height: 0,
                        thickness: 1,
                        // thickness: 0.65,
                      );
                    },
                    itemBuilder: (context, index) {
                      return DesktopFilterOptionItem(
                        icon: optionalHistoryTypes[index].icon,
                        title: optionalHistoryTypes[index].text,
                        isCheck:
                            listFileType.contains(optionalHistoryTypes[index]),
                        borderRadius: index == optionalHistoryTypes.length - 1
                            ? BorderRadius.vertical(
                                bottom: Radius.circular(10),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
