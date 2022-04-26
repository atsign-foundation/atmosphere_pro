import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/screens/group_contact_view/group_contact_view.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/trusted_sender/desktop_trusted_sender.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/error_dialog.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_callback.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart'
    as pro_text_strings;
import 'package:provider/provider.dart';

class DesktopEmptySender extends StatefulWidget {
  @override
  _DesktopEmptySenderState createState() => _DesktopEmptySenderState();
}

class _DesktopEmptySenderState extends State<DesktopEmptySender> {
  bool isContactSelecttion = false, isLoading = true;
  List<AtContact?> trustedContacts = [];

  @override
  void initState() {
    super.initState();
  }

  getTrustedSenderList() async {
    await Provider.of<TrustedContactProvider>(context, listen: false)
        .getTrustedContact();
    trustedContacts =
        await Provider.of<TrustedContactProvider>(context, listen: false)
            .trustedContacts;

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProviderHandler<TrustedContactProvider>(
      functionName: 'get_trusted_contacts',
      load: (provider) async => await provider.getTrustedContact(),
      showError: false,
      errorBuilder: (provider) => Container(),
      successBuilder: (provider) {
        if (provider.trustedContacts.isNotEmpty) {
          return DesktopTrustedSender();
        }
        return Container(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                            color: Color(0xffFCF9F9),
                            borderRadius: BorderRadius.circular(80.toHeight)),
                        height: 160.toHeight,
                        width: 160.toHeight,
                        child: Image.asset(ImageConstants.emptyTrustedSenders),
                      ),
                    ),
                    SizedBox(height: 20.toHeight),
                    Text(
                      pro_text_strings.TextStrings().noTrustedSenders,
                      style: CustomTextStyles.primaryBold18,
                    ),
                    SizedBox(height: 10.toHeight),
                    Text(
                      pro_text_strings.TextStrings().addTrustedSender,
                      style: CustomTextStyles.secondaryRegular16,
                    ),
                    SizedBox(
                      height: 25.toHeight,
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isContactSelecttion = !isContactSelecttion;
                        });
                      },
                      style: ButtonStyle(backgroundColor:
                          MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          return ColorConstants.orangeColor;
                        },
                      ), fixedSize: MaterialStateProperty.resolveWith<Size>(
                        (Set<MaterialState> states) {
                          return Size(160, 40);
                        },
                      )),
                      child: Text(
                        'Add',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            isContactSelecttion
                ? Expanded(
                    child: GroupContactView(
                      asSelectionScreen: true,
                      singleSelection: false,
                      showGroups: false,
                      showContacts: true,
                      isDesktop: true,
                      selectedList: (_list) {
                        providerCallback<TrustedContactProvider>(context,
                            task: (provider) async {
                              _list.forEach((element) async {
                                if (element!.contact != null) {
                                  await provider
                                      .addTrustedContacts(element.contact);
                                }
                              });
                              await provider.setTrustedContact();
                              isContactSelecttion = false;
                            },
                            taskName: (provider) => provider.AddTrustedContacts,
                            onSuccess: (provider) {},
                            onError: (err) => ErrorDialog()
                                .show(err.toString(), context: context));
                      },
                      onBackArrowTap: (selectedGroupContacts) {
                        if (mounted) {
                          setState(() {
                            isContactSelecttion = !isContactSelecttion;
                          });
                        }
                      },
                      onDoneTap: () {},
                    ),
                  )
                : SizedBox()
          ],
        ));
      },
    );
  }
}
