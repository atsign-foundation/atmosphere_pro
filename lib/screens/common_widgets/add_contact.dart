import 'dart:io';
import 'dart:typed_data';

import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_common_flutter/widgets/custom_button.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';

import 'contact_initial.dart';

class AddContact extends StatefulWidget {
  final String? atSignName, name;
  final Uint8List? image;

  const AddContact({Key? key, this.atSignName, this.name, this.image})
      : super(key: key);

  @override
  State<AddContact> createState() => _AddContactState();
}

class _AddContactState extends State<AddContact> {
  bool isContactAdding = false;
  String? nickName;

  @override
  Widget build(BuildContext context) {
    final isKeyBoard = MediaQuery.of(context).viewInsets.bottom != 0;

    return SizedBox(
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
                'Add ${widget.atSignName} to contacts ?',
                textAlign: TextAlign.center,
                style: CustomTextStyles.primaryRegular16,
              ),
            )
          ],
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: (widget.name != null) ? 190.toHeight : 150.toHeight,
          ),
          child: Column(
            children: [
              if (!isKeyBoard)
                SizedBox(
                  height: 21.toHeight,
                ),
              widget.image != null
                  ? CustomCircleAvatar(
                      nonAsset: true,
                      byteImage: widget.image,
                      size: 75,
                    )
                  : ContactInitial(
                      initials: widget.atSignName,
                      size: 50,
                    ),
              SizedBox(
                height: 10.toHeight,
              ),
              (widget.name != null)
                  ? Text(
                      widget.name!,
                      style: CustomTextStyles.primaryBold16,
                    )
                  : const SizedBox(),
              SizedBox(
                height: (widget.name != null) ? 2.toHeight : 0,
              ),
              Text(
                (widget.atSignName ?? ''),
                style: CustomTextStyles.primaryRegular16,
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.only(left: 20, right: 20),
        actions: [
          TextFormField(
            autofocus: true,
            onChanged: (value) {
              nickName = value;
            },
            decoration: const InputDecoration(
              hintText: 'Enter nickname (optional)',
            ),
            style: TextStyle(
              fontSize: 15.toFont,
              fontWeight: FontWeight.normal,
            ),
          ),
          SizedBox(
            height: 10.toHeight,
          ),
          isContactAdding
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ColorConstants.orange,
                    ),
                  ),
                )
              : Container(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: (Platform.isAndroid || Platform.isIOS)
                        ? SizeConfig().screenWidth
                        : 150.toWidth,
                    child: CustomButton(
                      buttonText: 'Yes',
                      fontColor: Colors.white,
                      onPressed: () async {
                        setState(() {
                          isContactAdding = true;
                        });
                        await ContactService().addAtSign(
                          atSign: widget.atSignName,
                          nickName: nickName,
                        );
                        setState(() {
                          isContactAdding = false;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
          SizedBox(
            height: 10.toHeight,
          ),
          isContactAdding
              ? const SizedBox()
              : Container(
                  alignment: Alignment.center,
                  child: SizedBox(
                      width: (Platform.isAndroid || Platform.isIOS)
                          ? SizeConfig().screenWidth
                          : 150.toWidth,
                      child: CustomButton(
                        buttonColor: Colors.white,
                        buttonText: 'No',
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )),
                ),
        ],
      ),
    );
  }
}
