import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_outlined_button.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'widgets/gradient_button.dart';
import 'widgets/remove_trusted_contact.dart';
import 'widgets/search_sender.dart';
import 'widgets/sender_grid_item.dart';

class TrustedSenders extends StatelessWidget {
  TrustedSenders({Key? key}) : super(key: key);

  final tempData = [
    {
      'avatar': 'https://randomuser.me/api/portraits/men/85.jpg',
      'name': 'John Doe',
      'atSign': '@john',
    },
    {
      'avatar': 'https://randomuser.me/api/portraits/women/85.jpg',
      'name': 'Jane Doe',
      'atSign': '@jane',
    },
    {
      'avatar': 'https://randomuser.me/api/portraits/women/8.jpg',
      'name': 'Lily Doe',
      'atSign': '@dlily',
    },
    {
      'avatar': 'https://randomuser.me/api/portraits/men/8.jpg',
      'name': 'Micheal Doe',
      'atSign': '@mike',
    },
  ];

  Map<String, List<Map<String, String>>> get groupSendersAlphabetically {
    return groupBy(
        tempData, (Map<String, String> e) => e['name']!.substring(0, 1));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - 118.toHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.25),
            blurRadius: 61,
            offset: Offset(0, -2),
          ),
        ],
        borderRadius: BorderRadius.circular(20.toWidth),
      ),
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: 27.toWidth, vertical: 30.toHeight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 1,
                  width: 45.toWidth,
                  color: Colors.black,
                ),
                CustomOutlinedButton(
                  buttonText: TextStrings().buttonClose,
                  height: 36.toHeight,
                  width: 106.toWidth,
                  radius: 28.toWidth,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            Text(
              TextStrings().trustedSenders,
              style: CustomTextStyles.interBold.copyWith(
                fontSize: 27.toFont,
              ),
            ),
            SizedBox(
              height: 20.toHeight,
            ),
            SearchSender(),
            SizedBox(
              height: 22.toHeight,
            ),
            Expanded(
              child: RawScrollbar(
                thumbColor: Color(0xFFE3E3E3),
                radius: Radius.circular(11.toWidth),
                thickness: 5.toWidth,
                thumbVisibility: true,
                interactive: true,
                child: ListView.builder(
                    itemCount: groupSendersAlphabetically.keys.length,
                    itemBuilder: (context, int index) {
                      final item =
                          groupSendersAlphabetically.keys.toList()[index];
                      final employees = groupSendersAlphabetically[item];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 22.toHeight,
                          ),
                          Row(
                            children: [
                              Text(
                                item,
                                style: CustomTextStyles.interBold,
                              ),
                              SizedBox(
                                width: 19.toWidth,
                              ),
                              Expanded(
                                child: Divider(
                                  color: Color(0xffD9D9D9),
                                  thickness: 1.toWidth,
                                  height: 1.toHeight,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 22.toHeight,
                          ),
                          GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              // childAspectRatio: 0.8,
                              crossAxisSpacing: 13.toWidth,
                              mainAxisSpacing: 10.toHeight,
                              mainAxisExtent: 65.toHeight,
                            ),
                            itemBuilder: (context, int index) {
                              final user = employees![index];
                              return InkWell(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                            contentPadding: EdgeInsets.zero,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      10.toWidth),
                                            ),
                                            content:
                                                RemoveConfirmation(user: user),
                                          ));
                                },
                                child: SenderGridItem(user: user),
                              );
                            },
                            itemCount: employees!.length,
                          ),
                        ],
                      );
                    }),
              ),
            ),
            SizedBox(
              height: 10.toHeight,
            ),
            GradientButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    ImageConstants.plus,
                    cacheHeight: 16,
                    cacheWidth: 20,
                  ),
                  SizedBox(
                    width: 10.toWidth,
                  ),
                  Text(
                    'Add atSign',
                    style: CustomTextStyles.interBold.copyWith(
                      color: Colors.white,
                      fontSize: 15.toFont,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
