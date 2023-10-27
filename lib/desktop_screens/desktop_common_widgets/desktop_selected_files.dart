import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/welcome_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';

class DesktopSelectedFiles extends StatefulWidget {
  final ValueChanged<bool> onChange;
  final bool showCancelIcon;

  const DesktopSelectedFiles(this.onChange,
      {Key? key, this.showCancelIcon = true})
      : super(key: key);

  @override
  State<DesktopSelectedFiles> createState() => _DesktopSelectedFilesState();
}

class _DesktopSelectedFilesState extends State<DesktopSelectedFiles> {
  late WelcomeScreenProvider welcomeScreenProvider;

  @override
  void initState() {
    welcomeScreenProvider = Provider.of<WelcomeScreenProvider>(
        NavService.navKey.currentContext!,
        listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(TextStrings().selectedFiles,
            style: CustomTextStyles.desktopPrimaryBold18),
        const SizedBox(
          height: 30,
        ),
        Consumer<FileTransferProvider>(builder: (context, provider, _) {
          if (provider.selectedFiles.isEmpty) {
            return const SizedBox();
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
                  child: SizedBox(
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
                                  welcomeScreenProvider.isSelectionItemChanged =
                                      true;
                                  widget.onChange(true);
                                },
                                child: const Icon(Icons.cancel),
                              ),
                            )
                          : const SizedBox(),
                      IgnorePointer(
                        child: ListTile(
                          onTap: null,
                          title: Text(
                            provider.selectedFiles[index].name,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.toFont,
                              fontWeight: FontWeight.normal,
                            ),
                            maxLines: 1,
                          ),
                          subtitle: Text(
                            double.parse(provider.selectedFiles[index].size
                                        .toString()) <=
                                    1024
                                ? '${provider.selectedFiles[index].size} Kb'
                                    ' . ${provider.selectedFiles[index].extension}'
                                : '${(provider.selectedFiles[index].size / (1024 * 1024)).toStringAsFixed(2)} Mb'
                                    ' . ${provider.selectedFiles[index].extension}',
                            style: TextStyle(
                              color: ColorConstants.fadedText,
                              fontSize: 14.toFont,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          leading: CommonUtilityFunctions().thumbnail(
                              provider.selectedFiles[index].extension
                                  .toString(),
                              provider.selectedFiles[index].path.toString()),
                          trailing: const SizedBox(),
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
    );
  }
}
