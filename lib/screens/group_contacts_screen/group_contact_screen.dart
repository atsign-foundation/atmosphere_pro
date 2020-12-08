import 'package:atsign_atmosphere_app/screens/common_widgets/app_bar.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_app/screens/contact/widgets/search_field.dart';
import 'package:atsign_atmosphere_app/screens/group_contacts_screen/widgets/custom_bottom_sheet.dart';
import 'package:atsign_atmosphere_app/screens/group_contacts_screen/widgets/custom_list_view.dart';
import 'package:atsign_atmosphere_app/screens/group_contacts_screen/widgets/horizontal_list_view.dart';
import 'package:atsign_atmosphere_app/screens/group_contacts_screen/widgets/limit_alert.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/view_models/contact_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupContactScreen extends StatefulWidget {
  final bool isTrustedScreen;

  const GroupContactScreen({Key key, this.isTrustedScreen = false})
      : super(key: key);
  @override
  _GroupContactScreenState createState() => _GroupContactScreenState();
}

class _GroupContactScreenState extends State<GroupContactScreen> {
  // ContactProvider _contactProvider = ContactProvider();
  // ContactProvider _contactProvider;

  @override
  void initState() {
    // _contactProvider = Provider.of<ContactProvider>(context, listen: false);
    // Future.delayed(Duration(seconds: 1), ini);
    print('IS TRUSTED IN MAIN SCREEN====>${widget.isTrustedScreen}');
    super.initState();
  }

  // ini() async {
  //   if (widget.isTrustedScreen) {

  //     // Provider.of<ContactProvider>(context, listen: false)
  //     //     .getTrustedContact(trustedContactsKey);
  //   }
  // }

  @override
  void didChangeDependencies() {
    // _contactProvider = Provider.of<ContactProvider>(context);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          showLeadingicon: false,
          showTitle: true,
          title: 'Select Contacts',
        ),
        bottomSheet: Consumer<ContactProvider>(
          builder: (context, provider, _) => CustomBottomSheet(
            list: (widget.isTrustedScreen)
                ? provider.trustedContacts
                : provider.selectedContacts,
            onPressed: () {
              (widget.isTrustedScreen)
                  ? {
                      provider.setTrustedContact(),
                      Navigator.pop(context),
                    }
                  : Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              (widget.isTrustedScreen)
                  ? Container()
                  : Consumer<ContactProvider>(
                      builder: (context, provider, _) => LimitAlert(
                        limitReached: provider.limitReached,
                        // onChange: (s) {
                        //   provider.limitReached = s;
                        // },
                      ),
                    ),
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Consumer<ContactProvider>(
                      builder: (context, provider, _) => Container(
                        height: 40.toHeight,
                        child: (provider.limitReached)
                            ? Container()
                            : ContactSearchField(
                                TextStrings().searchContact,
                                (text) => setState(() {
                                  // searchText = text;
                                }),
                              ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Consumer<ContactProvider>(
                      builder: (context, provider, __) {
                        return HorizontalCircularList(
                          list: (widget.isTrustedScreen)
                              ? provider.trustedContacts
                              : provider.selectedContacts,
                          isTrustedSender: widget.isTrustedScreen,
                        );
                      },
                    ),
                    SizedBox(height: 10.toHeight),
                    ProviderHandler<ContactProvider>(
                      functionName: 'get_contacts',
                      showError: false,
                      errorBuilder: (provider) => Center(
                        child: Text('Some error occured'),
                      ),
                      load: (provider) => provider.getContacts(),
                      successBuilder: (provider) {
                        return CustomListView(
                          isTrustedContact: widget.isTrustedScreen,
                          contactList: provider.contactList,
                          secondaryList: widget.isTrustedScreen
                              ? provider.trustedContacts
                              : provider.selectedContacts,
                        );
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
