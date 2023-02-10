import 'package:atsign_atmosphere_pro/screens/common_widgets/gradient_text_field_widget.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/view_models/add_contact_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/base_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({Key? key}) : super(key: key);

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  late TextEditingController atSignController;
  late TextEditingController nicknameController;
  late AddContactProvider addContactProvider, state;

  @override
  void initState() {
    addContactProvider = context.read<AddContactProvider>();
    atSignController = TextEditingController();
    nicknameController = TextEditingController();
    super.initState();
    addContactProvider.initData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddContactProvider>(
      builder: (_c, provider, _) {
        state = context.watch<AddContactProvider>();
        return Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(top: 120),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    height: 2,
                    width: 45,
                    margin: const EdgeInsets.only(left: 27, top: 38),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 27),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Add Contact",
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 53),
                              GradientTextFieldWidget(
                                hintText: 'Enter atSign',
                                controller: atSignController,
                                prefixText: "@",
                                prefixStyle: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                                onSubmitted: (value) {
                                  _checkValid();
                                },
                              ),
                              Visibility(
                                visible: state.atSignError.isNotEmpty,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    state.atSignError,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              GradientTextFieldWidget(
                                hintText: 'Enter nickname',
                                controller: nicknameController,
                                onSubmitted: (value) {
                                  _checkValid();
                                },
                              ),
                              const SizedBox(height: 44),
                              Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  color: ColorConstants.darkGray,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  const Text(
                                    "atSign verified",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xffCACACA),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Icon(
                                    Icons.check_circle_outlined,
                                    color: state.isVerify
                                        ? Colors.green
                                        : ColorConstants.darkGray,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        state.status['add_contact_status'] == Status.Loading
                            ? Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    ColorConstants.orange,
                                  ),
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(27, 0, 27, 40),
                      child: InkWell(
                        onTap: () async {
                          if (addContactProvider.isVerify) {
                            var response = await addContactProvider.addContact(
                              atSign: atSignController.text,
                              nickname: nicknameController.text,
                            );

                            if (response ?? false) {
                              Navigator.of(context).pop(true);
                            }
                          }
                        },
                        child: Container(
                          height: 60,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              "Create New Contact",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _checkValid() {
    if (atSignController.text.isNotEmpty &&
        nicknameController.text.isNotEmpty) {
      addContactProvider.changeVerifyStatus(true);
    } else {
      addContactProvider.changeVerifyStatus(false);
    }
  }
}
