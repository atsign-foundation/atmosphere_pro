import 'dart:typed_data';


/// This is a custom widget to display the selected contacts
/// in a row with overlapping profile pictures

import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_pro/screens/group_contacts_screen/widgets/group_contact_list_tile.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/welcome_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:provider/provider.dart';

class OverlappingContacts extends StatefulWidget {
  final List<GroupContactsModel?>? selectedList;
  final ValueChanged<bool>? onChnage;

  const OverlappingContacts({Key? key, this.selectedList, this.onChnage})
      : super(key: key);

  @override
  _OverlappingContactsState createState() => _OverlappingContactsState();
}

class _OverlappingContactsState extends State<OverlappingContacts> {
  bool isExpanded = false;
  Map _atsignImages = {};

  @override
  void initState() {
    for (var index = 0; index < widget.selectedList!.length; index++) {
      Uint8List? image;
      if (widget.selectedList![index]?.contact?.tags != null &&
          widget.selectedList![index]?.contact?.tags!['image'] != null) {
        image = CommonUtilityFunctions()
            .getContactImage(widget.selectedList![index]!.contact!);
      }
      _atsignImages[widget.selectedList![index]?.contact?.atSign] = image;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: Container(
        height: (isExpanded) ? 300.toHeight : 60.toHeight,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Color(0xffF7F7FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Stack(
              children: List<Positioned>.generate(
                (widget.selectedList!.length > 3)
                    ? 3
                    : widget.selectedList!.length,
                (index) {
                  Uint8List? image = _atsignImages[
                      widget.selectedList![index]?.contact?.atSign];

                  return Positioned(
                    left: 5 + double.parse((index * 10).toString()),
                    top: 5.toHeight,
                    child: Container(
                      height: 28.toHeight,
                      width: 28.toHeight,
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: (image != null)
                          ? CustomCircleAvatar(
                              byteImage: image,
                              nonAsset: true,
                            )
                          : ContactInitial(
                              initials: widget
                                      .selectedList![index]?.contact?.atSign ??
                                  widget.selectedList![index]?.group?.groupName,
                            ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 5.toHeight,
              left: 40 +
                  double.parse((widget.selectedList!.length * 25).toString()),
              child: Row(
                // mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  (widget.selectedList!.isEmpty)
                      ? Container()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: 160.toWidth,
                              child: Row(
                                children: [
                                  Container(
                                    width: 60.toWidth,
                                    child: Text(
                                      '${widget.selectedList![0]?.contact?.atSign ?? widget.selectedList![0]?.group?.groupName}',
                                      style:
                                          CustomTextStyles.secondaryRegular14,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    // width: 100.toWidth,
                                    child: Text(
                                      widget.selectedList!.length - 1 == 0
                                          ? ''
                                          : widget.selectedList!.length - 1 == 1
                                              ? ' and ${widget.selectedList!.length - 1} other'
                                              : ' and ${widget.selectedList!.length - 1} others',
                                      style:
                                          CustomTextStyles.secondaryRegular14,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 10.toWidth,
                      ),
                    ],
                  )
                ],
              ),
            ),
            Positioned(
              top: 10.toHeight,
              right: 0,
              child: Container(
                width: 20.toWidth,
                child: Icon(
                  (isExpanded)
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 15.toFont,
                ),
              ),
            ),
            (isExpanded)
                ? Consumer<WelcomeScreenProvider>(
                    builder: (context, provider, _) {
                      return Positioned(
                        top: 50.toHeight,
                        child: Container(
                          height: 200.toHeight,
                          width: SizeConfig().screenWidth - 60.toWidth,
                          child: ListView.builder(
                            itemCount: widget.selectedList!.length,
                            itemBuilder: (context, index) {
                              Uint8List? image = _atsignImages[
                                  widget.selectedList![index]?.contact?.atSign];

                              return ContactListTile(
                                isSelected: provider.selectedContacts
                                    .contains(provider.selectedContacts[index]),
                                onAdd: () {},
                                onRemove: () {
                                  provider.removeContacts(
                                      provider.selectedContacts[index]);
                                  widget.onChnage!(true);
                                },
                                name: provider
                                        .selectedContacts[index].contact?.atSign
                                        ?.substring(1) ??
                                    provider.selectedContacts[index].group
                                        ?.groupName
                                        ?.substring(0),
                                atSign: provider.selectedContacts[index].contact
                                        ?.atSign ??
                                    '${provider.selectedContacts[index].group?.members?.length.toString()} Members',
                                image: (image != null)
                                    ? CustomCircleAvatar(
                                        byteImage: image,
                                        nonAsset: true,
                                      )
                                    : ContactInitial(
                                        initials: provider
                                                .selectedContacts[index]
                                                .contact
                                                ?.atSign ??
                                            provider.selectedContacts[index]
                                                .group?.groupName,
                                      ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  )
                : Positioned(
                    top: 20.toHeight,
                    child: Container(),
                  )
          ],
        ),
      ),
    );
  }
}
