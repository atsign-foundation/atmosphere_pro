import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:at_contacts_group_flutter/widgets/confirmation_dialog.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/contacts_screen/widgets/options_icon_button.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_pro/services/snackbar_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class InformationCardExpanded extends StatefulWidget {
  final AtContact atContact;
  final Function() onBack;

  const InformationCardExpanded({
    Key? key,
    required this.atContact,
    required this.onBack,
  });

  @override
  State<InformationCardExpanded> createState() =>
      _InformationCardExpandedState();
}

class _InformationCardExpandedState extends State<InformationCardExpanded> {
  late TrustedContactProvider trustedContactProvider;
  late TextEditingController controller;
  late ContactService contactService;
  bool isTrusted = false;
  bool isEdit = false;
  bool isLoading = false;
  bool isBlocked = false;

  @override
  void initState() {
    trustedContactProvider = TrustedContactProvider();
    controller =
        TextEditingController(text: widget.atContact.tags?['nickname'] ?? '');
    contactService = ContactService();
    getContactState();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant InformationCardExpanded oldWidget) {
    controller =
        TextEditingController(text: widget.atContact.tags?['nickname'] ?? '');
    contactService = ContactService();
    getContactState();
    super.didUpdateWidget(oldWidget);
  }

  void getContactState() {
    isTrusted = false;
    trustedContactProvider.trustedContacts.forEach((element) {
      if (element.atSign == widget.atContact.atSign) {
        setState(() {
          isTrusted = true;
        });
      }
    });
    setState(() {
      isBlocked = widget.atContact.blocked ?? false;
    });
  }

  Future<void> editNickname() async {
    setState(() {
      isLoading = true;
    });
    AtContact contact = widget.atContact;
    contact.tags = await contactService.getContactDetails(contact.atSign, null);
    contact.tags!['nickname'] = controller.text;
    var res = await ContactService().atContactImpl.add(contact);
    if (res == true) {
      await SnackBarService()
          .showSnackBar(context, "Successfully updated nickname");
    } else {
      await SnackBarService()
          .showSnackBar(context, "Failed to update nickname");
    }
    setState(() {
      isLoading = false;
      isEdit = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 40, horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildAppBarRow(),
            SizedBox(height: 20),
            buildOptionsRow(),
            SizedBox(height: 20),
            buildTransferFileButton(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget buildAppBarRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: widget.onBack,
          child: SvgPicture.asset(
            AppVectors.icBack,
            height: 24,
            width: 24,
          ),
        ),
        Center(
          child: buildInfoWidget(),
        ),
      ],
    );
  }

  Widget buildInfoWidget() {
    return SizedBox(
      width: 204,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          widget.atContact.tags?['image'] != null
              ? CustomCircleAvatar(
                  byteImage: Uint8List.fromList(
                      widget.atContact.tags!['image'].cast<int>()),
                  nonAsset: true,
                  size: 100,
                )
              : ContactInitial(
                  initials: widget.atContact.atSign,
                  size: 100,
                ),
          isEdit
              ? buildEditNickNameField()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 4),
                    Text(
                      widget.atContact.tags?['nickname'] ??
                          widget.atContact.atSign?.substring(1),
                      style: CustomTextStyles.desktopPrimaryRegular18,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.atContact.atSign ?? '',
                      style: CustomTextStyles.desktopPrimaryW400S14,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                ),
        ],
      ),
    );
  }

  Widget buildOptionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OptionsIconButton(
          isSelected: isTrusted,
          onTap: () async {
            isTrusted
                ? await trustedContactProvider
                    .removeTrustedContacts(widget.atContact)
                : await trustedContactProvider
                    .addTrustedContacts(widget.atContact);
            setState(() {
              isTrusted = !isTrusted;
            });
          },
          icon: AppVectors.icTrust,
        ),
        SizedBox(width: 20),
        OptionsIconButton(
          isSelected: isEdit,
          onTap: () {
            setState(() {
              isEdit = !isEdit;
            });
          },
          icon: AppVectors.icEdit,
        ),
        SizedBox(width: 20),
        OptionsIconButton(
          onTap: () async {
            await showConfirmationDialog(
              action: 'delete',
              onYesPressed: () async {
                var res = await contactService.deleteAtSign(
                  atSign: widget.atContact.atSign!,
                );

                if (res) {
                  widget.onBack();
                }
              },
            );
          },
          icon: AppVectors.icDelete,
        ),
        SizedBox(width: 20),
        OptionsIconButton(
          isSelected: isBlocked,
          onTap: () async {
            await showConfirmationDialog(
              action: 'block',
              onYesPressed: () async {
                await contactService
                    .blockUnblockContact(
                      contact: widget.atContact,
                      blockAction: !isBlocked,
                    )
                    .then(
                      (value) => setState(() {
                        isBlocked = !isBlocked;
                      }),
                    );
              },
            );
          },
          icon: AppVectors.icBlock,
        ),
      ],
    );
  }

  Widget buildTransferFileButton() {
    return InkWell(
      onTap: () async {
        Provider.of<FileTransferProvider>(context, listen: false)
            .selectedContacts = [
          GroupContactsModel(
              contact: widget.atContact, contactType: ContactsType.CONTACT),
        ];
        Provider.of<FileTransferProvider>(context, listen: false).notify();
        await DesktopSetupRoutes.nested_pop();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: ColorConstants.raisinBlack,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Transfer File',
              style: CustomTextStyles.whiteBoldS12,
            ),
            SizedBox(width: 8),
            SvgPicture.asset(
              AppVectors.icArrow,
              width: 16,
              height: 12,
              fit: BoxFit.fitWidth,
            )
          ],
        ),
      ),
    );
  }

  Widget buildAttachmentsTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attachments',
          style: CustomTextStyles.desktopPrimaryW500S15,
        ),
        Text(
          'Files ${widget.atContact.atSign} has sent you',
          style: CustomTextStyles.oldSliverW400S10,
        )
      ],
    );
  }

  Widget buildEditNickNameField() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 8),
        TextField(
          controller: controller,
          style: CustomTextStyles.desktopPrimaryRegular14,
          cursorColor: Colors.black,
          decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffix: InkWell(
              onTap: () {
                controller.clear();
              },
              child: SvgPicture.asset(
                AppVectors.icCancel,
                width: 8,
                height: 8,
                color: Colors.black,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(height: 12),
        InkWell(
          onTap: () async {
            if (!isLoading) {
              await editNickname();
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.black,
            ),
            child: isLoading
                ? SizedBox(
                    height: 12,
                    width: 12,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : Text(
                    'Save',
                    style: CustomTextStyles.whiteBoldS12,
                  ),
          ),
        )
      ],
    );
  }

  Future<void> showConfirmationDialog({
    required String action,
    required Function() onYesPressed,
  }) async {
    await showDialog(
      context: context,
      builder: (context) {
        Uint8List? image;
        if (widget.atContact.tags?['image'] != null) {
          List<int> intList = widget.atContact.tags?['image'].cast<int>();
          image = Uint8List.fromList(intList);
        }
        return ConfirmationDialog(
          title: '${widget.atContact.atSign}',
          heading: 'Are you sure you want to $action this contact?',
          onYesPressed: onYesPressed,
          image: image,
        );
      },
    );
  }
}
