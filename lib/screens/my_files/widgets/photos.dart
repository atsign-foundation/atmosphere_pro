import 'dart:io';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/edit_bottomsheet.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    return ProviderHandler<HistoryProvider>(
      functionName: 'sort_files',
      showError: false,
      load: (provider) {
        provider.getReceivedHistory();
      },
      successBuilder: (provider) {
        return renderItems(provider);
      },
    );
  }

  Widget renderItems(HistoryProvider provider) {
    return GridView.builder(
        itemCount: provider.receivedPhotos.length,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 80.toHeight,
          mainAxisExtent: 80.toHeight,
          crossAxisSpacing: 20.toWidth,
          mainAxisSpacing: 20.toHeight,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () async {
              await openFilePath(provider.receivedPhotos[index].filePath!);
            },
            onLongPress: () {
              deleteFile(provider.receivedPhotos[index].filePath!);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.toHeight),
              child: Container(
                height: 100.toHeight,
                width: 100.toHeight,
                child: Image.file(
                  File(provider.receivedPhotos[index].filePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext _context, _, __) {
                    return Container(
                      child: Icon(
                        Icons.image,
                        size: 30.toFont,
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        });
  }

  deleteFile(String filePath) async {
    await showModalBottomSheet(
      context: NavService.navKey.currentContext!,
      backgroundColor: Colors.white,
      builder: (context) => EditBottomSheet(onConfirmation: () {
        var file = File(filePath);
        file.deleteSync();

        Provider.of<HistoryProvider>(NavService.navKey.currentContext!,
                listen: false)
            .sortFiles();
        Future.delayed(Duration(seconds: 1), () {
          Provider.of<HistoryProvider>(NavService.navKey.currentContext!,
                  listen: false)
              .populateTabs();
        });
      }),
    );
  }
}
