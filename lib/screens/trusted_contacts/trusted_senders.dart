import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/screens/contacts_screen.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_outlined_button.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart'
    as pro_text_strings;
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:showcaseview/showcaseview.dart';
import 'widgets/gradient_button.dart';
import 'widgets/remove_trusted_contact.dart';
import 'widgets/search_sender.dart';
import 'widgets/sender_grid_item.dart';

class TrustedSenders extends StatefulWidget {
  TrustedSenders({Key? key}) : super(key: key);

  @override
  State<TrustedSenders> createState() => _TrustedSendersState();
}

class _TrustedSendersState extends State<TrustedSenders> {
  Map<String, List<AtContact>> groupSendersAlphabetically(
      List<AtContact> contacts) {
    return groupBy(contacts, (AtContact e) => e.atSign!.substring(1, 2));
  }

  GlobalKey _one = GlobalKey();

  BuildContext? myContext;

  @override
  Widget build(BuildContext context) {
    return ProviderHandler<TrustedContactProvider>(
        functionName: 'get_trusted_contacts',
        load: (provider) async {
          await provider.getTrustedContact();
          await provider.migrateTrustedContact();
        },
        showError: false,
        errorBuilder: (provider) => Scaffold(
              body: Center(
                child: Text(TextStrings().errorOccured),
              ),
            ),
        successBuilder: (provider) {
          return ShowCaseWidget(
            builder: Builder(builder: (context) {
              myContext = context;
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
                  padding: EdgeInsets.symmetric(
                      horizontal: 27.toWidth, vertical: 30.toHeight),
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
                      Expanded(
                        child: provider.trustedContacts.isEmpty
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Container(
                                      padding: EdgeInsets.all(20.0),
                                      decoration: BoxDecoration(
                                          color: Color(0xffFCF9F9),
                                          borderRadius: BorderRadius.circular(
                                              80.toHeight)),
                                      height: 160.toHeight,
                                      width: 160.toHeight,
                                      child: Image.asset(
                                          ImageConstants.emptyTrustedSenders),
                                    ),
                                  ),
                                  SizedBox(height: 20.toHeight),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Showcase(
                                        key: _one,
                                        description:
                                            'When someone on your Trusted Senders list sends you a file while you’re in the app, it will be automatically downloaded. If they send it when you’re not in the app, it will download the next time you open it.',
                                        shapeBorder: CircleBorder(),
                                        disableAnimation: true,
                                        radius: BorderRadius.all(
                                            Radius.circular(40)),
                                        showArrow: false,
                                        overlayPadding: EdgeInsets.all(5),
                                        blurValue: 2,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          child: Text(
                                            pro_text_strings.TextStrings()
                                                .noTrustedSenders,
                                            style:
                                                CustomTextStyles.primaryBold18,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          // ShowCaseWidget.of(myContext!)
                                          //     .startShowCase([_one]);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.grey.shade400,
                                              borderRadius:
                                                  BorderRadius.circular(50)),
                                          margin: EdgeInsets.all(0),
                                          height: 20,
                                          width: 20,
                                          child: Icon(
                                            Icons.question_mark,
                                            size: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10.toHeight),
                                  Text(
                                    pro_text_strings.TextStrings()
                                        .addTrustedSender,
                                    style: CustomTextStyles.secondaryRegular16,
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    height: 25.toHeight,
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  SearchSender(
                                    onSearch: provider.searchTrustedContacts,
                                  ),
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
                                      child: provider.searchedTrustedContacts
                                              .isNotEmpty
                                          ? TrustedContactListGrid(
                                              trustedContact: provider
                                                  .searchedTrustedContacts,
                                            )
                                          : ListView.builder(
                                              itemCount:
                                                  groupSendersAlphabetically(
                                                          provider
                                                              .trustedContacts)
                                                      .keys
                                                      .length,
                                              itemBuilder:
                                                  (context, int index) {
                                                final item =
                                                    groupSendersAlphabetically(
                                                            provider
                                                                .trustedContacts)
                                                        .keys
                                                        .toList()[index];
                                                final trustedContact =
                                                    groupSendersAlphabetically(
                                                            provider
                                                                .trustedContacts)[
                                                        item];
                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      height: 22.toHeight,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          item.toUpperCase(),
                                                          style:
                                                              CustomTextStyles
                                                                  .interBold,
                                                        ),
                                                        SizedBox(
                                                          width: 19.toWidth,
                                                        ),
                                                        Expanded(
                                                          child: Divider(
                                                            color: Color(
                                                                0xffD9D9D9),
                                                            thickness:
                                                                1.toWidth,
                                                            height: 1.toHeight,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 22.toHeight,
                                                    ),
                                                    TrustedContactListGrid(
                                                        trustedContact:
                                                            trustedContact!),
                                                  ],
                                                );
                                              }),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.toHeight,
                                  ),
                                ],
                              ),
                      ),
                      GradientButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ContactsScreen(
                                      asSelectionScreen: true,
                                      selectedContactsHistory: [],
                                      selectedList: (s) async {
                                        for (var element in s) {
                                          await provider
                                              .addTrustedContacts(element!);
                                        }
                                      })));
                        },
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
            }),
          );
        });
  }
}

class TrustedContactListGrid extends StatelessWidget {
  const TrustedContactListGrid({
    Key? key,
    required this.trustedContact,
  }) : super(key: key);

  final List<AtContact> trustedContact;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: trustedContact.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        // childAspectRatio: 0.8,
        crossAxisSpacing: 13.toWidth,
        mainAxisSpacing: 10.toHeight,
        mainAxisExtent: 65.toHeight,
      ),
      itemBuilder: (context, int index) {
        final atContact = trustedContact[index];
        return InkWell(
          onTap: () {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      contentPadding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.toWidth),
                      ),
                      content: RemoveConfirmation(atContact: atContact),
                    ));
          },
          child: SenderGridItem(atContact: atContact),
        );
      },
    );
  }
}
