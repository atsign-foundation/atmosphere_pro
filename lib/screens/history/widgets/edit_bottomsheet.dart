import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/confirmation_dialog.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:at_common_flutter/services/size_config.dart';

class EditBottomSheet extends StatefulWidget {
  final FileHistory? fileHistory;
  EditBottomSheet({required this.fileHistory});
  @override
  _EditBottomSheetState createState() => _EditBottomSheetState();
}

class _EditBottomSheetState extends State<EditBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(10)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          InkWell(
            onTap: deleteSentItem,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  TextStrings.delete,
                  style: CustomTextStyles.red20,
                ),
                Icon(Icons.delete,
                    color: ColorConstants.redAlert, size: 20.toFont)
              ],
            ),
          ),
        ],
      ),
    );
  }

  deleteSentItem() async {
    await showDialog(
        context: NavService.navKey.currentContext!,
        builder: (context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.toWidth),
              ),
              content: ConfirmationDialog(TextStrings.deleteFileConfirmationMsg,
                  () async {
                await Provider.of<HistoryProvider>(context, listen: false)
                    .deleteSentItem(widget.fileHistory!.fileDetails!.key);
              }));
        });

    Navigator.of(context).pop();
  }
}
