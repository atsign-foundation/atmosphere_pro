import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DesktopCoverImagePicker extends StatelessWidget {
  final Uint8List? selectedImage;
  final Function() onPickImage;
  final bool isEdit;
  final Function() onCancel;

  const DesktopCoverImagePicker({
    Key? key,
    this.selectedImage,
    required this.onPickImage,
    required this.isEdit,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (isEdit) {
          onPickImage.call();
        }
      },
      child: selectedImage != null && selectedImage!.isNotEmpty
          ? SizedBox(
              width: 360,
              height: 88,
              child: Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.memory(
                      selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (isEdit)
                    Positioned(
                      top: 12,
                      right: 12,
                      left: 12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: onCancel,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white54.withOpacity(0.5),
                              ),
                              child: SvgPicture.asset(
                                AppVectors.icCancel,
                                width: 16,
                                height: 16,
                                color: Colors.black,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white54.withOpacity(0.5),
                            ),
                            child: SvgPicture.asset(
                              AppVectors.icEdit,
                              width: 16,
                              height: 16,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            )
          : Container(
              padding: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: ColorConstants.pickerBackgroundColor,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Insert Cover Image',
                    style: CustomTextStyles.orangeW50014,
                  ),
                  const SizedBox(height: 8),
                  SvgPicture.asset(
                    AppVectors.icDesktopImage,
                    width: 48,
                    height: 32,
                  ),
                ],
              ),
            ),
    );
  }
}
