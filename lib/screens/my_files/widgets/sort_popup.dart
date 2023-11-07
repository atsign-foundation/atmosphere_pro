import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_callback.dart';
import 'package:atsign_atmosphere_pro/view_models/my_files_provider.dart';
import 'package:flutter/material.dart';

class SortPopup extends StatefulWidget {
  const SortPopup({Key? key}) : super(key: key);

  @override
  State<SortPopup> createState() => _SortPopupState();
}

class _SortPopupState extends State<SortPopup> {
  String? ratioItem = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RadioListTile(
            value: 'By Name',
            groupValue: ratioItem,
            onChanged: (dynamic s) {
              setState(() {
                ratioItem = s;
                providerCallback<MyFilesProvider>(context,
                    task: (provider) =>
                        provider.sortByName(provider.receivedPhotos),
                    taskName: (provider) => provider.SORT_LIST,
                    onSuccess: (provider) {
                      print('object');
                    });
              });
            })
      ],
    );
  }
}
