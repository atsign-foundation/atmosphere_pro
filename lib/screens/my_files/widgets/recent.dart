import 'dart:io';
import 'dart:typed_data';

import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/downloads_folders.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/file_types.dart';
import 'package:atsign_atmosphere_pro/utils/file_utils.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:fc_native_video_thumbnail/fc_native_video_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class Recent extends StatefulWidget {
  @override
  _RecentState createState() => _RecentState();
}

class _RecentState extends State<Recent> {
  @override
  Widget build(BuildContext context) {
    return ProviderHandler<MyFilesProvider>(
      load: (provider) => provider.getrecentHistoryFiles(),
      functionName: 'recent_history',
      showError: false,
      successBuilder: (provider) {
        return (provider.recentFile.isEmpty)
            ? Center(
                child: Text(TextStrings().noFilesRecieved,
                    style: TextStyle(
                      fontSize: 15.toFont,
                      fontWeight: FontWeight.normal,
                    )),
              )
            : Container(
                margin: EdgeInsets.symmetric(
                    vertical: 10.toHeight, horizontal: 10.toWidth),
                child: GridView.builder(
                    itemCount: provider.recentFile.length,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: SizeConfig().screenWidth / 4,
                      mainAxisExtent: 110.toHeight,
                      crossAxisSpacing: 20.toWidth,
                      mainAxisSpacing: 20.toHeight,
                    ),
                    itemBuilder: (context, index) {
                      return fileCard(provider.recentFile[index].fileName,
                          provider.recentFile[index].filePath,
                          fileTransferId:
                              provider.recentFile[index].fileTransferId);
                    }),
              );
      },
    );
  }
}

Widget fileCard(String? title, String? filePath, {String? fileTransferId}) {
  return InkWell(
    onLongPress: () {
      FileUtils.deleteFile(filePath!, fileTransferId: fileTransferId);
    },
    child: Column(
      children: <Widget>[
        filePath != null
            ? Container(
                width: 80.toHeight,
                height: 80.toHeight,
                child: thumbnail(filePath.split('.').last, filePath))
            : Container(
                width: 80.toHeight,
                height: 80.toHeight,
                child: ClipRect(
                  child: Image.asset(ImageConstants.emptyTrustedSenders,
                      fit: BoxFit.fill),
                ),
              ),
        title != null
            ? Container(
                width: 100.toHeight,
                height: 30.toHeight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Color(0xFF8A8E95),
                      fontSize: 12.toFont,
                      fontWeight: FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            : SizedBox()
      ],
    ),
  );
}

Widget thumbnail(String extension, String path) {
  return FileTypes.IMAGE_TYPES.contains(extension)
      ? ClipRRect(
          child: GestureDetector(
            onTap: () async {
              await openFilePath(path);
            },
            child: Container(
              height: 50.toHeight,
              width: 50.toWidth,
              child: Image.file(
                File(path),
                fit: BoxFit.cover,
                errorBuilder: (BuildContext _context, _, __) {
                  return Container(
                    child: Icon(
                      Icons.image,
                      size: 30.toFont,
                    ),
                  );
                },
              ),
            ),
          ),
        )
      : FileTypes.VIDEO_TYPES.contains(extension)
          ? (Platform.isAndroid || Platform.isIOS)
              ? FutureBuilder(
                  future: videoThumbnailBuilder(path),
                  builder: (context, snapshot) => ClipRRect(
                    borderRadius: BorderRadius.circular(10.toHeight),
                    child: GestureDetector(
                      onTap: () async {
                        // await openDownloadsFolder(context);
                        await openFilePath(path);
                      },
                      child: Container(
                        padding: EdgeInsets.only(left: 10),
                        height: 50.toHeight,
                        width: 50.toWidth,
                        child: (snapshot.data == null || videoThumbnail == null)
                            ? Image.asset(
                                ImageConstants.videoLogo,
                                fit: BoxFit.cover,
                              )
                            : (videoThumbnail != null)
                                ? Image.memory(
                                    videoThumbnail!,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (BuildContext _context, _, __) {
                                      return Container(
                                        child: Icon(
                                          Icons.image,
                                          size: 30.toFont,
                                        ),
                                      );
                                    },
                                  )
                                : SizedBox(),
                      ),
                    ),
                  ),
                )
              : FutureBuilder(
                  future: generateVideoThumbnail(path),
                  builder: (context, snapshot) => ClipRRect(
                    borderRadius: BorderRadius.circular(10.toHeight),
                    child: GestureDetector(
                      onTap: () async {
                        await openFilePath(path);
                      },
                      child: Container(
                        height: 50.toHeight,
                        width: 50.toWidth,
                        child: (File(path + "_thumbnail.jpeg").existsSync() &&
                                File(path).existsSync())
                            ? Image.file(File(path + "_thumbnail.jpeg"),
                                fit: BoxFit.cover)
                            : Image.asset(
                                ImageConstants.videoLogo,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                )
          : Builder(
              builder: (context) => ClipRRect(
                borderRadius: BorderRadius.circular(10.toHeight),
                child: GestureDetector(
                  onTap: () async {
                    await openFilePath(path);
                    //   await openDownloadsFolder(context);
                  },
                  child: Container(
                    // padding: EdgeInsets.only(left: 10),
                    height: 50.toHeight,
                    width: 50.toWidth,
                    child: Image.asset(
                      FileTypes.PDF_TYPES.contains(extension)
                          ? ImageConstants.pdfLogo
                          : FileTypes.AUDIO_TYPES.contains(extension)
                              ? ImageConstants.musicLogo
                              : FileTypes.WORD_TYPES.contains(extension)
                                  ? ImageConstants.wordLogo
                                  : FileTypes.EXEL_TYPES.contains(extension)
                                      ? ImageConstants.exelLogo
                                      : FileTypes.TEXT_TYPES.contains(extension)
                                          ? ImageConstants.txtLogo
                                          : ImageConstants.unknownLogo,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            );
}

Future<bool> isFilePresent(String fileName) async {
  String filePath = BackendService.getInstance().downloadDirectory!.path +
      Platform.pathSeparator +
      fileName;

  File file = File(filePath);
  bool fileExists = await file.exists();
  return fileExists;
}

Uint8List? videoThumbnail;

Future videoThumbnailBuilder(String path) async {
  videoThumbnail = await VideoThumbnail.thumbnailData(
    video: path,
    imageFormat: ImageFormat.JPEG,
    maxWidth: 50,
    // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
    quality: 100,
  );
  return videoThumbnail;
}

Future<dynamic> generateVideoThumbnail(String path) async {
  final plugin = FcNativeVideoThumbnail();

  String thumbnailPath = path;
  String seperator = Platform.pathSeparator;
  var temp = thumbnailPath.split(seperator);
  var fileNamewithExt = temp.removeLast();
  var parentPath = temp.join(seperator);

  var file = File("${parentPath}${seperator}${fileNamewithExt}_thumbnail.jpeg");
  bool isExist = await file.exists();

  if (isExist) {
    return;
  }

  final thumbnailGenerated = await plugin.getVideoThumbnail(
    srcFile: path,
    destFile: "${parentPath}${seperator}${fileNamewithExt}_thumbnail.jpeg",
    width: 300,
    height: 300,
    keepAspectRatio: true,
    format: 'jpeg',
    quality: 90,
  );

  print(thumbnailGenerated);
}
