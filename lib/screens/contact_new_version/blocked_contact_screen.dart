import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contacts_flutter/models/contact_base_model.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/header_widget.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';

class BlockedContactScreen extends StatefulWidget {
  const BlockedContactScreen({Key? key}) : super(key: key);

  @override
  State<BlockedContactScreen> createState() => _BlockedContactScreenState();
}

class _BlockedContactScreenState extends State<BlockedContactScreen> {
  late ContactService _contactService;
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    _contactService = ContactService();
    searchController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await _contactService.fetchBlockContactList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: MediaQuery.of(context).size.height - 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildHeaderWidget(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 27),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Blocked atSigns",
                      style: TextStyle(
                        fontSize: 25.toFont,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 30),
                    HeaderWidget(
                      margin: EdgeInsets.only(bottom: 28),
                      onReloadCallback: () async {
                        await _contactService.fetchBlockContactList();
                        searchController.clear();
                      },
                      controller: searchController,
                      onSearch: (value) {
                        setState(() {});
                      },
                    ),
                    Container(
                      height: 37.toHeight,
                      padding: const EdgeInsets.only(left: 24),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(10),
                            topLeft: Radius.circular(10),
                          ),
                          color: ColorConstants.textBoxBg),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "atSign",
                            style: TextStyle(
                              fontSize: 15.toFont,
                              fontWeight: FontWeight.w500,
                              color: ColorConstants.sidebarTextUnselected,
                            ),
                          ),
                          Icon(
                            Icons.arrow_downward_outlined,
                            color: ColorConstants.sidebarTextUnselected,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 27),
                  child: _buildListBlocked(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(27, 24, 27, 0),
      child: Row(
        children: [
          Container(
            height: 2,
            width: 45,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                height: 31.toHeight,
                alignment: Alignment.topRight,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                ),
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
                      fontSize: 17.toFont,
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
    );
  }

  _buildListBlocked() {
    return StreamBuilder<List<BaseContact?>>(
      stream: _contactService.blockedContactStream,
      initialData: _contactService.baseBlockedList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          var listContact = snapshot.data!;
          listContact = listContact
              .where(
                (element) => (element?.contact?.atSign ?? '')
                    .contains(searchController.text),
              )
              .toList();
          return ListView.builder(
            itemCount: listContact.length,
            physics: ClampingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              return Container(
                height: 58.toHeight,
                color: Colors.white,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 18),
                              child: Text(
                                listContact[index]?.contact?.atSign ?? '',
                                style: TextStyle(
                                  fontSize: 13.toFont,
                                  fontWeight: FontWeight.w500,
                                  color: ColorConstants.textBlack,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 24),
                            child: InkWell(
                              onTap: () async {
                                await _contactService.blockUnblockContact(
                                  contact: listContact[index]!.contact!,
                                  blockAction: false,
                                );
                              },
                              child: Container(
                                height: 31.toHeight,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: ColorConstants.boxGrey,
                                  border: Border.all(
                                    color: ColorConstants.grey,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      "Unblock?",
                                      style: TextStyle(
                                        fontSize: 13.toFont,
                                        fontWeight: FontWeight.w600,
                                        color: ColorConstants.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Icon(
                                      Icons.block,
                                      color: Colors.red,
                                      size: 16,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      color: ColorConstants.textBoxBg,
                      height: 1.toHeight,
                      width: double.infinity,
                    )
                  ],
                ),
              );
            },
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
