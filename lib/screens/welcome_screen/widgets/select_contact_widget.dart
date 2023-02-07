import 'package:at_contacts_group_flutter/at_contacts_group_flutter.dart';
import 'package:at_contacts_group_flutter/screens/group_contact_view/group_contact_view.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/view_models/welcome_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectContactWidget extends StatefulWidget {
  final Function(bool) onUpdate;
  SelectContactWidget(this.onUpdate);
  @override
  _SelectContactWidgetState createState() => _SelectContactWidgetState();
}

class _SelectContactWidgetState extends State<SelectContactWidget> {
  String? headerText;

  @override
  void initState() {
    headerText = TextStrings().welcomeContactPlaceholder;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Theme(
      data: ThemeData(
        dividerColor: Colors.transparent,
        textTheme: TextTheme(
          subtitle1: TextStyle(
            color: ColorConstants.inputFieldColor,
          ),
        ),
      ),
      child: Container(
          child: _ExpansionTileWidget(
        headerText,
        (index) {
          widget.onUpdate(true);
          setState(() {});
        },
      )),
    );
  }
}

class _ExpansionTileWidget extends StatelessWidget {
  final String? headerText;
  final Function(int) onSelected;

  _ExpansionTileWidget(this.headerText, this.onSelected);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        selectContact(context);
      },
      child: Container(
        height: 62.toHeight,
        width: 350.toWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ColorConstants.grey),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.toWidth, 20.toHeight, 0, 20.toHeight),
          child: Text(
            'Select atSign',
            style: TextStyle(color: ColorConstants.grey, fontSize: 15.toFont),
          ),
        ),
      ),
    );
  }

  selectContact(BuildContext context) async {
    List<GroupContactsModel>? contactSelectedHistory = [];
    Provider.of<WelcomeScreenProvider>(NavService.navKey.currentContext!,
            listen: false)
        .selectedContacts
        .forEach((GroupContactsModel? element) {
      contactSelectedHistory.add(element ?? GroupContactsModel());
    });

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupContactView(
          asSelectionScreen: true,
          showGroups: true,
          showContacts: true,
          selectedList: (s) {
            Provider.of<WelcomeScreenProvider>(
                    NavService.navKey.currentContext!,
                    listen: false)
                .updateSelectedContacts(s);
            onSelected(s.length);
          },
          // singleSelection: true,
          contactSelectedHistory: contactSelectedHistory,
        ),
      ),
    );
  }
}
