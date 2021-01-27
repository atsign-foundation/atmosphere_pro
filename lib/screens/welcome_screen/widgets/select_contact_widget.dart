import 'package:atsign_atmosphere_pro/routes/route_names.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/view_models/contact_provider.dart';
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

  ContactProvider contactProvider;

  @override
  void initState() {
    headerText = TextStrings().welcomeContactPlaceholder;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (contactProvider == null) {
      contactProvider = Provider.of<ContactProvider>(context);
    }

    super.didChangeDependencies();
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
            child:
                // contactProvider.selectedAtsign == null
                _ExpansionTileWidget(
              headerText,
              (index) {
                widget.onUpdate(true);
                setState(() {});
              },
            )
            // : _ListTileWidget(
            //     () {
            //       contactProvider.selectedAtsign = null;
            //       widget.onUpdate(false);
            //       setState(() {});
            //     },
            //   ),
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
      trailing: InkWell(
        onTap: () async {
          await Navigator.pushNamed(context, Routes.CONTACT_SCREEN, arguments: {
            'currentAtsign': BackendService.getInstance().currentAtsign,
            'context': NavService.navKey.currentContext,
            'asSelectionScreen': true,
            'selectedList': (s) {
              Provider.of<WelcomeScreenProvider>(
                      NavService.navKey.currentContext,
                      listen: false)
                  .updateSelectedContacts(s);
            }
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Image.asset(
            ImageConstants.contactsIcon,
            color: Colors.black,
          ),
        ),
      ),
      // children: List.generate(
      //   Provider.of<ContactProvider>(context).contactList.length,
      //   (index) => Container(
      //     decoration: BoxDecoration(
      //       border: Border(
      //         bottom: BorderSide(
      //           color: ColorConstants.dividerColor.withOpacity(0.1),
      //           width: 1.toHeight,
      //         ),
      //       ),
      //     ),
      //     child: ListTile(
      //       onTap: () {
      //         Provider.of<ContactProvider>(context, listen: false)
      //                 .selectedAtsign =
      //             Provider.of<ContactProvider>(context, listen: false)
      //                 .contactList[index]
      //                 .atSign;
      //         onSelected(index);
      //       },
      //       title: Text(
      //         Provider.of<ContactProvider>(context)
      //             .contactList[index]
      //             .atSign
      //             .substring(1),
      //         style: TextStyle(
      //           color: Colors.black,
      //           fontSize: 14.toFont,
      //         ),
      //       ),
      //       subtitle: Text(
      //         Provider.of<ContactProvider>(context).contactList[index].atSign,
      //         style: TextStyle(
      //           color: ColorConstants.fadedText,
      //           fontSize: 14.toFont,
      //         ),
      //       ),
      //       leading: CustomCircleAvatar(
      //         image: ImageConstants.imagePlaceholder,
      //       ),
      //       trailing: Icon(Icons.add),
      //     ),
      //   ),
      // ),
    );
  }
}

// class _ListTileWidget extends StatelessWidget {
//   final Function() onRemove;
//   _ListTileWidget(this.onRemove);

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       title: Text(
//         Provider.of<ContactProvider>(context).selectedAtsign ?? '',
//         style: TextStyle(
//           color: ColorConstants.fadedText,
//           fontSize: 14.toFont,
//         ),
//       ),
//       leading: Container(
//         height: 40.toWidth,
//         width: 40.toWidth,
//         decoration: BoxDecoration(
//           color: Colors.black,
//           shape: BoxShape.circle,
//         ),
//         child: CustomCircleAvatar(
//           image: ImageConstants.imagePlaceholder,
//         ),
//       ),
//       trailing: InkWell(
//         onTap: onRemove,
//         child: Container(
//           padding: EdgeInsets.symmetric(vertical: 15.toHeight),
//           child: Icon(
//             Icons.clear,
//             color: Colors.black,
//           ),
//         ),
//       ),
//     );
//   }
// }
