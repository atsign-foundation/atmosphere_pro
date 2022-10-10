import 'dart:developer';

import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:flutter/material.dart';

import '../../../utils/colors.dart';
import '../../../utils/text_strings.dart';
import '../../../utils/text_styles.dart';

enum FileType {
  docx,
  ppt,
  pdf,
  excel,
  txt,
  psd,
  html,
  png,
}

extension FileTypeX on FileType {
  String name() {
    switch (this) {
      case FileType.docx:
        return 'Docx';
      case FileType.ppt:
        return 'PPT';
      case FileType.pdf:
        return 'PDF';
      case FileType.excel:
        return 'Excel';
      case FileType.txt:
        return 'Txt File';
      case FileType.psd:
        return 'PSD';
      case FileType.html:
        return 'HTML';
      case FileType.png:
        return 'PNG';
      default:
        throw Exception('Invalid filetype');
    }
  }

  String getIconPath() {
    // few logos are not yet added so default is word logo for now.
    switch (this) {
      case FileType.docx:
        return ImageConstants.wordLogo;
      case FileType.ppt:
        return ImageConstants.pptLogo;
      case FileType.pdf:
        return ImageConstants.pdfLogo;
      case FileType.excel:
        return ImageConstants.exelLogo;
      case FileType.txt:
        return ImageConstants.txtLogo;
      case FileType.psd:
        return ImageConstants.psdLogo;
      case FileType.html:
        return ImageConstants.htmlLogo;
      case FileType.png:
        return ImageConstants.pngLogo;
      default:
        throw Exception('Invalid filetype');
    }
  }
}

class FileFormatDropDownButton extends StatefulWidget {
  const FileFormatDropDownButton({Key? key}) : super(key: key);

  @override
  State<FileFormatDropDownButton> createState() =>
      _FileFormatDropDownButtonState();
}

class _FileFormatDropDownButtonState extends State<FileFormatDropDownButton>
    with FileTypeOverlayMixin {
  // for all different file types.
  // initially none will be selected as it will default to [All]

  @override
  void dispose() {
    removeOverlay();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    removeOverlay();
    setState(() {});
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TextStrings().deliveryType,
          style: CustomTextStyles.primaryBold14
              .copyWith(color: ColorConstants.myFilesBtn),
        ),
        const SizedBox(height: 5),
        InkWell(
          onTap: toggleOverlay,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15.toWidth),
            height: 48.toHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ColorConstants.light_grey2),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedFileTypes,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CustomTextStyles.primaryBold16.copyWith(
                      color: ColorConstants.light_grey2,
                    ),
                  ),
                ),
                Image.asset(
                  ImageConstants.arrowDown,
                  width: 12.toWidth,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

mixin FileTypeOverlayMixin<T extends StatefulWidget> on State<T> {
  OverlayEntry? _entry;

  bool get isOverlayShown => _entry != null;

  String selectedFileTypes = 'All';

  List<bool> selectedList = List.generate(8, (index) => false);

  void toggleOverlay() => isOverlayShown
      ? removeOverlay()
      : _insert(
          FileTypeCheckboxListOverlay(selectedList: selectedList),
        );

  removeOverlay() {
    _entry?.remove();
    _entry = null;
    if (selectedList.every((element) => !element)) {
      selectedFileTypes = 'All';
    } else {
      selectedFileTypes = '';
      for (int i = 0; i < 8; i++) {
        if (selectedList[i]) {
          selectedFileTypes += FileType.values[i].name() + ', ';
        }
      }
      selectedFileTypes =
          selectedFileTypes.substring(0, selectedFileTypes.length - 2);
    }
    setState(() {});
  }

  Widget _dismissableOverlay(Widget child, double dx, double dy, double width) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: removeOverlay,
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        Positioned(top: dy, left: dx, width: width, child: child),
      ],
    );
  }

  void _insert(Widget child) {
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final dx = offset.dx;
    final dy = offset.dy + renderBox.size.height;
    final w = renderBox.size.width;

    _entry = OverlayEntry(
      builder: (context) => _dismissableOverlay(child, dx, dy, w),
    );

    Overlay.of(context)?.insert(_entry!);
  }
}

class FileTypeCheckboxListOverlay extends StatefulWidget {
  const FileTypeCheckboxListOverlay({
    Key? key,
    required this.selectedList,
  }) : super(key: key);

  final List<bool> selectedList;

  @override
  State<FileTypeCheckboxListOverlay> createState() =>
      _FileTypeCheckboxListOverlayState();
}

class _FileTypeCheckboxListOverlayState
    extends State<FileTypeCheckboxListOverlay> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: Theme(
        data: Theme.of(context).copyWith(
          unselectedWidgetColor: ColorConstants.checkboxFill,
          checkboxTheme: CheckboxThemeData(
            fillColor: MaterialStateProperty.all(ColorConstants.checkboxFill),
            side: MaterialStateBorderSide.resolveWith(
              (states) =>
                  BorderSide(width: 1.0, color: ColorConstants.checkboxBorder),
            ),
            checkColor: MaterialStateProperty.all(Colors.black),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: ColorConstants.checkboxBorder,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(10),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 15,
                offset: Offset(0, 4),
                color: Colors.black.withOpacity(0.25),
              ),
            ],
          ),
          height: 255.toHeight,
          child: ListView.separated(
            itemBuilder: (context, index) {
              if (index == 0) {
                return CheckboxListTile(
                  dense: true,
                  title: Text(
                    'ALL',
                    style: CustomTextStyles.fileTypeDropdown,
                  ),
                  value: widget.selectedList.every((element) => !element),
                  onChanged: (val) {
                    widget.selectedList
                        .setAll(0, List.generate(8, (index) => false));
                    log(widget.selectedList.toString());
                    setState(() {});
                  },
                );
              }
              return CheckboxListTile(
                dense: true,
                title: Text(
                  FileType.values[index - 1].name(),
                  style: CustomTextStyles.fileTypeDropdown,
                ),
                value: widget.selectedList[index - 1],
                onChanged: (val) {
                  widget.selectedList[index - 1] = val!;
                  setState(() {});
                },
              );
            },
            separatorBuilder: (context, index) => Container(
              height: 1,
              color: ColorConstants.textBoxBg,
            ),
            padding: EdgeInsets.zero,
            itemCount: FileType.values.length + 1,
          ),
        ),
      ),
    );
  }
}
