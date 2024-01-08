import 'dart:typed_data';

import 'package:at_contacts_group_flutter/at_contacts_group_flutter.dart';
import 'package:at_contacts_group_flutter/screens/group_contact_view/group_contact_view.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_common_widgets/dektop_custom_person_tile.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_common_widgets/desktop_custom_input_field.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_common_widgets/desktop_header.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/error_dialog.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_callback.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/trusted_senders_screen/widgets/remove_trusted_contact_dialog.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:flutter/material.dart';
import 'package:at_contact/at_contact.dart';

class DesktopTrustedSender extends StatefulWidget {
  @override
  _DesktopTrustedSenderState createState() => _DesktopTrustedSenderState();
}

class _DesktopTrustedSenderState extends State<DesktopTrustedSender> {
  bool _isFilterOption = false, isContactSelection = false;
  List<AtContact> trustedContacts = [];
  String searchText = '';
  TrustedContactProvider? trustedContact;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      padding: EdgeInsets.all(20),
      color: ColorConstants.fadedBlue,
      child: ProviderHandler<TrustedContactProvider>(
          functionName: 'get_trusted_contacts',
          load: (provider) async {
            await provider.getTrustedContact();
            await provider.migrateTrustedContact();
          },
          showError: false,
          errorBuilder: (provider) => Center(
                child: Text(TextStrings().somethingWentWrong),
              ),
          successBuilder: (provider) {
            return Stack(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 20),
                          DesktopHeader(
                            title: TextStrings().trustedSenders,
                            isTitleCentered: true,
                            showBackIcon: false,
                            onFilter: (val) {},
                            actions: [
                              DesktopCustomInputField(
                                  backgroundColor: Colors.white,
                                  hintText: TextStrings().search,
                                  icon: Icons.search,
                                  height: 45,
                                  iconColor: ColorConstants.greyText,
                                  initialValue: searchText,
                                  value: (String s) {
                                    setState(() {
                                      searchText = s;
                                    });
                                  }),
                              SizedBox(width: 15.toWidth),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    isContactSelection = !isContactSelection;
                                  });
                                },
                                style: ButtonStyle(backgroundColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                    return ColorConstants.orangeColor;
                                  },
                                ), fixedSize:
                                    MaterialStateProperty.resolveWith<Size>(
                                  (Set<MaterialState> states) {
                                    return Size(100, 40);
                                  },
                                )),
                                child: Text(
                                  TextStrings().add,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                              SizedBox(width: 15.toWidth),
                            ],
                          ),
                          SizedBox(height: 20),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Wrap(
                              alignment: WrapAlignment.start,
                              runAlignment: WrapAlignment.start,
                              runSpacing: 10.0,
                              spacing: 30.0,
                              children: List.generate(
                                  provider.trustedContacts.length, (index) {
                                Uint8List? byteImage = CommonUtilityFunctions()
                                    .getCachedContactImage(
                                  provider.trustedContacts[index].atSign!,
                                );
                                if (provider.trustedContacts[index].atSign!
                                    .contains(searchText)) {
                                  return InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) =>
                                            RemoveTrustedContact(
                                          TextStrings().removeTrustedSender,
                                          image: byteImage,
                                          contact: AtContact(
                                              atSign: provider
                                                  .trustedContacts[index]
                                                  .atSign),
                                        ),
                                      );
                                    },
                                    child: DesktopCustomPersonVerticalTile(
                                      title: provider
                                          .trustedContacts[index].atSign,
                                      subTitle: provider
                                          .trustedContacts[index].atSign,
                                      showCancelIcon: false,
                                      showImage:
                                          byteImage != null ? true : false,
                                      image: byteImage,
                                    ),
                                  );
                                } else {
                                  return SizedBox();
                                }
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    isContactSelection
                        ? Expanded(
                            child: GroupContactView(
                              asSelectionScreen: true,
                              singleSelection: false,
                              showGroups: false,
                              showContacts: true,
                              isDesktop: true,
                              contactSelectedHistory: provider.trustedContacts
                                  .map((e) => GroupContactsModel(contact: e))
                                  .toList(),
                              selectedList: (_list) {
                                providerCallback<TrustedContactProvider>(
                                    context,
                                    task: (provider) async {
                                      _list.forEach((element) async {
                                        if (element!.contact != null) {
                                          await provider.addTrustedContacts(
                                              element.contact!);
                                        }
                                      });

                                      isContactSelection = false;
                                    },
                                    taskName: (provider) =>
                                        provider.AddTrustedContacts,
                                    onSuccess: (provider) {},
                                    onError: (err) => ErrorDialog().show(
                                        err.toString(),
                                        context: context));
                              },
                              onBackArrowTap: (selectedGroupContacts) {
                                if (mounted) {
                                  setState(() {
                                    isContactSelection = !isContactSelection;
                                  });
                                }
                              },
                              onDoneTap: () {},
                            ),
                          )
                        : SizedBox()
                  ],
                ),
                _isFilterOption
                    ? Positioned(
                        right: 15,
                        top: 55,
                        child: Container(
                          width: 150,
                          padding: EdgeInsets.only(
                              right: 10, left: 10, top: 10, bottom: 10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                  color: ColorConstants.light_grey, width: 1),
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    TextStrings().sortBy,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _isFilterOption = !_isFilterOption;
                                      });
                                    },
                                    child: Icon(Icons.close, size: 18),
                                  ),
                                ],
                              ),
                              Divider(
                                height: 10,
                                color: ColorConstants.greyText,
                              ),
                              getFilterOptionWidget(TextStrings().byName, true),
                              getFilterOptionWidget(
                                  TextStrings().byDate, false),
                              SizedBox(height: 15),
                              TextButton(
                                onPressed: () {},
                                style: ButtonStyle(backgroundColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                    return ColorConstants.orangeColor;
                                  },
                                ), fixedSize:
                                    MaterialStateProperty.resolveWith<Size>(
                                  (Set<MaterialState> states) {
                                    return Size(120, 40);
                                  },
                                )),
                                child: Text(
                                  TextStrings().apply,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SizedBox(),
              ],
            );
          }),
    );
  }

  Widget underline({double height = 2, double width = 70}) {
    return Container(
      height: height,
      width: width,
      color: Colors.black,
    );
  }

  Widget getFilterOptionWidget(String title, bool isSelected) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Checkbox(
          value: isSelected,
          onChanged: (value) {},
          activeColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
        ),
      ],
    );
  }
}
