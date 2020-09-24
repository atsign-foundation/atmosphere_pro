import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/images.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:flutter/material.dart';

class SelectFileWidget extends StatefulWidget {
  final Function(bool) onUpdate;
  SelectFileWidget(this.onUpdate);
  @override
  _SelectFileWidgetState createState() => _SelectFileWidgetState();
}

class _SelectFileWidgetState extends State<SelectFileWidget> {
  int selectedFiles;

  @override
  void initState() {
    selectedFiles = 0;
    super.initState();
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
                selectedFiles == 0
                    ? TextStrings().welcomeFilePlaceholder
                    : TextStrings().welcomeAddFilePlaceholder,
                style: TextStyle(
                  color: ColorConstants.fadedText,
                  fontSize: 14.toFont,
                ),
              ),
              subtitle: selectedFiles == 0
                  ? null
                  : Text(
                      '144KB . JPG',
                      style: TextStyle(
                        color: ColorConstants.fadedText,
                        fontSize: 10.toFont,
                      ),
                    ),
              trailing: InkWell(
                onTap: () {
                  if (selectedFiles == 0) widget.onUpdate(true);
                  setState(() {
                    selectedFiles++;
                  });
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
              itemCount: selectedFiles,
              itemBuilder: (c, index) => Container(
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
                    'File Name $index',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.toFont,
                    ),
                  ),
                  subtitle: Text(
                    '144KB . JPG',
                    style: TextStyle(
                      color: ColorConstants.fadedText,
                      fontSize: 14.toFont,
                    ),
                  ),
                  leading: Container(
                    height: 50.toHeight,
                    width: 50.toHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.toHeight),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage(
                          ImageConstants.test,
                        ),
                      ),
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        selectedFiles--;
                      });
                      if (selectedFiles == 0) widget.onUpdate(false);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
