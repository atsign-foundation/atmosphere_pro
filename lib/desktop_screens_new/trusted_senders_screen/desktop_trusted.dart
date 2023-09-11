import 'dart:typed_data';

import 'package:at_backupkey_flutter/utils/size_config.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/trusted_senders_screen/widgets/desktop_contact_tile.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DesktopTrustedScreen extends StatefulWidget {
  const DesktopTrustedScreen({Key? key}) : super(key: key);

  @override
  State<DesktopTrustedScreen> createState() => _DesktopTrustedScreenState();
}

class _DesktopTrustedScreenState extends State<DesktopTrustedScreen> {
  String searchText = '';
  bool isSearchActive = false;
  late TextEditingController searchController;

  @override
  void initState() {
    searchController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      padding: EdgeInsets.all(40),
      height: SizeConfig().screenHeight,
      color: const Color(0xFFF8F8F8),
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
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // HEADER
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Trusted",
                    style: TextStyle(
                      fontSize: 12.toFont,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  isSearchActive
                      ? Container(
                          width: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextField(
                            controller: searchController,
                            onChanged: (value) {
                              setState(() {
                                searchText = value;
                              });
                            },
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              hintText: "Search...",
                              suffixIcon: InkWell(
                                  onTap: () {
                                    searchText.isNotEmpty
                                        ? setState(() {
                                            searchText = '';
                                            searchController.clear();
                                          })
                                        : setState(() {
                                            isSearchActive = false;
                                          });
                                  },
                                  child: const Icon(Icons.close)),
                            ),
                          ),
                        )
                      : SizedBox(),
                  SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        isSearchActive = !isSearchActive;
                        searchText = "";
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        AppVectors.icSearch,
                        color: Colors.black,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      AppVectors.icRefresh,
                      color: Colors.black,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),

              SizedBox(
                height: 5,
              ),
              Divider(
                thickness: 1,
                color: Colors.black,
              ),
              SizedBox(
                height: 10,
              ),

              // BODY
              Expanded(
                child: Container(
                  width: SizeConfig().screenWidth,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      provider.trustedContacts.isNotEmpty
                          ? Expanded(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: provider.trustedContacts.length,
                                itemBuilder: (context, index) {
                                  Uint8List? byteImage =
                                      CommonUtilityFunctions()
                                          .getCachedContactImage(
                                    provider.trustedContacts[index].atSign!,
                                  );
                                  if (provider.trustedContacts[index].atSign!
                                      .contains(searchText)) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      child: DesktopContactTile(
                                        title: provider
                                            .trustedContacts[index].atSign,
                                        subTitle: provider
                                            .trustedContacts[index].atSign,
                                        showImage:
                                            byteImage != null ? true : false,
                                        image: byteImage,
                                      ),
                                    );
                                  } else {
                                    return SizedBox();
                                  }
                                },
                              ),
                            )
                          : SizedBox(),
                      provider.trustedContacts.isEmpty
                          ? Expanded(
                              child: Container(
                                  padding: EdgeInsets.only(left: 30),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Add contacts to trusted by ",
                                        style: TextStyle(
                                          color: ColorConstants.grey,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "selecting ",
                                            style: TextStyle(
                                              color: ColorConstants.grey,
                                              fontSize: 18,
                                            ),
                                          ),
                                          Icon(
                                            Icons.verified_outlined,
                                            color:
                                                Theme.of(context).primaryColor,
                                            size: 25,
                                          ),
                                          Text(
                                            " next to their name!",
                                            style: TextStyle(
                                              color: ColorConstants.grey,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  )),
                            )
                          : SizedBox(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
