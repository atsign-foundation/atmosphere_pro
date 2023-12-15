import 'package:at_backupkey_flutter/utils/size_config.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_route_names.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/my_files_screen/utils/file_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FilesCategoryWidget extends StatelessWidget {
  const FilesCategoryWidget({
    Key? key,
    required this.vectorIcon,
    required this.size,
    required this.title,
    required this.gradientStartColor,
    required this.gradientEndColor,
    required this.fileCategory,
  }) : super(key: key);

  final String vectorIcon;
  final String size;
  final String title;
  final Color gradientStartColor;
  final Color gradientEndColor;
  final FileCategory fileCategory;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () async {
          await DesktopSetupRoutes.nested_push(
              DesktopRoutes.DESKTOP_CATEGORY_FILES,
              arguments: {'fileType': fileCategory});
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              gradientStartColor,
              gradientEndColor,
            ]),
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.symmetric(horizontal: 10),
          height: 40.toWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                vectorIcon,
              ),
              Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 7.toFont),
              ),
              Text(
                "$size item(s)",
                style: TextStyle(color: Colors.white, fontSize: 5.toFont),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
