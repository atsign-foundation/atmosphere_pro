import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/filter_option_item.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FilterHistoryWidget extends StatelessWidget {
  final Offset? position;
  final Function(HistoryType type)? onSelected;
  final Function(bool)? setOrder;
  final bool isDesc;
  final HistoryType? typeSelected;

  FilterHistoryWidget({
    Key? key,
    this.position,
    this.onSelected,
    this.setOrder,
    this.isDesc = true,
    this.typeSelected,
  }) : super(key: key);

  final List<HistoryType> historyTypes = [
    HistoryType.received,
    HistoryType.send,
    HistoryType.all,
  ];

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
              top: position?.dy,
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
                            print(value);
                            setOrder?.call(value);
                          },
                        )
                      ],
                    ),
                  ),
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
                          height: 1,
                          // thickness: 0.65,
                        );
                      },
                      itemBuilder: (context, index) {
                        return FilterOptionItem(
                          icon: historyTypes[index].icon,
                          title: historyTypes[index].text,
                          isCheck: historyTypes[index] == typeSelected,
                          onTap: () {
                            onSelected?.call(
                              historyTypes[index],
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
      ),
    );
  }
}
