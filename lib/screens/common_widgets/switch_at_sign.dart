import 'dart:math';
import 'dart:typed_data';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contacts_group_flutter/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

class AtSignBottomSheet extends StatefulWidget {
  final List<String>? atSignList;

  const AtSignBottomSheet({Key? key, this.atSignList}) : super(key: key);

  @override
  State<AtSignBottomSheet> createState() => _AtSignBottomSheetState();
}

class _AtSignBottomSheetState extends State<AtSignBottomSheet> {
  final GlobalKey _one = GlobalKey();
  final GlobalKey _two = GlobalKey();
  BuildContext? myContext;

  BackendService backendService = BackendService.getInstance();
  bool isLoading = false;
  late AtClientPreference atClientPrefernce;

  @override
  Widget build(BuildContext context) {
    backendService
        .getAtClientPreference()
        .then((value) => atClientPrefernce = value);
    Random r = Random();

    return ShowCaseWidget(
      builder: Builder(builder: (context) {
        myContext = context;
        return Stack(
          children: [
            Positioned(
              child: BottomSheet(
                onClosing: () {},
                backgroundColor: Colors.transparent,
                builder: (context) => ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                  child: Container(
                    height: 155.toHeight < 155 ? 155 : 150.toHeight,
                    width: SizeConfig().screenWidth,
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Showcase(
                              key: _one,
                              description:
                                  'You can pair multiple atSigns with this app.',
                              shapeBorder: const CircleBorder(),
                              disableAnimation: true,
                              radius:
                                  const BorderRadius.all(Radius.circular(40)),
                              showArrow: false,
                              overlayPadding: const EdgeInsets.all(5),
                              blurValue: 2,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: Text(TextStrings().sidebarSwitchOut,
                                    style:
                                        CustomTextStyles.blackBold(size: 15)),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                ShowCaseWidget.of(myContext!)
                                    .startShowCase([_one, _two]);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade400,
                                    borderRadius: BorderRadius.circular(50)),
                                margin: const EdgeInsets.all(0),
                                height: 20,
                                width: 20,
                                child: const Icon(
                                  Icons.question_mark,
                                  size: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 100.toHeight < 105 ? 105 : 100.toHeight,
                          width: SizeConfig().screenWidth,
                          color: Colors.white,
                          child: Row(
                            children: [
                              Expanded(
                                  child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: widget.atSignList!.length,
                                itemBuilder: (context, index) {
                                  Uint8List? image = CommonUtilityFunctions()
                                      .getCachedContactImage(
                                          widget.atSignList![index]);
                                  return GestureDetector(
                                    onTap: isLoading
                                        ? () {}
                                        : () async {
                                            return await backendService
                                                .checkToOnboard(
                                                    atSign: widget
                                                        .atSignList![index]);

                                            // Navigator.pop(context);
                                          },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 10, top: 20),
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 40.toFont,
                                            width: 40.toFont,
                                            decoration: BoxDecoration(
                                              color: Color.fromARGB(
                                                  255,
                                                  r.nextInt(255),
                                                  r.nextInt(255),
                                                  r.nextInt(255)),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      50.toWidth),
                                            ),
                                            child: Center(
                                              child: image != null
                                                  ? CustomCircleAvatar(
                                                      byteImage: image,
                                                      nonAsset: true,
                                                    )
                                                  : ContactInitial(
                                                      initials: widget
                                                          .atSignList![index]),
                                            ),
                                          ),
                                          Text(widget.atSignList![index],
                                              style: TextStyle(
                                                fontSize: 15.toFont,
                                                fontWeight: FontWeight.normal,
                                              ))
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              )),
                              const SizedBox(
                                width: 20,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    isLoading = true;
                                    Navigator.pop(context);
                                  });
                                  await backendService.checkToOnboard(
                                    atSign: "",
                                    isSwitchAccount: true,
                                  );

                                  setState(() {
                                    isLoading = false;
                                  });
                                },
                                child: Showcase(
                                  key: _two,
                                  description:
                                      'Use the + icon to either generate a new free atSign or pair an existing one. All paired atSigns will appear here, where you can switch between them.',
                                  shapeBorder: const CircleBorder(),
                                  radius: const BorderRadius.all(
                                      Radius.circular(40)),
                                  showArrow: false,
                                  disableAnimation: true,
                                  overlayPadding: const EdgeInsets.all(5),
                                  blurValue: 2,
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    height: 40,
                                    width: 40,
                                    child: Icon(
                                        Icons.add_circle_outline_outlined,
                                        color: Colors.orange,
                                        size: 25.toFont),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
