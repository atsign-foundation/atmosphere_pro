import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/history_retry_contact_item.dart';
import 'package:flutter/material.dart';

class HistoryRetryContactList extends StatelessWidget {
  final List<ShareStatus> sharedWith;

  const HistoryRetryContactList({
    required this.sharedWith,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.fromLTRB(24, 4, 24, 20),
      physics: NeverScrollableScrollPhysics(),
      itemCount: sharedWith.length,
      itemBuilder: (context, index) {
        return HistoryRetryContactItem(
          data: sharedWith[index],
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(height: 12);
      },
    );
  }
}
