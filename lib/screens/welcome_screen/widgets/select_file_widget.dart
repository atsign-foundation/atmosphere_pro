import 'dart:io';
import 'dart:typed_data';

import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/images.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class SelectFileWidget extends StatefulWidget {
  final Function(bool) onUpdate;
  SelectFileWidget(this.onUpdate);
  @override
  _SelectFileWidgetState createState() => _SelectFileWidgetState();
}

class _SelectFileWidgetState extends State<SelectFileWidget> {
  bool isLoading = false;
  FilePickerResult result;
  PlatformFile file;
  List<PlatformFile> selectedFiles = [];
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
    return ClipRRect(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.toFont),
          color: ColorConstants.inputFieldColor,
        ),
        child: Column(
          children: [
            ListTile(
              title: Text(
                selectedFiles.isEmpty
                    ? TextStrings().welcomeFilePlaceholder
                    : TextStrings().welcomeAddFilePlaceholder,
                style: TextStyle(
                  color: ColorConstants.fadedText,
                  fontSize: 14.toFont,
                ),
              ),
              subtitle: selectedFiles.isEmpty
                  ? null
                  : Text(
                      '144KB . JPG',
                      style: TextStyle(
                        color: ColorConstants.fadedText,
                        fontSize: 10.toFont,
                      ),
                    ),
              trailing: InkWell(
                onTap: () async {
                  selectedFiles = [];
                  if (selectedFiles.isEmpty) widget.onUpdate(true);
                  result = await FilePicker.platform.pickFiles(
                    allowMultiple: true,
                    type: FileType.media,
                  );
                  if (result?.files != null) selectedFiles = [...result?.files];
                  setState(() {});
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15.toHeight),
                  child: Icon(
                    Icons.add_circle,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: selectedFiles.isNotEmpty ? selectedFiles.length : 0,
              itemBuilder: (c, index) {
                if (selectedFiles[index].extension == 'mp4') {
                  videoThumbnailBuilder(selectedFiles[index].path);
                }
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: ColorConstants.dividerColor.withOpacity(0.1),
                        width: 1.toHeight,
                      ),
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      result.files[index].name,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.toFont,
                      ),
                    ),
                    subtitle: Text(
                      selectedFiles[index].size <= 1024
                          ? '${selectedFiles[index].size} Kb' +
                              ' . ${selectedFiles[index].extension}'
                          : '${(selectedFiles[index].size / 1024).round()} Mb' +
                              ' . ${selectedFiles[index].extension}',
                      style: TextStyle(
                        color: ColorConstants.fadedText,
                        fontSize: 14.toFont,
                      ),
                    ),
                    leading: thumbnail(selectedFiles[index].extension,
                        selectedFiles[index].path),
                    trailing: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          selectedFiles.removeAt(index);
                        });
                        if (selectedFiles.isEmpty) widget.onUpdate(false);
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget thumbnail(String extension, String path) {
    return (extension == 'jpg' || extension == 'jpeg' || extension == 'png')
        ? ClipRRect(
            borderRadius: BorderRadius.circular(10.toHeight),
            child: Container(
              height: 50.toHeight,
              width: 50.toWidth,
              child: Image.file(
                File(path),
                fit: BoxFit.cover,
              ),
            ),
          )
        : (extension == 'mp4')
            ? FutureBuilder(
                future: videoThumbnailBuilder(path),
                builder: (context, snapshot) => (snapshot.data == null)
                    ? CircularProgressIndicator()
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(10.toHeight),
                        child: Container(
                          height: 50.toHeight,
                          width: 50.toWidth,
                          child: Image.memory(
                            videoThumbnail,
                            fit: BoxFit.cover,
                            errorBuilder: (context, o, ot) =>
                                CircularProgressIndicator(),
                          ),
                        ),
                      ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(10.toHeight),
                child: Container(
                  height: 50.toHeight,
                  width: 50.toWidth,
                  child: Image.asset(
                    (extension == 'pdf')
                        ? ImageConstants.pdfLogo
                        : (extension == 'mp3' ||
                                extension == 'wmv' ||
                                extension == 'ogg' ||
                                extension == 'aac' ||
                                extension == 'flac')
                            ? ImageConstants.musicLogo
                            : (extension == 'doc' || extension == 'docx')
                                ? ImageConstants.wordLogo
                                : (extension == 'xls' || extension == 'xlsx')
                                    ? ImageConstants.exelLogo
                                    : (extension == 'txt')
                                        ? ImageConstants.txtLogo
                                        : '',
                    fit: BoxFit.cover,
                  ),
                ),
              );
  }
}
