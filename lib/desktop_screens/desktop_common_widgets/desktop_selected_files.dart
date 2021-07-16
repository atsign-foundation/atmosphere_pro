import 'package:atsign_atmosphere_pro/services/common_functions.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:provider/provider.dart';

class DesktopSelectedFiles extends StatefulWidget {
  ValueChanged<bool> onChange;
  DesktopSelectedFiles(this.onChange);
  @override
  _DesktopSelectedFilesState createState() => _DesktopSelectedFilesState();
}

class _DesktopSelectedFilesState extends State<DesktopSelectedFiles> {
  FileTransferProvider _filePickerProvider;
  @override
  void initState() {
    _filePickerProvider =
        Provider.of<FileTransferProvider>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (((SizeConfig().screenWidth - MixedConstants.SIDEBAR_WIDTH) / 2) -
          80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Selected files', style: CustomTextStyles.desktopPrimaryBold18),
          SizedBox(
            height: 30,
          ),
          Consumer<FileTransferProvider>(builder: (context, provider, _) {
            if (provider.selectedFiles.isEmpty) {
              return SizedBox();
            }
            return Align(
              alignment: Alignment.center,
              child: Wrap(
                alignment: WrapAlignment.start,
                runAlignment: WrapAlignment.start,
                runSpacing: 10.0,
                spacing: 20.0,
                children: List.generate(provider.selectedFiles.length, (index) {
                  return Container(
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
                        provider.selectedFiles[index]?.name.toString(),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14.toFont,
                        ),
                      ),
                      subtitle: Text(
                        double.parse(provider.selectedFiles[index].size
                                    .toString()) <=
                                1024
                            ? '${provider.selectedFiles[index].size} Kb' +
                                ' . ${provider.selectedFiles[index].extension}'
                            : '${(provider.selectedFiles[index].size / (1024 * 1024)).toStringAsFixed(2)} Mb' +
                                ' . ${provider.selectedFiles[index].extension}',
                        style: TextStyle(
                          color: ColorConstants.fadedText,
                          fontSize: 14.toFont,
                        ),
                      ),
                      leading: CommonFunctions().thumbnail(
                          provider.selectedFiles[index].extension.toString(),
                          provider.selectedFiles[index].path.toString()),
                      trailing: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            provider.selectedFiles.removeAt(index);
                            provider.calculateSize();
                            widget.onChange(true);
                          });
                        },
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget customFileTile(String size, String type) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        InkWell(
          onTap: () {},
          child: Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      ImageConstants.welcomeDesktop,
                    ),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: Icon(Icons.cancel),
              ),
            ],
          ),
        ),
        SizedBox(width: 10),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'File Name',
                style: CustomTextStyles.desktopPrimaryRegular14,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 5.toHeight),
              type != null
                  ? Text(
                      '$size . $type',
                      style: CustomTextStyles.secondaryRegular12,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : SizedBox(),
            ],
          ),
        )
      ],
    );
  }
}
