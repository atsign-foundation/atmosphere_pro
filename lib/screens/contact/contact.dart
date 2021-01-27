// import 'dart:typed_data';

// import 'package:at_contact/at_contact.dart';
// import 'package:atsign_atmosphere_pro/routes/route_names.dart';
// import 'package:atsign_atmosphere_pro/screens/common_widgets/app_bar.dart';
// import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_circle_avatar.dart';
// import 'package:atsign_atmosphere_pro/screens/common_widgets/provider_handler.dart';
// import 'package:atsign_atmosphere_pro/screens/contact/widgets/search_field.dart';
// import 'package:atsign_atmosphere_pro/services/backend_service.dart';
// import 'package:atsign_atmosphere_pro/services/size_config.dart';
// import 'package:atsign_atmosphere_pro/utils/colors.dart';
// import 'package:atsign_atmosphere_pro/utils/images.dart';
// import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
// import 'package:atsign_atmosphere_pro/view_models/contact_provider.dart';
// import 'package:atsign_contacts/screens/contacts.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:provider/provider.dart';

// class ContactScreen extends StatefulWidget {
//   @override
//   _ContactScreenState createState() => _ContactScreenState();
// }

// class _ContactScreenState extends State<ContactScreen> {
//   ContactProvider provider;
//   String searchText;
//   BackendService _backendService;
//   @override
//   void initState() {
//     provider = ContactProvider();
//     _backendService = BackendService.getInstance();

//     super.initState();
//   }

