import 'package:at_contacts_flutter/at_contacts_flutter.dart';
import 'package:atsign_atmosphere_pro/dekstop_services/desktop_image_picker.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FileTransferScreen extends StatefulWidget {
  const FileTransferScreen({Key? key}) : super(key: key);

  @override
  State<FileTransferScreen> createState() => _FileTransferScreenState();
}

class _FileTransferScreenState extends State<FileTransferScreen> {
  late FileTransferProvider _filePickerProvider;

  @override
  void initState() {
    super.initState();
    _filePickerProvider =
        Provider.of<FileTransferProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    var selectedFiles = context.watch<FileTransferProvider>().selectedFiles;
    SizeConfig().init(context);

    return Padding(
      padding: const EdgeInsets.only(left: 40, top: 30, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Transfer File",
            style: TextStyle(
              fontSize: 24.toFont,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          const Divider(thickness: 1, color: Colors.black,),
          SizedBox(height: 20),
          Text(
            "SELECT FILES",
            style: TextStyle(
              color: ColorConstants.gray,
              fontSize: 15.toFont,
              fontWeight: FontWeight.bold,
            ),
          ),
          FractionallySizedBox(
            widthFactor: 0.7,
            child: Row(
              children: selectedFiles.map((file) {
                return Padding(
                  padding: EdgeInsets.only(right: 20, top: 20, bottom: 20),
                  child: Column(
                    children: [
                      Container(
                        width: 300,
                        height: 100,
                        child: Icon(Icons.image),
                        decoration: BoxDecoration(
                          color: ColorConstants.MILD_GREY,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                      ),
                      Container(
                        width: 300,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  file.name,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 16.toFont,
                                  ),
                                ),
                                SizedBox(height: 10.toHeight),
                                Text(
                                  DateTime.now().toString(),
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 12.toFont,
                                    color: ColorConstants.gray,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              file.size.toString(),
                              style: TextStyle(
                                fontSize: 12.toFont,
                                color: ColorConstants.gray,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(
            height: 10.toHeight,
          ),
          InkWell(
            onTap: () async {
              var files = await desktopImagePicker();
              if (files != null) {
                _filePickerProvider.selectedFiles.add(files[0]);
                _filePickerProvider.notify();
              }
              print("selected files: $files");
            },
            child: selectedFiles.isEmpty
                ? DottedBorder(
                    color: Theme.of(context).primaryColor,
                    padding: EdgeInsets.zero,
                    dashPattern: [6, 4],
                    strokeWidth: 1.5,
                    child: Container(
                      decoration: BoxDecoration(
                          color: ColorConstants.orangeColorDim,
                          borderRadius: BorderRadius.circular(5)),
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: FractionallySizedBox(
                        widthFactor: 0.7,
                        child: Column(
                          children: [
                            Image.asset(
                              ImageConstants.uploadFile,
                              height: 60.toHeight,
                            ),
                            SizedBox(
                              height: 10.toHeight,
                            ),
                            Text(
                              "Upload your File(s)",
                              style: TextStyle(
                                fontSize: 20.toFont,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 10.toHeight,
                            ),
                            Text(
                              "Drag or drop files or Browse",
                              style: TextStyle(
                                color: ColorConstants.gray,
                                fontSize: 15.toFont,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : FractionallySizedBox(
                    widthFactor: 0.7,
                    child: Container(
                      decoration: BoxDecoration(
                        color: ColorConstants.yellowDim,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Add Files (Drag or Drop Files)",
                            style: TextStyle(
                              color: ColorConstants.yellow,
                              fontSize: 16.toFont,
                            ),
                          ),
                          Icon(
                            Icons.add_circle_outline,
                            color: ColorConstants.yellow,
                            size: 25,
                          )
                        ],
                      ),
                    ),
                  ),
          ),
          SizedBox(
            height: 30.toHeight,
          ),
          Text(
            "SELECT CONTACTS",
            style: TextStyle(
              color: ColorConstants.gray,
              fontSize: 15.toFont,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 10.toHeight,
          ),
          FractionallySizedBox(
            widthFactor: 0.7,
            child: Container(
              decoration: BoxDecoration(
                color: ColorConstants.orangeColorDim,
                borderRadius: BorderRadius.circular(5.0),
              ),
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Add atsigns",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 16.toFont,
                    ),
                  ),
                  Icon(
                    Icons.add_circle_outline,
                    color: Theme.of(context).primaryColor,
                    size: 25,
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20.toHeight,
          ),
          FractionallySizedBox(
            widthFactor: 0.7,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Send Message (Optional)",
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 20)),
                maxLines: 5,
              ),
            ),
          ),
          SizedBox(
            height: 30.toHeight,
          ),
          InkWell(
            onTap: () {},
            child: FractionallySizedBox(
              widthFactor: 0.7,
              child: Container(
                decoration: BoxDecoration(
                  color: selectedFiles.isNotEmpty
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Text(
                  "Transfer Now",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
