import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/input_widget.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/add_contact_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/base_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
          body: Container(
            margin: EdgeInsets.only(top: 60),
            width: double.infinity,
            decoration: BoxDecoration(
              color: ColorConstants.culturedColor,
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
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: 31, top: 36),
                      child: SvgPicture.asset(
                        AppVectors.icBack,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 38,
                    ),
                    child: Text(
                      "Add New Contact",
                      style: TextStyle(
                        fontSize: 20.toFont,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 23),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InputWidget(
                                hintText: 'Enter atSign',
                                controller: atSignController,
                                prefixText: "@",
                                prefixStyle: TextStyle(
                                  fontSize: 14.toFont,
                                  color: Colors.black,
                                ),
                                onSubmitted: (value) async {
                                  await state.checkValid(atSignController.text);
                                },
                              ),
                              Visibility(
                                visible: state.atSignError.isNotEmpty,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    state.atSignError,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12.toFont,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              InputWidget(
                                hintText: 'Enter nickname',
                                controller: nicknameController,
                                onSubmitted: (value) async {
                                  await state.checkValid(atSignController.text);
                                },
                              ),
                              const SizedBox(height: 30),
                              Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  color: ColorConstants.lightGray,
                                ),
                              ),
                              const SizedBox(height: 28),
                              Align(
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      "atSign valid",
                                      style: TextStyle(
                                        fontSize: 14.toFont,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.check_circle_outlined,
                                      size: 23,
                                      color: state.isVerify
                                          ? Colors.green
                                          : Colors.black,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        state.status['add_contact_status'] == Status.Loading
                            ? AbsorbPointer(
                                child: SizedBox(
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        ColorConstants.orange,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(27, 0, 27, 16),
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
                        height: 51.toHeight,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: !state.isVerify
                              ? ColorConstants.buttonGrey
                              : Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            "Add Contact",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.toFont,
                              fontWeight: FontWeight.bold,
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
}
