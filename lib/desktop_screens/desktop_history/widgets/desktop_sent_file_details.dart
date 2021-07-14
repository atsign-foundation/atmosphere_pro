import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_history/widgets/desktop_transfer_overlapping.dart';
import 'package:atsign_atmosphere_pro/services/common_functions.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';

class DesktopSentFileDetails extends StatefulWidget {
  final FileHistory selectedFileData;
  UniqueKey key;
  DesktopSentFileDetails({this.key, this.selectedFileData});

  @override
  _DesktopSentFileDetailsState createState() => _DesktopSentFileDetailsState();
}

class _DesktopSentFileDetailsState extends State<DesktopSentFileDetails> {
  int fileCount = 0;
  int fileSize = 0;

  @override
  void initState() {
    fileCount = widget.selectedFileData.fileDetails.files.length;

    widget.selectedFileData.fileDetails.files.forEach((element) {
      fileSize += element.size;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorConstants.selago,
      height: SizeConfig().screenHeight,
      width: SizeConfig().screenWidth * 0.45,
      padding: EdgeInsets.only(left: 15, right: 15, top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          SizedBox(height: 15.toHeight),
          Column(
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Wrap(
                  alignment: WrapAlignment.start,
                  runAlignment: WrapAlignment.start,
                  runSpacing: 10.0,
                  spacing: 20.0,
                  children: List.generate(
                      widget.selectedFileData.fileDetails.files.length,
                      (index) {
                    return Container(
                      child: ListTile(
                        title: Text(
                          widget.selectedFileData.fileDetails.files[index]?.name
                              .toString(),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.toFont,
                          ),
                        ),
                        subtitle: Text(
                          double.parse(widget.selectedFileData.fileDetails
                                      .files[index].size
                                      .toString()) <=
                                  1024
                              ? '${widget.selectedFileData.fileDetails.files[index].size} Kb' +
                                  ' . ${widget.selectedFileData.fileDetails.files[index].name.split('.').last}'
                              : '${(widget.selectedFileData.fileDetails.files[index].size / (1024 * 1024)).toStringAsFixed(2)} Mb' +
                                  ' . ${widget.selectedFileData.fileDetails.files[index].name.split('.').last}',
                          style: TextStyle(
                            color: ColorConstants.fadedText,
                            fontSize: 14.toFont,
                          ),
                        ),
                        leading: CommonFunctions().thumbnail(
                            widget
                                .selectedFileData.fileDetails.files[index].name
                                .split('.')
                                .last
                                .toString(),
                            MixedConstants.SENT_FILE_DIRECTORY +
                                widget.selectedFileData.fileDetails.files[index]
                                    .name),
                        trailing: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {},
                        ),
                      ),
                    );
                  }),
                ),
              )
            ],
          ),
          SizedBox(height: 15.toHeight),
          Row(
            children: <Widget>[
              Text(
                '${fileCount.toString()} files . ',
                style: CustomTextStyles.greyText15,
              ),
              fileSize > 1024
                  ? Text('${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB',
                      style: CustomTextStyles.greyText15)
                  : Text('${fileSize.toStringAsFixed(2)} KB',
                      style: CustomTextStyles.greyText15),
            ],
          ),
          SizedBox(height: 15.toHeight),
          Text('Successfully transfered', style: CustomTextStyles.greyText15),
          SizedBox(height: 15.toHeight),
          Text('${widget.selectedFileData.fileDetails.date.toLocal()}',
              style: CustomTextStyles.greyText15),
          SizedBox(height: 15.toHeight),
          Text('To', style: CustomTextStyles.greyText15),
          SizedBox(height: 15.toHeight),
          widget.selectedFileData != null
              ? DesktopTranferOverlappingContacts(
                  selectedList: widget.selectedFileData.sharedWith,
                  fileHistory: widget.selectedFileData)
              : SizedBox()
        ],
      ),
    );
  }

  getImagePlaceholder({String filepath, String fileName}) {
    return Row(
      children: [
        SizedBox(
          height: 60,
          width: 60,
          child: Image.asset(ImageConstants.pdfLogo),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('File name',
                  style: TextStyle(color: Colors.black, fontSize: 16)),
              SizedBox(height: 5),
              Text('250 MB', style: CustomTextStyles.greyText16),
            ],
          ),
        )
      ],
    );
  }
}
