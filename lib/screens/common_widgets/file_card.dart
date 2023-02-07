import 'package:at_common_flutter/services/size_config.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class FileCard extends StatefulWidget {
  PlatformFile fileDetail;
  FileCard({Key? key, required this.fileDetail}) : super(key: key);

  @override
  State<FileCard> createState() => _FileCardState();
}

class _FileCardState extends State<FileCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: ColorConstants.sidebarTextUnselected.withOpacity(0.5)),
      ),
      margin: EdgeInsets.fromLTRB(0, 5, 5, 0),
      padding: EdgeInsets.fromLTRB(13, 8, 8, 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100.toWidth,
                child: Text(
                  widget.fileDetail.name,
                  style: TextStyle(color: Colors.black, fontSize: 12.toFont),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(widget.fileDetail.size.toString(),
                  style: TextStyle(fontSize: 15.toFont)),
            ],
          ),
          Icon(Icons.remove_red_eye, size: 15.toFont)
        ],
      ),
    );
  }
}
