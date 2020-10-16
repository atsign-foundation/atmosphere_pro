import 'dart:io';
import 'dart:typed_data';
import 'package:atsign_atmosphere_app/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/file_types.dart';
import 'package:atsign_atmosphere_app/utils/images.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:atsign_atmosphere_app/view_models/file_picker_provider.dart';
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

  Uint8List videoThumbnail;
  FilePickerProvider provider;
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
  void initState() {
    provider = FilePickerProvider();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderHandler<FilePickerProvider>(
      functionName: provider.PICK_FILES,
      successBuilder: (provider) => ClipRRect(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.toFont),
            color: ColorConstants.inputFieldColor,
          ),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  provider.selectedFiles.isEmpty
                      ? TextStrings().welcomeFilePlaceholder
                      : TextStrings().welcomeAddFilePlaceholder,
                  style: TextStyle(
                    color: ColorConstants.fadedText,
                    fontSize: 14.toFont,
                  ),
                ),
                subtitle: provider.selectedFiles.isEmpty
                    ? null
                    : Text(
                        double.parse(provider.totalSize.toString()) <= 1024
                            ? '${provider.totalSize} Kb . ${provider.selectedFiles?.length} file(s)'
                            : '${(provider.totalSize / 1024).toStringAsFixed(2)} Mb . ${provider.selectedFiles?.length} file(s)',
                        style: TextStyle(
                          color: ColorConstants.fadedText,
                          fontSize: 10.toFont,
                        ),
                      ),
                trailing: InkWell(
                  onTap: () {
                    provider.pickFiles();
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
                itemCount: provider.selectedFiles.isNotEmpty
                    ? int.parse(provider.selectedFiles?.length?.toString())
                    : 0,
                itemBuilder: (c, index) {
                  if (FileTypes.VIDEO_TYPES
                      .contains(provider.selectedFiles[index].extension)) {
                    videoThumbnailBuilder(provider.selectedFiles[index].path);
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
                        provider.result.files[index].name.toString(),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14.toFont,
                        ),
                      ),
                      subtitle: Text(
                        double.parse(provider.selectedFiles[index].size
                                    .toString()) <=
                                1024
                            ? '${provider.selectedFiles[index].size} Kb' +
                                ' . ${provider.selectedFiles[index].extension}'
                            : '${(provider.selectedFiles[index].size / 1024).toStringAsFixed(2)} Mb' +
                                ' . ${provider.selectedFiles[index].extension}',
                        style: TextStyle(
                          color: ColorConstants.fadedText,
                          fontSize: 14.toFont,
                        ),
                      ),
                      leading: thumbnail(
                          provider.selectedFiles[index].extension.toString(),
                          provider.selectedFiles[index].path.toString()),
                      trailing: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            provider.selectedFiles.removeAt(index);
                            provider.calculateSize();
                          });
                          if (provider.selectedFiles.isEmpty) {
                            widget.onUpdate(false);
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      errorBuilder: (provider) => Center(child: Text('some error occured')),
    );
  }

  Widget thumbnail(String extension, String path) {
    return FileTypes.IMAGE_TYPES.contains(extension)
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
        : FileTypes.VIDEO_TYPES.contains(extension)
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
              );
  }
}
