import 'package:at_contacts_group_flutter/screens/group_contact_view/group_contact_view.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
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
  String headerText;

  @override
  void initState() {
    headerText = TextStrings().welcomeContactPlaceholder;
    initGroups();
    super.initState();
  }

  initGroups() async {
    await GroupService().init(await BackendService.getInstance().getAtSign());
    await GroupService().fetchGroupsAndContacts();
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.toFont),
        child: Container(
            color: ColorConstants.inputFieldColor,
            child: _ExpansionTileWidget(
              headerText,
              (index) {
                widget.onUpdate(true);
                setState(() {});
              },
            )),
      ),
    );
  }
}

class _ExpansionTileWidget extends StatelessWidget {
  final String headerText;
  final Function(int) onSelected;

  _ExpansionTileWidget(this.headerText, this.onSelected);
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      backgroundColor: ColorConstants.inputFieldColor,
      title: Text(
        headerText,
        style: TextStyle(
          color: ColorConstants.fadedText,
          fontSize: 14.toFont,
        ),
      ),
      trailing: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroupContactView(
                asSelectionScreen: true,
                // singleSelection: true,
                showGroups: true,
                showContacts: true,
                selectedList: (s) {
                  Provider.of<WelcomeScreenProvider>(
                          NavService.navKey.currentContext,
                          listen: false)
                      .updateSelectedContacts(s);
                },
                // singleSelection: true,
              ),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Image.asset(
            ImageConstants.contactsIcon,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