//   @override
//   void didChangeDependencies() {
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       provider.getContacts();
//     });
//     searchText = '';
//     super.didChangeDependencies();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(child: ContactScreen()),
//       ],
//     );
//     // return Scaffold(
//     //   appBar: CustomAppBar(
//     //     showBackButton: true,
//     //     showTrailingButton: true,
//     //     showTitle: true,
//     //     title: TextStrings().sidebarContact,
//     //     onActionpressed: (String atSignName) {
//     //       Provider.of<ContactProvider>(context, listen: false)
//     //           .addContact(atSign: atSignName);
//     //     },
//     //   ),
//     //   body: Column(
//     //     children: [
//     //       Expanded(
//     //         child: ContactsScreen(
//     //           contactList: Provider.of<ContactProvider>(context, listen: false)
//     //               .contactList,
//     //           currentAtsign: _backendService.currentAtsign,
//     //         ),
//     //       )
//     //     ],
//     //   ),
//     body:
//     SingleChildScrollView(
//       child: Container(
//         margin:
//             EdgeInsets.symmetric(horizontal: 16.toWidth, vertical: 16.toHeight),
//         child: Column(
//           children: [
//             ContactSearchField(
//               TextStrings().searchContact,
//               (text) => setState(() {
//                 searchText = text;
//               }),
//             ),
//             SizedBox(
//               height: 15.toHeight,
//             ),
//             ProviderHandler<ContactProvider>(
//                 functionName: 'get_contacts',
//                 showError: true,
//                 load: (provider) => provider.getContacts(),
//                 errorBuilder: (provider) => Center(
//                       child: Text('Some error occured'),
//                     ),
//                 successBuilder: (provider) {
//                   return (provider.contactList.isEmpty)
//                       ? Center(
//                           child: Text('No Contact found'),
//                         )
//                       : ListView.builder(
//                           itemCount: 27,
//                           shrinkWrap: true,
//                           physics: NeverScrollableScrollPhysics(),
//                           itemBuilder: (context, alphabetIndex) {
//                             List<AtContact> _filteredList = [];
//                             provider.contactList.forEach((c) {
//                               if (c.atSign[1]
//                                   .toUpperCase()
//                                   .contains(searchText.toUpperCase())) {
//                                 _filteredList.add(c);
//                               }
//                             });
//                             List<AtContact> contactsForAlphabet = [];
//                             String currentChar =
//                                 String.fromCharCode(alphabetIndex + 65)
//                                     .toUpperCase();
//                             if (alphabetIndex == 26) {
//                               currentChar = 'Others';
//                               _filteredList.forEach((c) {
//                                 if (int.tryParse(c.atSign[1]) != null) {
//                                   contactsForAlphabet.add(c);
//                                 }
//                               });
//                             } else {
//                               _filteredList.forEach((c) {
//                                 if (c.atSign[1].toUpperCase() == currentChar) {
//                                   contactsForAlphabet.add(c);
//                                 }
//                               });
//                             }
//                             if (contactsForAlphabet.isEmpty) {
//                               return Container();
//                             }
//                             return Container(
//                               child: Column(
//                                 children: [
//                                   Row(
//                                     children: [
//                                       Text(
//                                         currentChar,
//                                         style: TextStyle(
//                                           color: ColorConstants.blueText,
//                                           fontSize: 16.toFont,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       SizedBox(width: 4.toWidth),
//                                       Expanded(
//                                         child: Divider(
//                                           color: ColorConstants.dividerColor
//                                               .withOpacity(0.2),
//                                           height: 1.toHeight,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   ListView.separated(
//                                       itemCount: contactsForAlphabet.length,
//                                       physics: NeverScrollableScrollPhysics(),
//                                       shrinkWrap: true,
//                                       separatorBuilder: (context, _) => Divider(
//                                             color: ColorConstants.dividerColor
//                                                 .withOpacity(0.2),
//                                             height: 1.toHeight,
//                                           ),
//                                       itemBuilder: (context, index) {
//                                         // the contact image returned is List<dynamic>
//                                         // converting to Uint8List
//                                         Widget contactImage;
//                                         if (contactsForAlphabet[index].tags !=
//                                                 null &&
//                                             contactsForAlphabet[index]
//                                                     .tags['image'] !=
//                                                 null) {
//                                           List<int> intList =
//                                               contactsForAlphabet[index]
//                                                   .tags['image']
//                                                   .cast<int>();
//                                           Uint8List image =
//                                               Uint8List.fromList(intList);
//                                           contactImage = CustomCircleAvatar(
//                                             byteImage: image,
//                                             nonAsset: true,
//                                           );
//                                         } else {
//                                           contactImage = CustomCircleAvatar(
//                                             image:
//                                                 ImageConstants.imagePlaceholder,
//                                           );
//                                         }
//                                         return Padding(
//                                           padding: const EdgeInsets.all(8.0),
//                                           child: Slidable(
//                                             actionPane:
//                                                 SlidableDrawerActionPane(),
//                                             actionExtentRatio: 0.25,
//                                             secondaryActions: <Widget>[
//                                               IconSlideAction(
//                                                 caption: 'Block',
//                                                 color: ColorConstants
//                                                     .inputFieldColor,
//                                                 icon: Icons.block,
//                                                 onTap: () {
//                                                   print('Block');
//                                                   provider.blockUnblockContact(
//                                                       atSign:
//                                                           contactsForAlphabet[
//                                                                   index]
//                                                               .atSign,
//                                                       blockAction: true);
//                                                 },
//                                               ),
//                                               IconSlideAction(
//                                                 caption: 'Delete',
//                                                 color: Colors.red,
//                                                 icon: Icons.delete,
//                                                 onTap: () {
//                                                   provider.deleteAtsignContact(
//                                                       atSign:
//                                                           contactsForAlphabet[
//                                                                   index]
//                                                               .atSign);
//                                                 },
//                                               ),
//                                             ],
//                                             child: Container(
//                                               child: ListTile(
//                                                 title: Text(
//                                                   contactsForAlphabet[index]
//                                                                   .tags !=
//                                                               null &&
//                                                           contactsForAlphabet[
//                                                                           index]
//                                                                       .tags[
//                                                                   'name'] !=
//                                                               null
//                                                       ? contactsForAlphabet[
//                                                               index]
//                                                           .tags['name']
//                                                       : contactsForAlphabet[
//                                                               index]
//                                                           .atSign
//                                                           .substring(1),
//                                                   style: TextStyle(
//                                                     color: Colors.black,
//                                                     fontSize: 14.toFont,
//                                                   ),
//                                                 ),
//                                                 subtitle: Text(
//                                                   contactsForAlphabet[index]
//                                                       .atSign,
//                                                   style: TextStyle(
//                                                     color: ColorConstants
//                                                         .fadedText,
//                                                     fontSize: 14.toFont,
//                                                   ),
//                                                 ),
//                                                 leading: Container(
//                                                     height: 40.toWidth,
//                                                     width: 40.toWidth,
//                                                     decoration: BoxDecoration(
//                                                       color: Colors.black,
//                                                       shape: BoxShape.circle,
//                                                     ),
//                                                     child: contactImage),
//                                                 trailing: IconButton(
//                                                   onPressed: () {
//                                                     provider.contactList[index]
//                                                             .atSign =
//                                                         contactsForAlphabet[
//                                                                 index]
//                                                             .atSign
//                                                             .substring(1);
//                                                     provider.selectedAtsign =
//                                                         provider
//                                                             .contactList[index]
//                                                             .atSign;

//                                                     Navigator.of(context)
//                                                         .pushNamed(
//                                                       Routes.WELCOME_SCREEN,
//                                                     );
//                                                   },
//                                                   icon: Image.asset(
//                                                     ImageConstants.sendIcon,
//                                                     width: 21.toWidth,
//                                                     height: 18.toHeight,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         );
//                                       }),
//                                 ],
//                               ),
//                             );
//                           },
//                         );
//                 })
//           ],
//         ),
//       ),
//     );
//   }
// }
