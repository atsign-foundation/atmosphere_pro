import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/avatar_widget.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/card_widget.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:atsign_atmosphere_pro/view_models/welcome_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ContactDetailScreen extends StatefulWidget {
  final AtContact contact;

  const ContactDetailScreen({
    Key? key,
    required this.contact,
  }) : super(key: key);

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  late TrustedContactProvider _trustedContactProvider;
  late ContactService _contactService;
  late WelcomeScreenProvider _welcomeScreenProvider;

  bool isTrusted = false;

  @override
  void initState() {
    _trustedContactProvider = TrustedContactProvider();
    _welcomeScreenProvider = WelcomeScreenProvider();
    _contactService = ContactService();
    checkTrustedContact();
    super.initState();
  }

  void checkTrustedContact() {
    _trustedContactProvider.trustedContacts.forEach((element) {
      if (element.atSign == widget.contact.atSign) {
        setState(() {
          isTrusted = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: double.infinity,
          width: double.infinity,
          margin: EdgeInsets.only(top: 120),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: [
                  const Spacer(),
                  Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        height: 31,
                        alignment: Alignment.topRight,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                        ),
                        margin: const EdgeInsets.only(right: 27, top: 30),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: ColorConstants.grey,
                          ),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Center(
                          child: Text(
                            "Close",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: ColorConstants.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 42),
                child: Row(
                  children: <Widget>[
                    AvatarWidget(
                      size: 83,
                      borderRadius: 24,
                      contact: widget.contact,
                    ),
                    const SizedBox(width: 25),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              widget.contact.atSign ?? '',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Flexible(
                            child: Text(
                              widget.contact.tags?['name'] ??
                                  widget.contact.atSign!.substring(1),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Flexible(
                child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 36,
                    vertical: 25,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop(false);
                          _welcomeScreenProvider.selectedContacts = [
                            GroupContactsModel(
                              contactType: ContactsType.CONTACT,
                              contact: widget.contact,
                            ),
                          ];
                          _welcomeScreenProvider.changeBottomNavigationIndex(0);
                        },
                        child: Container(
                          height: 63,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: <Color>[
                                ColorConstants.orangeColor,
                                ColorConstants.yellow,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Text(
                                  "Transfer Now",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 24),
                                SvgPicture.asset(
                                  AppVectors.icArrow,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 46),
                      isTrusted
                          ? CardButton(
                              icon: AppVectors.icBigTrustActivated,
                              title: "Trusted",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: ColorConstants.orange,
                              ),
                              borderColor: ColorConstants.orange,
                              backgroundColor:
                                  ColorConstants.orange.withOpacity(0.2),
                              onTap: () async {
                                await _trustedContactProvider
                                    .removeTrustedContacts(widget.contact);
                                setState(() {
                                  isTrusted = false;
                                });
                              },
                            )
                          : CardButton(
                              icon: AppVectors.icTrust,
                              title: "Add To Trusted",
                              onTap: () async {
                                await _trustedContactProvider
                                    .addTrustedContacts(widget.contact);
                                setState(() {
                                  isTrusted = true;
                                });
                              },
                            ),
                      const SizedBox(height: 25),
                      CardButton(
                        icon: AppVectors.icTrash,
                        title: "Delete",
                        onTap: () async {
                          await _contactService.deleteAtSign(
                            atSign: widget.contact.atSign!,
                          );
                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(height: 25),
                      CardButton(
                        icon: AppVectors.icBlock,
                        title: "Block",
                        onTap: () async {
                          await _contactService.blockUnblockContact(
                            contact: widget.contact,
                            blockAction: true,
                          );
                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(height: 25),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
