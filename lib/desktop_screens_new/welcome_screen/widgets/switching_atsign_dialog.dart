import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SwitchingAtSignDialog extends StatefulWidget {
  final Function(String) onSwitchAtSign;

  const SwitchingAtSignDialog({Key? key, required this.onSwitchAtSign})
      : super(key: key);

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
      height: 256,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          buildAtSignList(),
          const SizedBox(height: 16),
          buildAddNewCard(),
        ],
      ),
    );
  }

  Widget buildAtSignCard({required String atSign}) {
    Uint8List? image = CommonUtilityFunctions().getCachedContactImage(atSign);
    bool currentAtSign = BackendService.getInstance().currentAtSign! == atSign;

    return InkWell(
      onTap: () async {
        await BackendService.getInstance()
            .checkToOnboard(
          atSign: atSign,
        )
            .then((value) {
          widget.onSwitchAtSign(atSign);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        color: currentAtSign ? ColorConstants.orange : Colors.white,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: image != null
                  ? Image.memory(
                      image,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    )
                  : ContactInitial(
                      initials: atSign,
                      size: 48,
                      borderRadius: 10,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  atSign,
                  style: currentAtSign
                      ? CustomTextStyles.whiteW50015
                      : CustomTextStyles.desktopPrimaryW50015,
                ),
              ],
            ))
          ],
        ),
      ),
    );
  }

  Widget buildAtSignList() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(10),
      ),
      child: SizedBox(
        height: 196,
        child: ListView.separated(
          physics: const ClampingScrollPhysics(),
          itemBuilder: (context, index) {
            return buildAtSignCard(atSign: atSignList?[index] ?? '');
          },
          separatorBuilder: (context, index) {
            return const Divider(
              height: 1,
            );
          },
          itemCount: atSignList?.length ?? 0,
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AppVectors.icAddNew,
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 16),
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
