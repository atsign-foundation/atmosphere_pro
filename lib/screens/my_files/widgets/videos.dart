import 'dart:typed_data';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'downloads_folders.dart';

class Videos extends StatefulWidget {
  @override
  _VideosState createState() => _VideosState();
}

class _VideosState extends State<Videos> {
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

  @override
  Widget build(BuildContext context) {
    return ProviderHandler<HistoryProvider>(
      functionName: 'sort_files',
      load: (provider) {
        return provider.sortFiles(provider.receivedHistoryLogs);
      },
      successBuilder: (provider) => Container(
        margin:
            EdgeInsets.symmetric(vertical: 10.toHeight, horizontal: 10.toWidth),
        child: ListView.builder(
            itemCount: provider.receivedVideos.length,
            itemBuilder: (context, index) {
              DateTime date =
                  DateTime.parse(provider.receivedVideos[index].date);
              return InkWell(
                onTap: () async {
                  print(
                      'provider.receivedVideos[index].size====>${provider.receivedVideos[index].size}');
                  await openDownloadsFolder(context);
                },
                child: Card(
                  margin: EdgeInsets.only(top: 15.toHeight),
                  child: ListTile(
                    tileColor: ColorConstants.listBackground,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3)),
                    title: Text(provider.receivedVideos[index].fileName,
                        style: CustomTextStyles.primaryBold14),
                    leading: FutureBuilder(
                      future: videoThumbnailBuilder(
                          provider.receivedVideos[index].filePath),
                      builder: (context, snapshot) => ClipRRect(
                        borderRadius: BorderRadius.circular(10.toHeight),
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
                    subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                              double.parse(provider.receivedVideos[index].size
                                          .toString()) <=
                                      1024
                                  ? '${(provider.receivedVideos[index].size).toStringAsFixed(2)}'+ TextStrings().kb
                                  : '${(provider.receivedVideos[index].size / 1024).toStringAsFixed(2)}'+ TextStrings().mb,
                              style: CustomTextStyles.secondaryRegular12),
                          SizedBox(
                            width: 12.toWidth,
                          ),
                          Text(
                              '${date.day.toString()}/${date.month}/${date.year}',
                              style: CustomTextStyles.secondaryRegular12),
                        ]),
                  ),
                ),
              );
            }),
      ),
    );
  }
}
