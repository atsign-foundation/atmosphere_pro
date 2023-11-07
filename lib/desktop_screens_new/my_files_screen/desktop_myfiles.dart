import 'package:at_backupkey_flutter/utils/size_config.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_route_names.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/common_widgets/file_tile.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/groups_screen/widgets/icon_button_widget.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/my_files_screen/utils/file_category.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/my_files_screen/widgets/files_category_widget.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:flutter/material.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return ProviderHandler<MyFilesProvider>(
        functionName: 'fetch_and_sort',
        load: (provider) async {
          await provider.fetchAndSortFiles();
        },
        showError: false,
        successBuilder: (provider) {
          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(40),
              height: SizeConfig().screenHeight,
              color: ColorConstants.background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "My Files",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      isSearchActive
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child: Container(
                                height: 40,
                                width: 308,
                                color: Colors.white,
                                child: TextField(
                                  autofocus: true,
                                  onChanged: (value) {
                                    setState(() {
                                      searchText = value;
                                    });
                                  },
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 28, vertical: 8),
                                    border: InputBorder.none,
                                    hintText: 'Search',
                                    hintStyle: const TextStyle(
                                      color: ColorConstants.grey,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    suffixIcon: InkWell(
                                        onTap: () {
                                          searchText.isEmpty
                                              ? setState(() {
                                                  isSearchActive = false;
                                                })
                                              : setState(() {
                                                  searchText = '';
                                                });
                                        },
                                        child: const Icon(Icons.close)),
                                  ),
                                ),
                              ),
                            )
                          : IconButtonWidget(
                              icon: AppVectors.icSearch,
                              onTap: () {
                                setState(() {
                                  isSearchActive = true;
                                });
                              },
                            ),
                      const SizedBox(
                        width: 10,
                      ),
                      IconButtonWidget(
                        icon: AppVectors.icRefresh,
                        onTap: () async {
                          await provider.fetchAndSortFiles();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Divider(
                    thickness: 1,
                    color: Colors.black,
                  ),
                  const SizedBox(
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Row(
                        children: [
                          Text(
                            "All Files",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.toFont,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            provider.allFiles.length.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.toFont,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 20,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  provider.recentFile.isNotEmpty
                      ? Text(
                          "Recent",
                          style: TextStyle(
                              fontSize: 6.toFont, fontWeight: FontWeight.w600),
                        )
                      : const SizedBox(),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: provider.recentFile.map((file) {
                        if (file.fileName
                                ?.toLowerCase()
                                .contains(searchText.toLowerCase()) ==
                            false) {
                          return const SizedBox();
                        }
                        return FileTile(
                            fileName: file.fileName ?? "",
                            fileExt: file.fileName?.split(".").last ?? "",
                            filePath: file.filePath ?? "",
                            fileSize: file.size ?? 0,
                            fileDate: file.date ?? "",
                            id: file.fileTransferId);
                      }).toList(),
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  Text(
                    "Category",
                    style: TextStyle(
                        fontSize: 6.toFont, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FilesCategoryWidget(
                        vectorIcon: AppVectors.icCategoryImage,
                        size: provider.receivedPhotos.length.toString(),
                        title: "Photos",
                        gradientStartColor: const Color(0xFFF07C50),
                        gradientEndColor: const Color(0xFFD86033),
                        fileCategory: FileCategory.Photos,
                      ),
                      FilesCategoryWidget(
                        vectorIcon: AppVectors.icCategoryPlay,
                        size: provider.receivedVideos.length.toString(),
                        title: "Videos",
                        gradientStartColor: const Color(0xFFF07C50),
                        gradientEndColor: const Color(0xFFD86033),
                        fileCategory: FileCategory.Videos,
                      ),
                      FilesCategoryWidget(
                        vectorIcon: AppVectors.icCategoryFiles,
                        size: provider.receivedDocument.length.toString(),
                        title: "Documents",
                        gradientStartColor: const Color(0xFFED8B44),
                        gradientEndColor: const Color(0xFFFC832C),
                        fileCategory: FileCategory.Documents,
                      ),
                      FilesCategoryWidget(
                        vectorIcon: AppVectors.icCategoryFolder,
                        size: provider.receivedZip.length.toString(),
                        title: "Zips",
                        gradientStartColor: const Color(0xFFED8B44),
                        gradientEndColor: const Color(0xFFFC832C),
                        fileCategory: FileCategory.Zips,
                      ),
                      FilesCategoryWidget(
                        vectorIcon: AppVectors.icCategoryVolume,
                        size: provider.receivedAudio.length.toString(),
                        title: "Audio",
                        gradientStartColor: const Color(0xFFFFB13C),
                        gradientEndColor: const Color(0xFFFFAE35),
                        fileCategory: FileCategory.Audios,
                      ),
                      FilesCategoryWidget(
                        vectorIcon: AppVectors.icCategoryOther,
                        size: provider.receivedUnknown.length.toString(),
                        title: "Others",
                        gradientStartColor: const Color(0xFFFFB13C),
                        gradientEndColor: const Color(0xFFFFAE35),
                        fileCategory: FileCategory.Others,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}
