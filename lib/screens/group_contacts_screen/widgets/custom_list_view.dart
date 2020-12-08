import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_app/screens/group_contacts_screen/widgets/group_contact_list_tile.dart';
import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/view_models/contact_provider.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:provider/provider.dart';

class CustomListView extends StatefulWidget {
  final List<AtContact> contactList;
  final bool isTrustedContact;
  final List<AtContact> secondaryList;
  final bool plainView;

  const CustomListView(
      {Key key,
      this.contactList,
      this.isTrustedContact = false,
      this.secondaryList,
      this.plainView = false})
      : super(key: key);

  @override
  _CustomListViewState createState() => _CustomListViewState();
}

class _CustomListViewState extends State<CustomListView> {
  ContactProvider _contactProvider;
  @override
  void initState() {
    _contactProvider = Provider.of(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600.toHeight,
      child: ListView.separated(
        separatorBuilder: (context, _) => Divider(
          color: ColorConstants.dividerColor.withOpacity(0.2),
          height: 1.toHeight,
        ),
        padding: EdgeInsets.only(
            bottom: widget.secondaryList.isEmpty ? 0 : 190.toHeight),
        scrollDirection: Axis.vertical,
        itemCount: widget.contactList.length,
        itemBuilder: (context, index) {
          return Consumer<ContactProvider>(
            builder: (context, provider, _) {
              print(
                  'widget.contactList[index]====>${widget.contactList[index]}=====>${provider.trustedContacts.contains(widget.contactList[index])}');
              return ContactListTile(
                isSelected: (widget.isTrustedContact)
                    ? widget.secondaryList.contains(provider.contactList[index])
                    : widget.secondaryList
                        .contains(provider.contactList[index]),
                onAdd: () {
                  (widget.isTrustedContact)
                      ? provider.addTrustedContacts(widget.contactList[index])
                      : provider.selectContacts(widget.contactList[index]);
                },
                onRemove: () {
                  (widget.isTrustedContact)
                      ? provider
                          .removeTrustedContacts(widget.contactList[index])
                      : provider.removeContacts(widget.contactList[index]);
                },
                name: widget.contactList[index].tags != null &&
                        widget.contactList[index].tags['name'] != null
                    ? widget.contactList[index].tags['name']
                    : widget.contactList[index].atSign.substring(1),
                atSign: widget.contactList[index].atSign,
                image: (widget.contactList[index].tags != null &&
                        widget.contactList[index].tags['image'] != null)
                    ? CustomCircleAvatar(
                        byteImage: widget.contactList[index].tags['image'],
                        nonAsset: true,
                      )
                    : ContactInitial(
                        initials:
                            widget.contactList[index].atSign.substring(1, 3),
                      ),
              );
            },
          );
        },
      ),
    );
  }
}
