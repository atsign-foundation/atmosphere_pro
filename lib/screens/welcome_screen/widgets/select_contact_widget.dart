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
  String headerText;

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
        tilePadding: SizeConfig().isTablet(context)
            ? EdgeInsets.symmetric(vertical: 10.toFont, horizontal: 10.toFont)
            : EdgeInsets.only(left: 10.toFont, right: 10.toFont),
        backgroundColor: ColorConstants.inputFieldColor,
        title: InkWell(
          onTap: (){
            selectContact(context);
          },
          child: Text(
            headerText,
            style: TextStyle(
              color: ColorConstants.fadedText,
              fontSize: 14.toFont,
            ),
          ),
        ),
        trailing: InkWell(
          onTap: (){
            selectContact(context);
          },
          child: ExpansionTile(
            backgroundColor: ColorConstants.inputFieldColor,
            title: Text(
              headerText,
              style: TextStyle(
                color: ColorConstants.fadedText,
                fontSize: 14.toFont,
              ),
            ),
            trailing: Container(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Image.asset(
                ImageConstants.contactsIcon,
                color: Colors.black,
              ),
            ),
          ),
        ));
  }

  selectContact(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupContactView(
          asSelectionScreen: true,
          // singleSelection: true,
          showGroups: true,
          showContacts: true,
          selectedList: (s) {
            Provider.of<WelcomeScreenProvider>(NavService.navKey.currentContext,
                    listen: false)
                .updateSelectedContacts(s);
            onSelected(s.length);
          },
          // singleSelection: true,
          contactSelectedHistory: Provider.of<WelcomeScreenProvider>(
                  NavService.navKey.currentContext,
                  listen: false)
              .selectedContacts,
        ),
      ),
    );
  }
}
