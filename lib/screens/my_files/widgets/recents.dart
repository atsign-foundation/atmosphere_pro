import 'dart:io';
import 'dart:typed_data';

import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/downloads_folders.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/file_types.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class Recents extends StatefulWidget {
  @override
  _RecentsState createState() => _RecentsState();
}

class _RecentsState extends State<Recents> {
  @override
  Widget build(BuildContext context) {
    return ProviderHandler<HistoryProvider>(
      load: (provider) => provider.getRecievedHistory(),
      functionName: 'received_history',
      successBuilder: (provider) => (provider.finalReceivedHistory.isEmpty)
          ? Center(
              child: Text('No files received'),
            )
          : Container(
              margin: EdgeInsets.symmetric(
                  vertical: 10.toHeight, horizontal: 10.toWidth),
              child: GridView.count(
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: 3,
                children: List.generate(provider.finalReceivedHistory.length,
                    (index) {
                  return thumbnail(
                      provider.finalReceivedHistory[index].fileName
                          .split('.')
                          .last,
                      provider.finalReceivedHistory[index].filePath);
                }),
              ),
            ),
    );
  }
}

Widget thumbnail(String extension, String path) {
  return FileTypes.IMAGE_TYPES.contains(extension)
      ? ClipRRect(
          borderRadius: BorderRadius.circular(10.toHeight),
          child: GestureDetector(
            onTap: () async {
              // preview file
              File test = File(path);
              bool fileExists = await test.exists();
              if (fileExists) {
                await OpenFile.open(path);
              }
            },
            child: Container(
              height: 50.toHeight,
              width: 50.toWidth,
              child: Image.file(
                File(path),
                fit: BoxFit.cover,
              ),
            ),
          ),
        )
      : FileTypes.VIDEO_TYPES.contains(extension)
          ? FutureBuilder(
              future: videoThumbnailBuilder(path),
              builder: (context, snapshot) => ClipRRect(
                borderRadius: BorderRadius.circular(10.toHeight),
                child: GestureDetector(
                  onTap: () async {
                    await openDownloadsFolder(context);
                  },
                  child: Container(
                    padding: EdgeInsets.only(left: 10),
                    height: 50.toHeight,
                    width: 50.toWidth,
                    child: (snapshot.data == null)
                        ? Image.asset(
                            ImageConstants.unknownLogo,
                            fit: BoxFit.cover,
                          )
                        : Image.memory(
                            videoThumbnail,
                            fit: BoxFit.cover,
                            errorBuilder: (context, o, ot) =>
                                CircularProgressIndicator(),
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
                    await openDownloadsFolder(context);
                  },
                  child: Container(
                    padding: EdgeInsets.only(left: 10),
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

Uint8List videoThumbnail;

Future videoThumbnailBuilder(String path) async {
  videoThumbnail = await VideoThumbnail.thumbnailData(
    video: path,
    imageFormat: ImageFormat.JPEG,
    maxWidth:
        50, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
    quality: 100,
  );
  return videoThumbnail;
}
