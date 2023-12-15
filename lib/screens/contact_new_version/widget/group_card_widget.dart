import 'dart:typed_data';
import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';

class GroupCardWidget extends StatefulWidget {
  final AtGroup group;
  final double size;
  final double borderRadius;
  final Function()? onTap;
  final bool isSelected;

  const GroupCardWidget({
    Key? key,
    required this.group,
    this.size = 44,
    this.borderRadius = 10,
    this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  @override
  State<GroupCardWidget> createState() => _GroupCardWidgetState();
}

class _GroupCardWidgetState extends State<GroupCardWidget> {
  String groupName = 'UG';
  Uint8List? image;

  @override
  void initState() {
    getNameAndImage();
    super.initState();
  }

  getNameAndImage() {
    try {
      if (widget.group.groupPicture != null) {
        image = Uint8List.fromList(widget.group.groupPicture?.cast<int>());
      }

      groupName = widget.group.displayName ?? 'UG';
    } catch (e) {
      groupName = 'UG';
      print('Error in getting image $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          widget.onTap?.call();
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(17, 10, 12, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.isSelected
                  ? ColorConstants.orange
                  : ColorConstants.textBoxBg,
            ),
            color: widget.isSelected
                ? ColorConstants.orange.withOpacity(0.2)
                : Colors.white,
          ),
          child: Row(
            children: <Widget>[
              Container(
                height: widget.size,
                width: widget.size,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: image != null
                    ? CustomCircleAvatar(
                        byteImage: image,
                        nonAsset: true,
                      )
                    : ContactInitial(
                        borderRadius: widget.borderRadius,
                        size: widget.size,
                        initials: groupName,
                      ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      (widget.group.displayName ?? widget.group.groupName) ??
                          '',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      '${widget.group.members?.length ?? 0} Member(s)',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
