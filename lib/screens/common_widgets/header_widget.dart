import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HeaderWidget extends StatefulWidget {
  final Function()? onReloadCallback;
  final TextEditingController? controller;
  final Function(String)? onSearch;
  final EdgeInsetsGeometry? margin;

  const HeaderWidget({
    Key? key,
    this.onReloadCallback,
    this.controller,
    this.onSearch,
    this.margin,
  }) : super(key: key);

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  bool isSearch = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 28),
      padding: const EdgeInsets.fromLTRB(14, 11, 8, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: ColorConstants.textBoxBg,
      ),
      child: Row(
        children: <Widget>[
          _buildButton(
            title: "Refresh",
            icon: AppVectors.icReload,
            onTap: widget.onReloadCallback,
          ),
          const SizedBox(width: 24),
          Expanded(
            child: _buildSearchWidget(),
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
          const SizedBox(height: 5),
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: ColorConstants.grey,
              ),
              color: Colors.white,
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
    return Column(
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
        const SizedBox(height: 5),
        Container(
          height: 48,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: ColorConstants.grey,
            ),
            color: Colors.white,
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
                      color: ColorConstants.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  onChanged: widget.onSearch,
                ),
              ),
              SizedBox(width: 4),
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
    );
  }
}
