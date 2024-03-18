import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GroupsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;
  final Function()? onBack;

  const GroupsAppBar({
    required this.title,
    this.actions = const [],
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            SizedBox(width: 8),
            InkWell(
              onTap: onBack ??
                  () {
                    Navigator.pop(context);
                  },
              child: SizedBox(
                width: 24,
                height: 24,
                child: SvgPicture.asset(
                  AppVectors.icBack,
                  height: 20,
                  width: 8,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ),
            SizedBox(width: 32),
            Text(
              title,
              style: CustomTextStyles.desktopPrimaryW50018,
            ),
            Spacer(),
            ...actions
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(28);
}
