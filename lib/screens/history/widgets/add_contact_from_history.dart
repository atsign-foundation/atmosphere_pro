/// This widgets pops up when a contact is added it takes [name]
/// [handle] to display the name and the handle of the user and an
/// onTap function named as [onYesTap] for on press of [Yes] button of the dialog

import 'package:atsign_atmosphere_app/screens/common_widgets/custom_button.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_app/utils/images.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:atsign_atmosphere_app/utils/text_styles.dart';
import 'package:atsign_atmosphere_app/view_models/contact_provider.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';

class AddHistoryContactDialog extends StatelessWidget {
  final String atSignName;
  final ContactProvider contactProvider;

  const AddHistoryContactDialog(
      {Key key, this.atSignName, this.contactProvider})
      : super(key: key);

  addtoContact(context) async {
    await contactProvider.addContact(atSign: atSignName);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderHandler<ContactProvider>(
      functionName: contactProvider.Contacts,
      errorBuilder: (provider) => Center(
        child: Text('Some error occured'),
      ),
      successBuilder: (provider) {
        return Container(
          height: 100,
          width: 100,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.toWidth)),
            titlePadding: EdgeInsets.only(
                top: 20.toHeight, left: 25.toWidth, right: 25.toWidth),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    TextStrings().addContactHeading,
                    textAlign: TextAlign.center,
                    style: CustomTextStyles.secondaryRegular16,
                  ),
                )
              ],
            ),
            content: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 190.toHeight),
              child: Column(
                children: [
                  SizedBox(
                    height: 21.toHeight,
                  ),
                  CustomCircleAvatar(
                    image: ImageConstants.imagePlaceholder,
                    size: 75,
                  ),
                  SizedBox(
                    height: 10.toHeight,
                  ),
                  Text(
                    atSignName.substring(1) ?? 'Levina Thomas',
                    style: CustomTextStyles.primaryBold16,
                  ),
                  SizedBox(
                    height: 2.toHeight,
                  ),
                  Text(
                    atSignName ?? '',
                    style: CustomTextStyles.secondaryRegular16,
                  ),
                ],
              ),
            ),
            actions: [
              CustomButton(
                buttonText: TextStrings().yes,
                onPressed: () => addtoContact(context),
              ),
              SizedBox(
                height: 10.toHeight,
              ),
              CustomButton(
                isInverted: true,
                buttonText: TextStrings().no,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
