import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';

class DesktopReceivedFileDetails extends StatelessWidget {
  final FileHistory selectedFileData;
  DesktopReceivedFileDetails({this.selectedFileData});

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
          Text('Receiving', style: CustomTextStyles.orangeext15),
          SizedBox(height: 15.toHeight),
          Text('August 12 2020', style: CustomTextStyles.greyText15),
          SizedBox(height: 15.toHeight),
          SizedBox(height: 15.toHeight),
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
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('File name',
                      style: TextStyle(color: Colors.black, fontSize: 16)),
                  SizedBox(height: 5),
                  Text('250 MB', style: CustomTextStyles.greyText16),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30.0),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: ColorConstants.orangeColor,
                      borderRadius: BorderRadius.circular(30)),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Center(
                      child: Text(
                        '30%',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
