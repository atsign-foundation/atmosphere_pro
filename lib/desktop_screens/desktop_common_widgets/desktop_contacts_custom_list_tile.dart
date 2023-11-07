import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';

class DesktopContactsCustomListTile extends StatelessWidget {
  const DesktopContactsCustomListTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Text(
          '@levina',
          style: CustomTextStyles.desktopPrimaryRegular18,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      subtitle: Text(
        '@levina',
        style: CustomTextStyles.secondaryRegular16,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      leading: Container(
          height: 50,
          width: 50,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          child: const ContactInitial(
            initials: 'Levina',
            size: 30,
            maxSize: (80.0 - 30.0),
            minSize: 50,
          )),
      trailing: IconButton(
        onPressed: () {},
        icon: const Icon(Icons.add),
      ),
    );
  }
}
