import 'package:at_backupkey_flutter/utils/size_config.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_route_names.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/common_widgets/file_tile.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/my_files_screen/utils/file_category.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/my_files_screen/widgets/files_category_widget.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyFilesDesktop extends StatefulWidget {
  const MyFilesDesktop({Key? key}) : super(key: key);

  @override
  State<MyFilesDesktop> createState() => _MyFilesDesktopState();
}

class _MyFilesDesktopState extends State<MyFilesDesktop> {
  String searchText = '';
  bool isSearchActive = false;

  @override
  void initState() {
    super.initState();
    getAllFiles();
  }

  void getAllFiles() async {
    await context.read<MyFilesProvider>().getAllFiles();
  }

  @override
  Widget build(BuildContext context) {
    var files = context.watch<MyFilesProvider>();
    // var recentFiles = context.watch<MyFilesProvider>().recentFile;
    SizeConfig().init(context);

    return Container(
      padding: EdgeInsets.all(40),
      height: SizeConfig().screenHeight,
      color: ColorConstants.fadedBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "My Files",
                style: TextStyle(
                  fontSize: 12.toFont,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              isSearchActive
                  ? Container(
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchText = value;
                          });
                        },
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          hintText: "Search...",
                        ),
                      ),
                    )
                  : SizedBox(),
              SizedBox(
                width: 10,
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    isSearchActive = !isSearchActive;
                    searchText = "";
                  });
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.search,
                    size: 25,
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.refresh,
                  size: 25,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Divider(
            thickness: 1,
            color: Colors.black,
          ),
          SizedBox(
            height: 10,
          ),

          //body
          InkWell(
            onTap: () async {
              await DesktopSetupRoutes.nested_push(
                  DesktopRoutes.DESKTOP_CATEGORY_FILES,
                  arguments: {'fileType': FileCategory.AllFiles});
            },
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Text(
                    "All Files",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.toFont,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    files.allFiles.length.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.toFont,
                    ),
                  ),
                  Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(
            height: 20,
          ),

          files.recentFile.isNotEmpty
              ? Text(
                  "Recent",
                  style: TextStyle(
                      fontSize: 6.toFont, fontWeight: FontWeight.w600),
                )
              : SizedBox(),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: files.recentFile.map((file) {
                if (file.fileName
                        ?.toLowerCase()
                        .contains(searchText.toLowerCase()) ==
                    false) {
                  return SizedBox();
                }
                return FileTile(
                  fileName: file.fileName ?? "",
                  fileExt: file.fileName?.split(".").last ?? "",
                  filePath: file.filePath ?? "",
                  fileSize: file.size ?? 0,
                  fileDate: file.date ?? "",
                );
              }).toList(),
            ),
          ),

          SizedBox(
            height: 30,
          ),

          Text(
            "Category",
            style: TextStyle(fontSize: 6.toFont, fontWeight: FontWeight.w600),
          ),

          SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FilesCategoryWidget(
                vectorIcon: AppVectors.icCategoryImage,
                size: files.receivedPhotos.length.toString(),
                title: "Photos",
                gradientStartColor: Color(0xFFF07C50),
                gradientEndColor: Color(0xFFD86033),
                fileCategory: FileCategory.Photos,
              ),
              FilesCategoryWidget(
                vectorIcon: AppVectors.icCategoryPlay,
                size: files.receivedVideos.length.toString(),
                title: "Videos",
                gradientStartColor: Color(0xFFF07C50),
                gradientEndColor: Color(0xFFD86033),
                fileCategory: FileCategory.Videos,
              ),
              FilesCategoryWidget(
                vectorIcon: AppVectors.icCategoryFiles,
                size: files.allFiles.length.toString(),
                title: "Documents",
                gradientStartColor: Color(0xFFED8B44),
                gradientEndColor: Color(0xFFFC832C),
                fileCategory: FileCategory.Documents,
              ),
              FilesCategoryWidget(
                vectorIcon: AppVectors.icCategoryFolder,
                size: files.receivedZip.length.toString(),
                title: "Zips",
                gradientStartColor: Color(0xFFED8B44),
                gradientEndColor: Color(0xFFFC832C),
                fileCategory: FileCategory.Zips,
              ),
              FilesCategoryWidget(
                vectorIcon: AppVectors.icCategoryVolume,
                size: files.receivedAudio.length.toString(),
                title: "Audio",
                gradientStartColor: Color(0xFFFFB13C),
                gradientEndColor: Color(0xFFFFAE35),
                fileCategory: FileCategory.Audios,
              ),
              FilesCategoryWidget(
                vectorIcon: AppVectors.icCategoryOther,
                size: files.receivedUnknown.length.toString(),
                title: "Others",
                gradientStartColor: Color(0xFFFFB13C),
                gradientEndColor: Color(0xFFFFAE35),
                fileCategory: FileCategory.Others,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
