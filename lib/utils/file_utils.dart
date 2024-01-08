import 'dart:io';

import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/downloads_folders.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/services/snackbar_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/file_types.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/welcome_screen_view_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' show basename;

class FileUtils {
  static Future<void> deleteFile(
    String filePath, {
    String? fileTransferId,
    Function()? onComplete,
  }) async {
    await CommonUtilityFunctions().showConfirmationDialog(
      () async {
        if (File(filePath).existsSync()) File(filePath).deleteSync();
        if (fileTransferId != null) {
          await Provider.of<MyFilesProvider>(NavService.navKey.currentContext!,
                  listen: false)
              .removeParticularFile(
                  fileTransferId, filePath.split(Platform.pathSeparator).last);

          await Provider.of<MyFilesProvider>(NavService.navKey.currentContext!,
                  listen: false)
              .getAllFiles();
        }
        onComplete?.call();
        SnackbarService().showSnackbar(
          NavService.navKey.currentContext!,
          "Successfully deleted the file(s)",
          bgColor: ColorConstants.successColor,
        );
      },
      'Are you sure you want to delete the file(s)?',
    );
  }

  static Future<void> moveToSendFile(String filePath) async {
    final file = File(filePath);
    final length = await file.length();
    FileTransferProvider.appClosedSharedFiles.add(
      PlatformFile(
          name: basename(file.path),
          path: file.path,
          size: length.round(),
          bytes: await file.readAsBytes()),
    );
    Provider.of<FileTransferProvider>(NavService.navKey.currentContext!,
            listen: false)
        .setFiles();
    Provider.of<WelcomeScreenProvider>(NavService.navKey.currentContext!,
            listen: false)
        .changeBottomNavigationIndex(0);
  }

  static Future<void> openFile({
    required String path,
    required String extension,
    required Function() onDelete,
    required FilesDetail fileDetail,
  }) async {
    GroupService().allContacts;
    String nickname = "";
    final date = DateTime.parse(fileDetail.date ?? "").toLocal();
    final shortDate = DateFormat('dd/MM/yy').format(date);
    final time = DateFormat('HH:mm').format(date);

    for (var contact in GroupService().allContacts) {
      if (contact?.contact?.atSign == fileDetail.contactName) {
        nickname = contact?.contact?.tags?["nickname"] ?? "";
        break;
      }
    }
    if (FileTypes.IMAGE_TYPES.contains(extension)) {
      await showDialog(
        context: NavService.navKey.currentContext!,
        builder: (_) => Material(
          type: MaterialType.transparency,
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(NavService.navKey.currentContext!);
                    },
                    child: Icon(
                      Icons.clear,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: Container(
                  // height: double.infinity,
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 33),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: FileImage(
                        File(path),
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: SvgPicture.asset(
                      AppVectors.icDownloadFile,
                      height: 50,
                      width: 50,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: GestureDetector(
                      onTap: () async {
                        Navigator.pop(NavService.navKey.currentContext!);
                        Navigator.pop(NavService.navKey.currentContext!);
                        await FileUtils.moveToSendFile(path);
                      },
                      child: SvgPicture.asset(
                        AppVectors.icSendFile,
                        height: 50,
                        width: 50,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: GestureDetector(
                      onTap: () async {
                        await onDelete();
                      },
                      child: SvgPicture.asset(
                        AppVectors.icDeleteFile,
                        height: 50,
                        width: 50,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 40,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.symmetric(horizontal: 25),
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              fileDetail.fileName ?? "",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                "$shortDate",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: ColorConstants.oldSliver,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 8,
                                color: Color(0xFFD7D7D7),
                                margin: EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                              ),
                              Text(
                                "$time",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: ColorConstants.oldSliver,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Text(
                        double.parse(fileDetail.size.toString()) <= 1024
                            ? '${fileDetail.size} ' + TextStrings().kb
                            : '${(fileDetail.size! / (1024 * 1024)).toStringAsFixed(2)} ' +
                                TextStrings().mb,
                        style: TextStyle(
                          color: ColorConstants.grey,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 10),
                      nickname.isNotEmpty
                          ? Text(
                              nickname,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            )
                          : SizedBox(),
                      SizedBox(height: 5),
                      Text(
                        fileDetail.contactName ?? "",
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 10),
                      // fileDetail.message.isNotNull
                      //     ?
                      Text(
                        "Message",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      // : SizedBox(),
                      SizedBox(height: 5),
                      Text(
                        fileDetail.message ?? "",
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      await openFilePath(path);
    }
  }
}
