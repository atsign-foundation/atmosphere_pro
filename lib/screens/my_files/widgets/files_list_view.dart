// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';

import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_divider.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/widgets/file_format_dropdown_button.dart';

class FilesListView extends StatefulWidget {
  const FilesListView({Key? key}) : super(key: key);

  @override
  State<FilesListView> createState() => _FilesListViewState();
}

class _FilesListViewState extends State<FilesListView> {
  // List<FilesDetail> files;
  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      radius: Radius.circular(11),
      thickness: 5,
      trackVisibility: true,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              primary: false,
              titleSpacing: 0,
              title: CustomDivider(initialLetter: 'A', padRight: true),
            ),
          ];
        },
        body: ListView.builder(
          itemCount: 1, //this should be number of files / 2
          padding: EdgeInsets.symmetric(horizontal: 18.toWidth),

          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8.toHeight),
              child: Row(
                children: [
                  Expanded(
                    child: FileListTile(
                      type: FileType.ppt,
                      title: 'Qna.docx',
                      fileSize: '2 Mb',
                    ),
                  ),
                  SizedBox(width: 8.toWidth),
                  // if(index*2 + 1 < numberOfFiles)
                  Expanded(
                    child: FileListTile(
                      type: FileType.docx,
                      title: 'Qna.docx',
                      fileSize: '2 Mb',
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class FileListTile extends StatelessWidget {
  const FileListTile({
    Key? key,
    required this.type,
    required this.title,
    required this.fileSize,
  }) : super(key: key);

  final FileType type;
  final String title;
  final String fileSize;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        // TODO: Interact with file
      },
      contentPadding: EdgeInsets.symmetric(horizontal: 10.toWidth),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: ColorConstants.textBoxBg)),
      leading: Image.asset(
        type.getIconPath(),
        height: 24.toHeight,
      ),
      minLeadingWidth: 0,
      dense: true,
      horizontalTitleGap: 9.toWidth,
      visualDensity: VisualDensity.compact,
      title: Text(
        title,
        style: CustomTextStyles.fileTitle,
      ),
      subtitle: Text(
        fileSize,
        style: CustomTextStyles.fileSubtitle,
      ),
    );
  }
}
