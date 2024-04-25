import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';

class GroupsEditOptionsWidget extends StatelessWidget {
  final Function() onEditName;
  final Function() onCoverImage;
  final Function() onManageMembers;
  final Function() onDelete;

  const GroupsEditOptionsWidget({
    required this.onEditName,
    required this.onCoverImage,
    required this.onManageMembers,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 18,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onEditName,
            child: SizedBox(
              height: 56,
              child: Center(
                child: Text(
                  'Edit Name',
                  style: CustomTextStyles.blackW40017,
                ),
              ),
            ),
          ),
          Divider(
            height: 0,
            thickness: 1,
            color: Colors.black,
          ),
          InkWell(
            onTap: onCoverImage,
            child: SizedBox(
              height: 56,
              child: Center(
                child: Text(
                  'Edit Cover Image',
                  style: CustomTextStyles.blackW40017,
                ),
              ),
            ),
          ),
          Divider(
            height: 0,
            thickness: 1,
            color: Colors.black,
          ),
          InkWell(
            onTap: onManageMembers,
            child: SizedBox(
              height: 56,
              child: Center(
                child: Text(
                  'Manage Members',
                  style: CustomTextStyles.blackW40017,
                ),
              ),
            ),
          ),
          Divider(
            height: 0,
            thickness: 1,
            color: Colors.black,
          ),
          InkWell(
            onTap: onDelete,
            child: SizedBox(
              height: 56,
              child: Center(
                child: Text(
                  'Delete',
                  style: CustomTextStyles.blackW40017,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
