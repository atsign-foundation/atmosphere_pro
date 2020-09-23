import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/images.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:flutter/material.dart';

class SelectContactWidget extends StatefulWidget {
  final Function(bool) onUpdate;
  SelectContactWidget(this.onUpdate);
  @override
  _SelectContactWidgetState createState() => _SelectContactWidgetState();
}

class _SelectContactWidgetState extends State<SelectContactWidget> {
  String headerText;
  int selectedIndex;

  @override
  void initState() {
    headerText = TextStrings().welcomeContactPlaceholder;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          child: selectedIndex == null
              ? _ExpansionTileWidget(
                  headerText,
                  (index) {
                    widget.onUpdate(true);
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                )
              : _ListTileWidget(
                  selectedIndex,
                  () {
                    widget.onUpdate(false);
                    setState(() {
                      selectedIndex = null;
                    });
                  },
                ),
        ),
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
      trailing: Container(
        padding: EdgeInsets.symmetric(vertical: 15.toHeight),
        child: Image.asset(
          ImageConstants.contactsIcon,
          color: Colors.black,
        ),
      ),
      children: List.generate(
        5,
        (index) => Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: ColorConstants.dividerColor.withOpacity(0.1),
                width: 1.toHeight,
              ),
            ),
          ),
          child: ListTile(
            onTap: () => onSelected(index),
            title: Text(
              'Levina Thomas $index',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14.toFont,
              ),
            ),
            subtitle: Text(
              '@levinat',
              style: TextStyle(
                color: ColorConstants.fadedText,
                fontSize: 14.toFont,
              ),
            ),
            leading: Container(
              height: 40.toWidth,
              width: 40.toWidth,
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
            trailing: Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

class _ListTileWidget extends StatelessWidget {
  final int selectedIndex;
  final Function() onRemove;
  _ListTileWidget(this.selectedIndex, this.onRemove);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        'Levina Thomas $selectedIndex',
        style: TextStyle(
          color: ColorConstants.fadedText,
          fontSize: 14.toFont,
        ),
      ),
      leading: Container(
        height: 40.toWidth,
        width: 40.toWidth,
        decoration: BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
      ),
      trailing: InkWell(
        onTap: onRemove,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 15.toHeight),
          child: Icon(
            Icons.clear,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
