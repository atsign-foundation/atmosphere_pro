import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class DesktopHeader extends StatelessWidget {
  final String? title;
  final ValueChanged<bool>? onFilter;
  List<Widget>? actions;
  Function onBackTap;
  List<String> options = [
    'By type',
    'By name',
    'By size',
    'By date',
    'add-btn'
  ];
  bool showBackIcon, isTitleCentered;

  DesktopHeader({
    Key? key,
    required this.onBackTap,
    this.title,
    this.showBackIcon = true,
    this.onFilter,
    this.actions,
    this.isTitleCentered = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 68, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: <Widget>[
              if (showBackIcon) ...[
                InkWell(
                  onTap: () {
                    onBackTap();
                  },
                  child: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 32),
              ],

              title != null
                  ? Expanded(
                      child: isTitleCentered
                          ? Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Center(
                                child: Text(
                                  title!,
                                  style: CustomTextStyles.primaryRegular20,
                                ),
                              ),
                            )
                          : Text(
                              title!,
                              style: CustomTextStyles.raisinBlackW60025,
                            ),
                    )
                  : const SizedBox(),
              const SizedBox(width: 15),
              // !isTitleCentered ? Expanded(child: SizedBox()) : SizedBox(),
              actions != null
                  ? Row(
                      children: actions!,
                    )
                  : const SizedBox()
            ],
          ),
          const SizedBox(height: 16),
          const Divider(
            height: 0.5,
            color: Colors.black,
          )
        ],
      ),
    );
  }
}
