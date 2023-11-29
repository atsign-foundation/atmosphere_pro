import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/welcome_screen/widgets/atsign_card_widget.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SwitchingAtSignDialog extends StatefulWidget {
  final Function(String) onSwitchAtSign;

  const SwitchingAtSignDialog({required this.onSwitchAtSign});

  @override
  State<SwitchingAtSignDialog> createState() => _SwitchingAtSignDialogState();
}

class _SwitchingAtSignDialogState extends State<SwitchingAtSignDialog> {
  List<String>? atSignList;

  @override
  void initState() {
    getAtSignList();
    super.initState();
  }

  void getAtSignList() async {
    final result = await KeychainUtil.getAtsignList();
    setState(() {
      atSignList = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          buildAtSignList(),
          buildAddNewCard(),
        ],
      ),
    );
  }

  Widget buildAtSignList() {
    return Container(
      constraints: BoxConstraints(maxHeight: 196),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15),
        ),
      ),
      child: ListView.separated(
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return AtSignCardWidget(
            key: UniqueKey(),
            atSign: atSignList?[index] ?? '',
            onSwitchAtSign: widget.onSwitchAtSign,
          );
        },
        separatorBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              thickness: 1,
              height: 0,
              color: ColorConstants.dividerGrayColor,
            ),
          );
        },
        itemCount: atSignList?.length ?? 0,
      ),
    );
  }

  Widget buildAddNewCard() {
    return InkWell(
      onTap: () async {
        await BackendService.getInstance()
            .checkToOnboard(
          isSwitchAccount: true,
        )
            .then((value) {
          widget.onSwitchAtSign(BackendService.getInstance().currentAtSign!);
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AppVectors.icAddNew,
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                'Add New',
                style: CustomTextStyles.orangeW50015,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
