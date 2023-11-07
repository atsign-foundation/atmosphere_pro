import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/received_file_list_tile.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WelcomeScreenReceivedFiles extends StatefulWidget {
  const WelcomeScreenReceivedFiles({Key? key}) : super(key: key);

  @override
  State<WelcomeScreenReceivedFiles> createState() =>
      _WelcomeScreenReceivedFilesState();
}

class _WelcomeScreenReceivedFilesState
    extends State<WelcomeScreenReceivedFiles> {
  late HistoryProvider historyProvider;

  @override
  Widget build(BuildContext context) {
    historyProvider = Provider.of<HistoryProvider>(context);
    return ProviderHandler<HistoryProvider>(
      functionName: historyProvider.RECEIVED_HISTORY,
      load: (provider) {},
      showError: false,
      successBuilder: (provider) => (provider.receivedHistoryLogs.isEmpty)
          ? Center(
              child: Text(
                TextStrings().noFilesRecieved,
                style: TextStyle(
                  fontSize: 15.toFont,
                  fontWeight: FontWeight.normal,
                ),
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.only(bottom: 170.toHeight),
              physics: const AlwaysScrollableScrollPhysics(),
              separatorBuilder: (context, index) => Divider(indent: 16.toWidth),
              itemCount: provider.receivedHistoryLogs.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: ReceivedFilesListTile(
                  key: Key(provider.receivedHistoryLogs[index].key),
                  receivedHistory: provider.receivedHistoryLogs[index],
                  isWidgetOpen:
                      provider.receivedHistoryLogs[index].isWidgetOpen,
                ),
              ),
            ),
      errorBuilder: (provider) => Center(
        child: Text(TextStrings().errorOccured),
      ),
    );
  }
}
