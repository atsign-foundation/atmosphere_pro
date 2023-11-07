import 'package:at_backupkey_flutter/utils/size_config.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/recents.dart';
import 'package:atsign_atmosphere_pro/utils/app_utils.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class AddFileTile extends StatelessWidget {
  const AddFileTile({
    Key? key,
    required this.file,
  }) : super(key: key);

  final PlatformFile file;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20, top: 20, bottom: 20),
      child: Column(
        children: [
          Container(
            width: 300,
            height: 100,
            decoration: const BoxDecoration(
              color: ColorConstants.MILD_GREY,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: thumbnail(file.extension ?? "", file.path ?? ""),
          ),
          Container(
            width: 300,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.name,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 16,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 10.toHeight),
                      Text(
                        DateTime.now().toString(),
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 12,
                          color: ColorConstants.gray,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  AppUtils.getFileSizeString(bytes: file.size.toDouble()),
                  style: const TextStyle(
                    fontSize: 12,
                    color: ColorConstants.gray,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
