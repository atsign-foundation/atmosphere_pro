import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_server_status/at_server_status.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/input_widget.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/add_contact_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/base_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class DesktopAddContactScreen extends StatefulWidget {
  final Function() onBack;

  const DesktopAddContactScreen({Key? key, required this.onBack})
      : super(key: key);

  @override
  State<DesktopAddContactScreen> createState() =>
      _DesktopAddContactScreenState();
}

enum CheckValid { idle, valid, inValid, loading }

class _DesktopAddContactScreenState extends State<DesktopAddContactScreen> {
  late TextEditingController atSignController;
  late TextEditingController nicknameController;
  late AddContactProvider addContactProvider, state;

  late AtStatus atStatus;
  final AtStatusImpl atStatusImpl = AtStatusImpl();

  var isValid = CheckValid.idle;

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
            width: double.infinity,
            decoration: BoxDecoration(
              color: ColorConstants.culturedColor,
              borderRadius: const BorderRadius.only(
                  // topLeft: Radius.circular(20),
                  // topRight: Radius.circular(20),
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
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          widget.onBack();
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 35,
                          ),
                          child: SvgPicture.asset(
                            AppVectors.icBack,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 30,
                          horizontal: 25,
                        ),
                        child: Text(
                          "Add New Contact",
                          style: TextStyle(
                            fontSize: 20.toFont,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
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
                                onchange: (value) async {
                                  await _checkValid(value);
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
                                child: isValid != CheckValid.idle
                                    ? isValid == CheckValid.loading
                                        ? const CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              ColorConstants.orange,
                                            ),
                                          )
                                        : Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text(
                                                isValid == CheckValid.valid
                                                    ? "atSign valid"
                                                    : "Invalid atSign",
                                                style: TextStyle(
                                                  fontSize: 14.toFont,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(
                                                isValid == CheckValid.valid
                                                    ? Icons
                                                        .check_circle_outlined
                                                    : Icons
                                                        .remove_circle_outline,
                                                size: 23,
                                                color:
                                                    isValid == CheckValid.valid
                                                        ? Colors.green
                                                        : Colors.red,
                                              )
                                            ],
                                          )
                                    : const SizedBox(),
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
                        if (isValid == CheckValid.valid &&
                            state.status['add_contact_status'] !=
                                Status.Loading) {
                          var response = await addContactProvider.addContact(
                            atSign: atSignController.text,
                            nickname: nicknameController.text,
                          );

                          if (response ?? false) {
                            widget.onBack();
                          }
                        }
                      },
                      child: Container(
                        height: 51.toHeight,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isValid != CheckValid.valid ||
                                  state.status['add_contact_status'] ==
                                      Status.Loading
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

  // Check if the atSign in valid
  _checkValid(String atSign) async {
    if (atSign.isEmpty) {
      setState(() {
        isValid = CheckValid.idle;
      });
    }

    try {
      setState(() {
        isValid = CheckValid.loading;
      });
      atStatus = await atStatusImpl.get(atSign);
      if (atSignController.text != atSign) {
        return;
      }
      if (atStatus.serverStatus == ServerStatus.activated) {
        isValid = CheckValid.valid;
      } else {
        isValid = CheckValid.inValid;
      }
      setState(() {
        isValid;
      });
    } catch (e) {
      print(e);
    }
  }
}
