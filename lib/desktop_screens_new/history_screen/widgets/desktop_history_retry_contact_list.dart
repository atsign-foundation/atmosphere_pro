import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/history_screen/widgets/desktop_history_retry_contact_item.dart';
import 'package:flutter/material.dart';

class DesktopHistoryRetryContactList extends StatelessWidget {
  final List<ShareStatus> sharedWith;

  const DesktopHistoryRetryContactList({
    required this.sharedWith,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: sharedWith.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 260 / 44),
      itemBuilder: (context, index) {
        return DesktopHistoryRetryContactItem(
          data: sharedWith[index],
        );
      },
    );
  }
}
