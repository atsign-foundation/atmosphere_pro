import 'dart:typed_data';

import 'package:at_backupkey_flutter/utils/size_config.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddContactTile extends StatelessWidget {
  const AddContactTile({
    Key? key,
    required this.title,
    required this.subTitle,
    this.showImage = false,
    this.image,
    this.isSelected = false,
    this.showDivider = false,
    this.hasBackground = false,
    this.isTrusted = false,
    this.index,
  }) : super(key: key);

  final String? title, subTitle;
  final bool showImage;
  final Uint8List? image;
  final bool isSelected;
  final bool showDivider;
  final bool hasBackground;
  final bool isTrusted;
  final int? index;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: hasBackground ? Colors.white : null,
            border: isSelected
                ? Border.all(color: Theme.of(context).primaryColor, width: 2.0)
                : null,
          ),
          clipBehavior: Clip.hardEdge,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ClipRRect(
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(10)),
                child: showImage
                    ? Image.memory(
                        image!,
                        height: 60,
                        width: 60,
                        fit: BoxFit.fill,
                        errorBuilder: (BuildContext context, _, __) {
                          return Icon(
                            Icons.image,
                            size: 30.toFont,
                          );
                        },
                      )
                    : ContactInitial(
                        initials: (title?.isEmpty ?? true) ? '@UG' : title,
                        size: 60,
                        maxSize: (80.0 - 20.0),
                        minSize: 60,
                        borderRadius: 0,
                      ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 10.toHeight),
                    Text(
                      title!,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    (subTitle ?? '').isNotEmpty
                        ? Text(
                            subTitle!,
                            style: CustomTextStyles.desktopPrimaryRegular12,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : const SizedBox(),
                    SizedBox(width: 10.toHeight),
                  ],
                ),
              ),
              if (isTrusted) ...[
                const SizedBox(width: 12),
                Icon(
                  Icons.verified_outlined,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                )
              ],
              const SizedBox(width: 12),
              if (index != null)
                InkWell(
                  onTap: () {
                    context
                        .read<FileTransferProvider>()
                        .removeSelectedContact(index!);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(
                      Icons.clear,
                      size: 14,
                    ),
                  ),
                ),
              const SizedBox(
                width: 20,
              ),
            ],
          ),
        ),
        showDivider
            ? const Divider(
                thickness: 1,
              )
            : const SizedBox(),
      ],
    );
  }
}
