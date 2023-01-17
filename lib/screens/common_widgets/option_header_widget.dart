import 'package:atsign_atmosphere_pro/data_models/enums/file_types.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OptionHeaderWidget extends StatefulWidget {
  final Function? onReloadCallback;
  final Function? onSearchCallback;
  final bool hideReloadIcon;
  final Function? selectTypeCallback;

  OptionHeaderWidget({
    Key? key,
    this.onReloadCallback,
    this.onSearchCallback,
    this.hideReloadIcon = true,
    this.selectTypeCallback,
  }) : super(key: key);

  @override
  State<OptionHeaderWidget> createState() => _OptionHeaderWidgetState();
}

class _OptionHeaderWidgetState extends State<OptionHeaderWidget> {
  FileTypes? typeSelected = FileTypes.all;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 28),
      padding: EdgeInsets.fromLTRB(14, 11, 15, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: ColorConstants.textBoxBg,
      ),
      child: Row(
        children: <Widget>[
          Visibility(
            visible: widget.hideReloadIcon,
            child: _buildButton(
                title: "Refresh",
                icon: AppVectors.icReload,
                onTap: widget.onReloadCallback),
          ),
          SizedBox(width: 12),
          _buildButton(
            title: "Search",
            icon: AppVectors.icSearch,
            onTap: widget.onSearchCallback,
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Delivery Type",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ColorConstants.sidebarTextUnselected,
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  height: 48,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: ColorConstants.grey,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: DropdownButtonHideUnderline(
                    child: Padding(
                      padding: EdgeInsets.zero,
                      child: DropdownButton<FileTypes>(
                        value: typeSelected,
                        icon: SvgPicture.asset(
                          AppVectors.icArrowDown,
                        ),
                        isExpanded: true,
                        underline: null,
                        alignment: AlignmentDirectional.bottomEnd,
                        hint: Text(
                          "All",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: ColorConstants.grey,
                          ),
                        ),
                        items: FileTypes.values.map(
                          (key) {
                            return DropdownMenuItem<FileTypes>(
                              value: key,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            key.text,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: ColorConstants.grey,
                                            ),
                                          ),
                                        ),
                                        typeSelected == key
                                            ? SvgPicture.asset(
                                                AppVectors.icCheck,
                                                // color: Colors.green,
                                              )
                                            : SvgPicture.asset(
                                                AppVectors.icUnCheck,
                                                // color: Colors.green,
                                              ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    color: ColorConstants.sidebarTileSelected,
                                    height: 2,
                                    width: double.infinity,
                                  )
                                ],
                              ),
                            );
                          },
                        ).toList(),
                        selectedItemBuilder: (BuildContext context) {
                          return FileTypes.values.map(
                            (key) {
                              return DropdownMenuItem<FileTypes>(
                                value: key,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      child: Text(
                                        key.text,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: ColorConstants.grey,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      color: ColorConstants.sidebarTileSelected,
                                      height: 1,
                                      width: double.infinity,
                                    )
                                  ],
                                ),
                              );
                            },
                          ).toList();
                        },
                        onChanged: (value) {
                          setState(
                            () {
                              typeSelected = value;
                            },
                          );
                          widget.selectTypeCallback?.call();
                        },
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    String? title,
    required String icon,
    Function? onTap,
  }) {
    return InkWell(
      onTap: onTap?.call(),
      child: Column(
        children: <Widget>[
          Text(
            title ?? '',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ColorConstants.sidebarTextUnselected,
            ),
          ),
          SizedBox(height: 5),
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: ColorConstants.grey,
              ),
            ),
            child: Center(
              child: SvgPicture.asset(icon),
            ),
          )
        ],
      ),
    );
  }
}
