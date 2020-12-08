import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_app/screens/group_contacts_screen/widgets/circular_contacts.dart';
import 'package:atsign_atmosphere_app/utils/images.dart';
import 'package:atsign_atmosphere_app/view_models/contact_provider.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:provider/provider.dart';

class HorizontalCircularList extends StatelessWidget {
  final List<AtContact> list;
  // final Function onTap;
  final bool isTrustedSender;
  const HorizontalCircularList({Key key, this.list, this.isTrustedSender})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('HORIZONTAL CIRCULAR======>$isTrustedSender');
    return Container(
      height: (list.isEmpty) ? 0 : 120.toHeight,
      child: ListView.builder(
        itemCount: list.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => CircularContacts(
          atSign: list[index].atSign,
          image: (list[index].tags != null && list[index].tags['image'] != null)
              ? CustomCircleAvatar(
                  byteImage: list[index].tags['image'],
                  nonAsset: true,
                )
              : ContactInitial(
                  initials: list[index].atSign.substring(1, 3),
                ),
          name: list[index].tags != null && list[index].tags['name'] != null
              ? list[index].tags['name']
              : list[index].atSign.substring(1),
          onCrossPressed: () {
            (isTrustedSender)
                ? Provider.of<ContactProvider>(context, listen: false)
                    .removeTrustedContacts(list[index])
                : Provider.of<ContactProvider>(context, listen: false)
                    .removeContacts(list[index]);
            // onTap();
          },
        ),
      ),
    );
  }
}
