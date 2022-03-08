import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/welcome_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DesktopSelectedFiles extends StatefulWidget {
  ValueChanged<bool> onChange;
  final bool showCancelIcon;
  DesktopSelectedFiles(this.onChange, {this.showCancelIcon = true});
  @override
  _DesktopSelectedFilesState createState() => _DesktopSelectedFilesState();
}

class _DesktopSelectedFilesState extends State<DesktopSelectedFiles> {
  FileTransferProvider _filePickerProvider;
  WelcomeScreenProvider welcomeScreenProvider;
  @override
  void initState() {
    welcomeScreenProvider = Provider.of<WelcomeScreenProvider>(
        NavService.navKey.currentContext,
        listen: false);
    _filePickerProvider =
        Provider.of<FileTransferProvider>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
              alignment: Alignment.topLeft,
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
                    child: Container(
                      width: 230,
                      child: Stack(children: [
                        widget.showCancelIcon
                            ? Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    provider.selectedFiles.removeAt(index);
                                    provider.calculateSize();
                                    welcomeScreenProvider
                                        .isSelectionItemChanged = true;
                                    widget.onChange(true);
                                  },
                                  child: Icon(Icons.cancel),
                                ),
                              )
                            : SizedBox(),
                        IgnorePointer(
                          child: ListTile(
                            onTap: null,
                            title: Text(
                              provider.selectedFiles[index]?.name.toString(),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14.toFont,
                              ),
                              maxLines: 1,
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
                            leading: CommonUtilityFunctions().thumbnail(
                                provider.selectedFiles[index].extension
                                    .toString(),
                                provider.selectedFiles[index].path.toString()),
                            trailing: SizedBox(),
                          ),
                        ),
                      ]),
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
}
