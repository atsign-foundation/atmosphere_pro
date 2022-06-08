import 'dart:io';
import 'dart:typed_data';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/edit_bottomsheet.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'downloads_folders.dart';

class Videos extends StatefulWidget {
  @override
  _VideosState createState() => _VideosState();
}

class _VideosState extends State<Videos> {
  List<Uint8List?>? videoThumbnails;

  Future<List<Uint8List?>?> videoThumbnailBuilder(
      List<FilesDetail> files) async {
    videoThumbnails = [];
    for (var file in files) {
      var thumbnail = await VideoThumbnail.thumbnailData(
        video: file.filePath!,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 50,
        // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
        quality: 100,
      );
      videoThumbnails!.add(thumbnail);
    }
    return videoThumbnails;
  }

  @override
  Widget build(BuildContext context) {
    return ProviderHandler<MyFilesProvider>(
      functionName: 'sort_files',
      showError: false,
      load: (provider) {
        return provider.sortFiles();
      },
      successBuilder: (provider) => Container(
        margin:
            EdgeInsets.symmetric(vertical: 10.toHeight, horizontal: 10.toWidth),
        child: FutureBuilder(
            future: videoThumbnailBuilder(provider.receivedVideos),
            builder: (context, AsyncSnapshot<List<Uint8List?>?> snapshot) {
              // List<Uint8List> videoBytes = Uint8List.fromList(snapshot.data as List<int>) ;
              if (snapshot.data == null) {
                return listVideoWidget(provider, null);
              } else {
                return listVideoWidget(provider, snapshot.data);
              }
            }),
      ),
    );
  }

  Widget listVideoWidget(MyFilesProvider provider, dynamic videos) {
    return ListView.builder(
        itemCount: provider.receivedVideos.length,
        itemBuilder: (context, index) {
          DateTime date = DateTime.parse(provider.receivedVideos[index].date!);
          return InkWell(
            onLongPress: () {
              deleteFile(provider.receivedVideos[index].filePath!,
                  fileTransferId:
                      provider.receivedVideos[index].fileTransferId);
            },
            onTap: () async {
              print(
                  'provider.receivedVideos[index].size====>${provider.receivedVideos[index].size}');
              //      await openDownloadsFolder(context);
              await openFilePath(provider.receivedVideos[index].filePath!);
            },
            child: Card(
              margin: EdgeInsets.only(top: 15.toHeight),
              child: ListTile(
                tileColor: ColorConstants.listBackground,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3)),
                title: Text(provider.receivedVideos[index].fileName!,
                    style: CustomTextStyles.primaryBold14),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10.toHeight),
                  child: Container(
                    padding: EdgeInsets.only(left: 10),
                    height: 50.toHeight,
                    width: 50.toWidth,
                    child: (videos == null ||
                            videos.isEmpty ||
                            videos[index] == null)
                        ? Image.asset(
                            ImageConstants.unknownLogo,
                            fit: BoxFit.cover,
                          )
                        : Image.memory(
                            videos[index],
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
                subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                          double.parse(provider.receivedVideos[index].size
                                      .toString()) <=
                                  1024
                              ? '${provider.receivedVideos[index].size!.toStringAsFixed(2)} ${TextStrings().kb}'
                              : '${(provider.receivedVideos[index].size! / 1024).toStringAsFixed(2)} ${TextStrings().mb}',
                          style: CustomTextStyles.secondaryRegular12),
                      SizedBox(
                        width: 12.toWidth,
                      ),
                      Text('${date.day.toString()}/${date.month}/${date.year}',
                          style: CustomTextStyles.secondaryRegular12),
                    ]),
              ),
            ),
          );
        });
  }

  deleteFile(String filePath, {String? fileTransferId}) async {
    await showModalBottomSheet(
      context: NavService.navKey.currentContext!,
      backgroundColor: Colors.white,
      builder: (context) => EditBottomSheet(onConfirmation: () {
        var file = File(filePath);
        file.deleteSync();
        if (fileTransferId != null) {
          Provider.of<MyFilesProvider>(NavService.navKey.currentContext!,
                  listen: false)
              .removeParticularFile(
                  fileTransferId, filePath.split(Platform.pathSeparator).last);
        }
      }),
    );
  }
}
