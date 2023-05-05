import 'dart:io';

import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/data_models/enums/file_category_type.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/search_widget.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/sliver_grid_delegate.dart';
import 'package:atsign_atmosphere_pro/screens/my_files/image_view_widget.dart';
import 'package:atsign_atmosphere_pro/utils/app_utils.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class FilesDetailScreen extends StatefulWidget {
  final FileType? type;

  const FilesDetailScreen({
    Key? key,
    required this.type,
  }) : super(key: key);

  @override
  State<FilesDetailScreen> createState() => _FilesDetailScreenState();
}

class _FilesDetailScreenState extends State<FilesDetailScreen> {
  bool isGridType = true;
  late TextEditingController searchController;
  late MyFilesProvider provider;

  @override
  void initState() {
    searchController = TextEditingController();
    provider = context.read<MyFilesProvider>();
    super.initState();
    provider.changeTypeSelected(widget.type);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      appBar: AppBar(
        backgroundColor: ColorConstants.background,
        title: Text(
          widget.type != null ? "${widget.type!.text}" : "All Files",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: EdgeInsets.symmetric(
              vertical: 6,
              horizontal: 21,
            ),
            padding: EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 6,
            ),
            decoration: BoxDecoration(
              color: ColorConstants.dividerGrey,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: <Widget>[
                InkWell(
                  onTap: () {
                    setState(() {
                      isGridType = !isGridType;
                    });
                  },
                  child: Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      color: isGridType ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    padding: EdgeInsets.all(8),
                    child: Image.asset(
                      isGridType
                          ? ImageConstants.icGridTypeActivate
                          : ImageConstants.icGridType,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      isGridType = !isGridType;
                    });
                  },
                  child: Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      color: isGridType ? Colors.transparent : Colors.white,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    padding: EdgeInsets.all(8),
                    child: Image.asset(
                      isGridType
                          ? ImageConstants.icListType
                          : ImageConstants.icListTypeActivate,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 28),
              child: SearchWidget(
                controller: searchController,
                borderColor: Colors.white,
                backgroundColor: Colors.white,
                hintText: "Search",
                hintStyle: TextStyle(
                  color: ColorConstants.darkSliver,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                margin: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 75),
                child: Consumer<MyFilesProvider>(
                  builder: (context, provider, _) {
                    final files = provider.displayFiles;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        isGridType
                            ? _buildGridView(files)
                            : _buildListView(files),
                        Padding(
                          padding: EdgeInsets.only(top: 75),
                          child: Text(
                            "${files.length} items",
                            style: TextStyle(
                              fontSize: 13,
                              color: ColorConstants.textGrey,
                            ),
                          ),
                        )
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(List<FilesDetail> files) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 36),
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: files.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
          crossAxisCount: 4,
          crossAxisSpacing: 24,
          mainAxisSpacing: 22,
          height: 104,
        ),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              if (widget.type == FileType.photo) {
                _onTapPhotoItem.call(files[index]);
              } else {
                /// handler
              }
            },
            child: Column(
              children: [
                Container(
                  height: 85,
                  decoration: BoxDecoration(
                    color: ColorConstants.lightSliver,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                Spacer(),
                Text(
                  files[index].fileName ?? "",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 8.toFont,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildListView(List<FilesDetail> files) {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: 32),
      physics: NeverScrollableScrollPhysics(),
      itemCount: files.length,
      separatorBuilder: (context, index) => SizedBox(height: 10),
      itemBuilder: (context, index) {
        final date = DateTime.parse(files[index].date ?? "").toLocal();
        final shortDate = DateFormat('dd/MM/yy').format(date);
        final time = DateFormat('HH:mm').format(date);

        return Slidable(
          actionPane: const SlidableDrawerActionPane(),
          actionExtentRatio: 0.11,
          secondaryActions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: SvgPicture.asset(
                AppVectors.icDownloadFile,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: SvgPicture.asset(
                AppVectors.icSendFile,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: SvgPicture.asset(
                AppVectors.icDeleteFile,
              ),
            ),
          ],
          child: Container(
            key: UniqueKey(),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  height: 49,
                  width: 38,
                  decoration: BoxDecoration(
                    color: ColorConstants.lightSliver,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              "${files[index].fileName}",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          Text(
                            "$shortDate",
                            style: TextStyle(
                              fontSize: 10,
                              color: ColorConstants.oldSliver,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 8,
                            color: Color(0xFFD7D7D7),
                            margin: EdgeInsets.symmetric(
                              horizontal: 3,
                            ),
                          ),
                          Text(
                            "$time",
                            style: TextStyle(
                              fontSize: 10,
                              color: ColorConstants.oldSliver,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 7),
                      Text(
                        "${(files[index].contactName ?? '').split("@")[1]}",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                      SizedBox(height: 1),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              "${files[index].contactName}",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          Text(
                            AppUtils.getFileSizeString(
                              bytes: files[index].size ?? 0,
                              decimals: 2,
                            ),
                            style: TextStyle(
                              fontSize: 10,
                              color: ColorConstants.oldSliver,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _onTapPhotoItem(FilesDetail file) {
    showDialog(
      context: context,
      builder: (context) => ImageViewWidget(
        image: file,
      ),
    );
  }
}