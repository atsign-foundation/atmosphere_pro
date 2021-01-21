import 'package:atsign_atmosphere_app/screens/common_widgets/provider_callback.dart';
import 'package:atsign_atmosphere_app/view_models/history_provider.dart';
import 'package:flutter/material.dart';

class SortPopup extends StatefulWidget {
  @override
  _SortPopupState createState() => _SortPopupState();
}

class _SortPopupState extends State<SortPopup> {
  String ratioItem = '';
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          RadioListTile(
              value: 'By Name',
              groupValue: ratioItem,
              onChanged: (s) {
                setState(() {
                  ratioItem = s;
                  providerCallback<HistoryProvider>(context,
                      task: (provider) =>
                          provider.sortByName(provider.receivedPhotos),
                      taskName: (provider) => provider.SORT_LIST,
                      onSuccess: (provider) {
                        print('object');
                      });
                });
              })
        ],
      ),
    );
  }
}
