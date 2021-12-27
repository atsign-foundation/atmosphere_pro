import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

class FilePickerScreen extends StatefulWidget {
  @override
  _FilePickerScreenState createState() => _FilePickerScreenState();
}

class _FilePickerScreenState extends State<FilePickerScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              height: 40.toHeight,
              margin: EdgeInsets.only(top: 5.toHeight),
              child: Center(
                child: GestureDetector(
                  child: Text(
                    TextStrings().buttonClose,
                    style: CustomTextStyles.blueRegular18,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Select a File',
                  style: CustomTextStyles.primaryBold18,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Container(
                margin: EdgeInsets.only(right: 15.toWidth),
                width: 74.toWidth,
                height: 35.toHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30.toFont),
                  child: Container(
                    color: Color(0xffF05E3E),
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.toWidth, vertical: 5.toHeight),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: TextStyle(letterSpacing: 0.1),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 400,
              child: GridView.builder(
                itemCount: 10,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5.0,
                  mainAxisSpacing: 5.0,
                ),
                itemBuilder: (context, index) => Stack(
                  children: [
                    Container(
                      height: 150,
                      width: 150,
                      // child: Image.file(File(result.files[index].path)),
                      color: Colors.red,
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        height: 10,
                        width: 10,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
