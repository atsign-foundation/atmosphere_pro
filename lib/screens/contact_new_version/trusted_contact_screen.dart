import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/screens/new_version/widget/single_contact_widget.dart';
import 'package:atsign_atmosphere_pro/screens/contact_new_version/contact_detail_screen.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TrustedContactScreen extends StatefulWidget {
  const TrustedContactScreen({Key? key}) : super(key: key);

  @override
  State<TrustedContactScreen> createState() => _TrustedContactScreenState();
}

class _TrustedContactScreenState extends State<TrustedContactScreen> {
  late TrustedContactProvider provider;
  late TextEditingController searchController;

  List<AtContact> trustedContacts = [];

  @override
  void initState() {
    provider = context.read<TrustedContactProvider>();
    searchController = TextEditingController();
    super.initState();
    trustedContacts = provider.trustedContacts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: EdgeInsets.only(top: 120),
          height: double.infinity,
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
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Trusted Senders",
                      style: TextStyle(
                        fontSize: 25.toFont,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      height: 48,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: ColorConstants.grey,
                        ),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              style: TextStyle(
                                fontSize: 14.toFont,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  trustedContacts = provider.trustedContacts
                                      .where((element) => (element.atSign ?? '')
                                          .contains(value))
                                      .toList();
                                });
                              },
                              decoration: InputDecoration.collapsed(
                                hintText: 'Search by atSign or nickname',
                                hintStyle: TextStyle(
                                  color: ColorConstants.grey,
                                  fontSize: 14.toFont,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              // onChanged: widget.onSearch,
                            ),
                          ),
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Icon(
                              Icons.search,
                              color: ColorConstants.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              Expanded(
                child: Consumer<TrustedContactProvider>(
                  builder: (context, myProvider, child) {
                    return Scrollbar(
                      child: SingleContactWidget(
                        contacts: trustedContacts,
                        onTapContact: (contact) async {
                          await showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            useRootNavigator: true,
                            backgroundColor: Colors.transparent,
                            builder: (BuildContext context) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 120),
                                child: ContactDetailScreen(
                                  contact: contact,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
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
}
