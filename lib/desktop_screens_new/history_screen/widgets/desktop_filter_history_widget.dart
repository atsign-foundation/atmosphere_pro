import 'package:atsign_atmosphere_pro/data_models/enums/file_category_type.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/history_screen/widgets/desktop_filter_option_item.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DesktopFilterHistoryWidget extends StatefulWidget {
  final Offset? position;
  final Function(HistoryType historyType)? onSelectedFilter;
  final Function(List<FileType> fileTypes)? onSelectedOptionalFilter;
  final HistoryType? typeSelected;
  final List<FileType>? listFileType;

  const DesktopFilterHistoryWidget({
    Key? key,
    this.position,
    this.onSelectedFilter,
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
  bool isCheck = true;

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
            ),
          ),
          Positioned(
            right: 15,
            top: 100,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    color: Theme.of(context).primaryColor,
                  ),
                  width: 400,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "All File Types",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            isCheck = !isCheck;
                            isCheck
                                ? listFileType.addAll(optionalHistoryTypes)
                                : listFileType = [];
                          });
                        },
                        child: SvgPicture.asset(
                          isCheck
                              ? AppVectors.icChecked
                              : AppVectors.icUnchecked,
                          width: 24,
                          height: 24,
                          color: Colors.white,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  color: ColorConstants.disableColor,
                  height: 0,
                  thickness: 1,
                ),
                SizedBox(
                  width: 400,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: optionalHistoryTypes.length,
                    separatorBuilder: (context, index) {
                      return Divider(
                        color:
                            listFileType.contains(optionalHistoryTypes[index])
                                ? ColorConstants.orange
                                : ColorConstants.disableColor,
                        height: 0,
                        thickness: 1,
                      );
                    },
                    itemBuilder: (context, index) {
                      return DesktopFilterOptionItem(
                        icon: optionalHistoryTypes[index].icon,
                        title: optionalHistoryTypes[index].text,
                        isOptional: true,
                        isCheck:
                            listFileType.contains(optionalHistoryTypes[index]),
                        borderRadius: index == optionalHistoryTypes.length - 1
                            ? const BorderRadius.vertical(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
