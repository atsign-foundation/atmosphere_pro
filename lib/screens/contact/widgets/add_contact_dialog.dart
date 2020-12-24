import 'package:atsign_atmosphere_app/screens/common_widgets/custom_button.dart';

/// This widgets pops up when a contact is added it takes [name]
/// [handle] to display the name and the handle of the user and an
/// onTap function named as [onYesTap] for on press of [Yes] button of the dialog
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/services/validators.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:atsign_atmosphere_app/utils/text_styles.dart';
import 'package:atsign_atmosphere_app/view_models/contact_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddContactDialog extends StatelessWidget {
  final String name;
  final String handle;
  final Function(String) onYesTap;
  final formKey;
  String atsignName = '';
  AddContactDialog({
    Key key,
    this.name,
    this.handle,
    this.onYesTap,
    this.formKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double deviceTextFactor = MediaQuery.of(context).textScaleFactor;
    return Container(
      // height: 100.toHeight * deviceTextFactor,
      // width: 100.toWidth,
      child: SingleChildScrollView(
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
                  TextStrings().addContact,
                  textAlign: TextAlign.center,
                  style: CustomTextStyles.primaryBold18,
                ),
              )
            ],
          ),
          // content: ConstrainedBox(
          //   constraints: BoxConstraints(
          //       // maxHeight:
          //       //     (Provider.of<ContactProvider>(context).getAtSignError == ''
          //       //             ? 255.toHeight
          //       //             : 305.toHeight) *
          //       //         deviceTextFactor),
          //   child:  ),
          content: Column(
            children: [
              SizedBox(
                height: 20.toHeight,
              ),
              TextFormField(
                autofocus: true,
                onChanged: (value) {
                  atsignName = value;
                },
                validator: Validators.validateAdduser,
                decoration: InputDecoration(
                  prefixText: '@',
                  prefixStyle: TextStyle(color: Colors.grey),
                  hintText: '\tEnter user atsign',
                ),
              ),
              SizedBox(
                height: 10.toHeight,
              ),
              (Provider.of<ContactProvider>(context).getAtSignError == '')
                  ? Container()
                  : Row(
                      children: [
                        Expanded(
                          child: Text(
                            Provider.of<ContactProvider>(
                              context,
                            ).getAtSignError,
                            style: TextStyle(color: Colors.red),
                          ),
                        )
                      ],
                    ),
              SizedBox(
                height: 45.toHeight,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  (Provider.of<ContactProvider>(context).isLoading)
                      ? CircularProgressIndicator()
                      : CustomButton(
                          height: 50.toHeight * deviceTextFactor,
                          buttonText: TextStrings().addtoContact,
                          onPressed: () => onYesTap(atsignName),
                        )
                ],
              ),
              SizedBox(
                height: 20.toHeight,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                      height: 50.toHeight * deviceTextFactor,
                      isInverted: true,
                      buttonText: TextStrings().buttonCancel,
                      onPressed: () {
                        Provider.of<ContactProvider>(context, listen: false)
                            .getAtSignError = '';
                        Navigator.pop(context);
                      })
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
