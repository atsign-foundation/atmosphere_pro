import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OptionHeaderWidget extends StatefulWidget {
  final Function()? onReloadCallback;
  final Function()? onSearchCallback;
  final bool hideReloadIcon;
  final Widget? filterWidget;
  final TextEditingController? controller;
  final Function(String)? onSearch;

  OptionHeaderWidget({
    Key? key,
    this.onReloadCallback,
    this.onSearchCallback,
    this.hideReloadIcon = true,
    this.filterWidget,
    this.controller,
    this.onSearch,
  }) : super(key: key);

  @override
  State<OptionHeaderWidget> createState() => _OptionHeaderWidgetState();
}

class _OptionHeaderWidgetState extends State<OptionHeaderWidget> {
  bool isSearch = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 28),
      padding: EdgeInsets.fromLTRB(14, 11, 15, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: ColorConstants.textBoxBg,
      ),
      child: isSearch
          ? _buildSearchWidget()
          : Row(
              children: <Widget>[
                Visibility(
                  visible: widget.hideReloadIcon,
                  child: _buildButton(
                    title: "Refresh",
                    icon: AppVectors.icReload,
                    onTap: widget.onReloadCallback,
                  ),
                ),
                SizedBox(width: 12),
                _buildButton(
                  title: "Search",
                  icon: AppVectors.icSearch,
                  onTap: () {
                    setState(() {
                      isSearch = true;
                    });
                    widget.onSearchCallback?.call();
                  },
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
                        child: widget.filterWidget,
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
    Function()? onTap,
  }) {
    return InkWell(
      onTap: () {
        onTap?.call();
      },
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
              child: SvgPicture.asset(
                icon,
                color: ColorConstants.grey,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSearchWidget() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Search",
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
                  // color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.only(left: 6, right: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        decoration: InputDecoration.collapsed(
                          hintText: 'Search History by atSign',
                          hintStyle: TextStyle(
                            color: ColorConstants.sidebarTextUnselected,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        onChanged: widget.onSearch,
                      ),
                    ),
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: SvgPicture.asset(
                        AppVectors.icSearch,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildButton(
          onTap: () {
            setState(() {
              isSearch = false;
            });
          },
          icon: AppVectors.icCancel,
        )
      ],
    );
  }
}
