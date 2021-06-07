import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_history/widgets/desktop_transfer_overlapping.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';

class DesktopSentFileDetails extends StatelessWidget {
  final FileHistory selectedFileData;
  DesktopSentFileDetails({this.selectedFileData});

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
          Row(
            children: <Widget>[
              getImagePlaceholder(),
              SizedBox(width: 25),
              getImagePlaceholder(),
              Expanded(
                child: SizedBox(),
              ),
              TextButton(
                onPressed: () {},
                style: ButtonStyle(backgroundColor:
                    MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                  return ColorConstants.dark_red;
                }), textStyle: MaterialStateProperty.resolveWith<TextStyle>(
                    (Set<MaterialState> states) {
                  return TextStyle(color: Colors.white);
                })),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 20,
                      ),
                      Text(
                        'Resend',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 15.toHeight),
          Row(
            children: <Widget>[
              Text(
                '2 files . ',
                style: CustomTextStyles.greyText15,
              ),
              Text('250 MB', style: CustomTextStyles.greyText15),
            ],
          ),
          SizedBox(height: 15.toHeight),
          Text('Successfully transfered', style: CustomTextStyles.greyText15),
          SizedBox(height: 15.toHeight),
          Text('August 12 2020', style: CustomTextStyles.greyText15),
          SizedBox(height: 15.toHeight),
          Text('To', style: CustomTextStyles.greyText15),
          SizedBox(height: 15.toHeight),
          selectedFileData != null
              ? DesktopTranferOverlappingContacts(
                  selectedList: selectedFileData.sharedWith
                      .sublist(1, selectedFileData.sharedWith.length),
                  fileHistory: selectedFileData)
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
