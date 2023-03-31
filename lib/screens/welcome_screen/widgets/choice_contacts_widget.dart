import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contacts_group_flutter/at_contacts_group_flutter.dart';
import 'package:atsign_atmosphere_pro/screens/contact_new_version/widget/list_contact_widget.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class ChoiceContactsWidget extends StatefulWidget {
  final List<GroupContactsModel>? selectedContacts;

  const ChoiceContactsWidget({
    Key? key,
    this.selectedContacts,
  }) : super(key: key);

  @override
  State<ChoiceContactsWidget> createState() => _ChoiceContactsWidgetState();
}

class _ChoiceContactsWidgetState extends State<ChoiceContactsWidget> {
  late TrustedContactProvider trustedProvider;
  late List<GroupContactsModel> listContact;

  @override
  void initState() {
    trustedProvider = context.read<TrustedContactProvider>();
    listContact = widget.selectedContacts ?? [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: MediaQuery.of(context).size.height - 60,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xFFF4F4F4),
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
              Padding(
                padding: const EdgeInsets.only(left: 27),
                child: Text(
                  "Send To:",
                  style: TextStyle(
                    fontSize: 20.toFont,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                child: ListContactWidget(
                  trustedContacts: trustedProvider.trustedContacts,
                  isSelectMultiContacts: true,
                  showGroups: true,
                  isShowFilterBar: false,
                  selectedContacts: listContact,
                  searchBackgroundColor: Colors.white,
                  searchBorderColor: Colors.white,
                  hintText: "Search",
                  onSelectContacts: (contacts) {
                    setState(() {
                      listContact = contacts;
                    });
                  },
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 44,
                    vertical: 24,
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop(listContact);
                    },
                    child: Container(
                      width: double.infinity,
                      height: 51.toHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black,
                      ),
                      child: Center(
                        child: Text(
                          "Select (${listContact.length})",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.toFont,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
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
              child: SvgPicture.asset(
                AppVectors.icClose,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
