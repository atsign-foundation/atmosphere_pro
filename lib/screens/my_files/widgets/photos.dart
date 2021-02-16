import 'dart:io';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

class Photos extends StatefulWidget {
  @override
  _PhotosState createState() => _PhotosState();
}

class _PhotosState extends State<Photos> {
  HistoryProvider provider = HistoryProvider();
  @override
  void initState() {
    print('in PHOTOS');
    provider.getRecievedHistory();
    provider.sortFiles(provider.receivedHistory);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    provider.receivedPhotos.forEach((element) {});
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderHandler<HistoryProvider>(
      functionName: 'sort_files',
      load: (provider) {
        provider.getRecievedHistory();
      },
      successBuilder: (provider) => Container(
        margin:
            EdgeInsets.symmetric(vertical: 10.toHeight, horizontal: 10.toWidth),
        child: GridView.count(
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 3,
          children: List.generate(provider.receivedPhotos.length, (index) {
            return GestureDetector(
              onTap: () async {
                // preview file
                File test = File(provider.receivedPhotos[index].filePath);
                bool fileExists = await test.exists();
                if (fileExists) {
                  await OpenFile.open(provider.receivedPhotos[index].filePath);
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.toHeight),
                child: Container(
                  height: 50.toHeight,
                  width: 50.toWidth,
                  child: Image.file(
                    File(provider.receivedPhotos[index].filePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
