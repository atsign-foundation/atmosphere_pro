import 'package:at_contacts_group_flutter/widgets/add_contacts_group_dialog.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';

class DesktopFloatingAddContactButton extends StatelessWidget {
  const DesktopFloatingAddContactButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 32,
      left: 48,
      right: 48,
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => const AddContactDialog(),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: Colors.black,
          ),
          alignment: Alignment.center,
          child: Text(
            'Add Contact',
            style: CustomTextStyles.whiteBold16,
          ),
        ),
      ),
    );
  }
}
