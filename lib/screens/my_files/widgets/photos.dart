import 'dart:io';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:flutter/material.dart';

import 'downloads_folders.dart';

class Photos extends StatefulWidget {
  @override
  _PhotosState createState() => _PhotosState();
}

class _PhotosState extends State<Photos> {
  HistoryProvider provider = HistoryProvider();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(bottom: 100.toHeight),
        child: ProviderHandler<HistoryProvider>(
          functionName: 'sort_files',
          showError: false,
          load: (provider) {
            provider.getReceivedHistory();
          },
          successBuilder: (provider) {
            return Container(
              margin: EdgeInsets.symmetric(
                  vertical: 10.toHeight, horizontal: 10.toWidth),
              child: Align(
                alignment: Alignment.topLeft,
                child: Wrap(
                    alignment: WrapAlignment.start,
                    runAlignment: WrapAlignment.start,
                    runSpacing: 10.0,
                    spacing: 15.0,
                    children:
                        List.generate(provider.receivedPhotos.length, (index) {
                      return GestureDetector(
                        onTap: () async {
                          await openFilePath(
                              provider.receivedPhotos[index].filePath);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.toHeight),
                          child: Container(
                            height: 100.toHeight,
                            width: 100.toHeight,
                            child: Image.file(
                              File(provider.receivedPhotos[index].filePath),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    })),
              ),
            );
          },
        ),
      ),
    );
  }
}
