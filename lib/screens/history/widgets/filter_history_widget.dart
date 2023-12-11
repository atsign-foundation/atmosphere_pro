import 'package:atsign_atmosphere_pro/data_models/enums/file_category_type.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/filter_option_item.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';

class FilterHistoryWidget extends StatefulWidget {
  final Offset? position;
  final Function(List<FileType> fileTypes)? onSelectedOptionalFilter;
  final HistoryType? typeSelected;
  final List<FileType>? listFileType;

  FilterHistoryWidget({
    Key? key,
    this.position,
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
              height: double.infinity,
              width: double.infinity,
            ),
          ),
          Positioned(
            right: 28,
            left: 28,
            top: widget.position?.dy,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilterOptionItem(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                  isAllOption: true,
                  title: 'All File Types',
                  isCheck: optionalHistoryTypes
                      .every((element) => listFileType.contains(element)),
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
                    return FilterOptionItem(
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
        ],
      ),
    );
  }
}
