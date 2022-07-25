import 'dart:typed_data';

import 'package:at_contacts_flutter/screens/contacts_screen.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart'
    as pro_text_strings;
import 'package:atsign_atmosphere_pro/utils/colors.dart' as pro_color_constants;
import 'package:atsign_atmosphere_pro/screens/common_widgets/app_bar.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_button.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_pro/screens/group_contacts_screen/widgets/group_contact_list_tile.dart';
import 'package:atsign_atmosphere_pro/screens/trusted_contacts/widgets/remove_trusted_contact_dialog.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../services/navigation_service.dart';

class TrustedContacts extends StatefulWidget {
  @override
  _TrustedContactsState createState() => _TrustedContactsState();
}

class _TrustedContactsState extends State<TrustedContacts> {
  TrustedContactProvider? trustedContact;
  bool toggleList = false;
  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var trustedContact =
          Provider.of<TrustedContactProvider>(context, listen: false);
      trustedContact.migrateTrustedContact();
    });

    super.didChangeDependencies();
  }

  GlobalKey _one = GlobalKey();
  GlobalKey _two = GlobalKey();
  BuildContext? myContext;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: ProviderHandler<TrustedContactProvider>(
            functionName: 'get_trusted_contacts',
            load: (provider) async => await provider.getTrustedContact(),
            showError: false,
            errorBuilder: (provider) => Scaffold(
                  body: Center(
                    child: Text(TextStrings().errorOccured),
                  ),
                ),
            successBuilder: (provider) {
              return ShowCaseWidget(builder: Builder(builder: (context) {
                myContext = context;
                return Scaffold(
                  appBar: CustomAppBar(
                    showBackButton: true,
                    showTitle: true,
                    title: pro_text_strings.TextStrings().trustedSenders,
                    showTrailingButton:
                        provider.fetchedTrustedContact.isEmpty ? false : true,
                    trailingIcon: Icons.add,
                    isTrustedContactScreen: true,
                  ),
                  body: SafeArea(
                    child: Column(children: [
                      Expanded(
                          child: provider.fetchedTrustedContact.isEmpty
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                              style: CustomTextStyles
                                                  .primaryBold18,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            ShowCaseWidget.of(myContext!)
                                                ?.startShowCase([_one]);
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
                                      style:
                                          CustomTextStyles.secondaryRegular16,
                                    ),
                                    SizedBox(
                                      height: 25.toHeight,
                                    ),
                                    CustomButton(
                                      isOrange: true,
                                      buttonText:
                                          pro_text_strings.TextStrings().add,
                                      height: 40.toHeight,
                                      width: 115.toWidth,
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ContactsScreen(
                                                    asSelectionScreen: true,
                                                    context: NavService
                                                        .navKey.currentContext,
                                                    selectedList: (s) async {
                                                      s.forEach(
                                                          (element) async {
                                                        await provider
                                                            .addTrustedContacts(
                                                                element!);
                                                      });
                                                      await provider
                                                          .setTrustedContact();
                                                    },
                                                  )),
                                        );
                                      },
                                    )
                                  ],
                                )
                              : ListView.builder(
                                  itemCount: provider.trustedContacts.length,
                                  itemBuilder: (context, index) {
                                    Uint8List? byteImage;

                                    if (provider.trustedContacts[index]!
                                            .tags!['image'] !=
                                        null) {
                                      byteImage = CommonUtilityFunctions()
                                          .getContactImage(
                                              provider.trustedContacts[index]!);
                                    }

                                    return ContactListTile(
                                      plainView: true,
                                      isSelected: false,
                                      onlyRemoveMethod: true,
                                      onTileTap: () {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) =>
                                              RemoveTrustedContact(
                                            pro_text_strings.TextStrings()
                                                .removeTrustedSender,
                                            contact: provider
                                                .fetchedTrustedContact[index],
                                          ),
                                        );
                                      },
                                      onAdd: () {},
                                      onRemove: () {},
                                      name: provider.trustedContacts[index]!
                                                      .tags !=
                                                  null &&
                                              provider.trustedContacts[index]!
                                                      .tags!['name'] !=
                                                  null
                                          ? provider.trustedContacts[index]!
                                              .tags!['name']
                                          : provider
                                              .trustedContacts[index]!.atSign!
                                              .substring(1),
                                      atSign: provider
                                          .trustedContacts[index]!.atSign,
                                      image: byteImage != null
                                          ? CustomCircleAvatar(
                                              byteImage: byteImage,
                                              nonAsset: true,
                                            )
                                          : ContactInitial(
                                              initials: provider
                                                  .trustedContacts[index]!
                                                  .atSign,
                                            ),
                                    );
                                  },
                                )),
                    ]),
                  ),
                );
              }));
            }));
  }
}
