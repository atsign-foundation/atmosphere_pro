import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/app_bar.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/common_button.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/side_bar.dart';
import 'package:atsign_atmosphere_pro/screens/welcome_screen/widgets/overlapping_contacts.dart';
import 'package:atsign_atmosphere_pro/screens/welcome_screen/widgets/select_file_widget.dart';
import 'package:atsign_atmosphere_pro/services/backend_service.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_strings.dart';
import 'package:atsign_atmosphere_pro/view_models/file_picker_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/welcome_screen_view_model.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../view_models/file_picker_provider.dart';
import 'widgets/select_contact_widget.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isContactSelected;
  bool isFileSelected;
  // ContactProvider contactProvider;
  WelcomeScreenProvider _welcomeScreenProvider;
  Flushbar sendingFlushbar;
  BackendService backendService = BackendService.getInstance();
  HistoryProvider historyProvider;
  List<AtContact> selectedList = [];
  // FilePickerProvider _filePickerProvider;
  // 0-Sending, 1-Success, 2-Error
  List<Widget> transferStatus = [
    SizedBox(),
    Icon(
      Icons.check_circle,
      size: 13.toFont,
      color: ColorConstants.successColor,
    ),
    Icon(
      Icons.cancel,
      size: 13.toFont,
      color: ColorConstants.redText,
    )
  ];
  List<String> transferMessages = [
    'Sending file ...',
    'Sent the file',
    'Oops! something went wrong'
  ];
  String currentAtSign;
  @override
  void initState() {
    isContactSelected = false;
    isFileSelected = false;
    backendService.onboard();
    setAtSign();
    _welcomeScreenProvider = WelcomeScreenProvider();

    super.initState();
  }

  setAtSign() async {
    currentAtSign = await backendService.getAtSign();
    await getAtSignAndInitializeContacts();
    await initGroups();
    setState(() {});
  }

  initGroups() async {
    await GroupService().init(await BackendService.getInstance().getAtSign());
    await GroupService().fetchGroupsAndContacts();
  }

  getAtSignAndInitializeContacts() async {
    await initializeContactsService(
        backendService.atClientServiceInstance.atClient, currentAtSign,
        rootDomain: MixedConstants.ROOT_DOMAIN);
  }

  _showScaffold({int status = 0}) {
    return Flushbar(
      title: transferMessages[status],
      message: 'hello',
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      backgroundColor: ColorConstants.scaffoldColor,
      boxShadows: [
        BoxShadow(
            color: Colors.black, offset: Offset(0.0, 2.0), blurRadius: 3.0)
      ],
      isDismissible: false,
      duration: Duration(seconds: 3),
      icon: Container(
        height: 40.toWidth,
        width: 40.toWidth,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(ImageConstants.imagePlaceholder),
              fit: BoxFit.cover),
          shape: BoxShape.circle,
        ),
      ),

      mainButton: FlatButton(
        onPressed: () {
          sendingFlushbar.dismiss();
        },
        child: Text(
          TextStrings().buttonDismiss,
          style: TextStyle(color: ColorConstants.fontPrimary),
        ),
      ),
      // showProgressIndicator: true,
      progressIndicatorBackgroundColor: Colors.blueGrey,
      titleText: Row(
        children: <Widget>[
          transferStatus[status],
          Padding(
            padding: EdgeInsets.only(
              left: 5.toWidth,
            ),
            child: Text(
              transferMessages[status],
              style: TextStyle(
                  color: ColorConstants.fadedText, fontSize: 10.toFont),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filePickerModel = Provider.of<FilePickerProvider>(context);

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: CustomAppBar(
          showLeadingicon: true,
        ),
        endDrawer: SideBarWidget(),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: 26.toWidth, vertical: 20.toHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TextStrings().welcomeUser(currentAtSign),
                  style: GoogleFonts.playfairDisplay(
                    textStyle: TextStyle(
                      fontSize: 28.toFont,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.toHeight,
                ),
                Text(
                  TextStrings().welcomeRecipient,
                  style: TextStyle(
                    color: ColorConstants.fadedText,
                    fontSize: 13.toFont,
                  ),
                ),
                SizedBox(
                  height: 67.toHeight,
                ),
                Text(
                  TextStrings().welcomeSendFilesTo,
                  style: TextStyle(
                    color: ColorConstants.fadedText,
                    fontSize: 12.toFont,
                  ),
                ),
                SizedBox(
                  height: 20.toHeight,
                ),
                SelectContactWidget(
                  (b) {
                    setState(() {
                      isContactSelected = b;
                    });
                  },
                ),
                SizedBox(
                  height: 10.toHeight,
                ),
                // ProviderHandler<WelcomeScreenProvider>(),
                Consumer<WelcomeScreenProvider>(
                  builder: (context, provider, _) =>
                      (provider.selectedContacts.isEmpty)
                          ? Container()
                          : OverlappingContacts(
                              selectedList: provider.selectedContacts),
                ),
                SizedBox(
                  height: 40.toHeight,
                ),
                SelectFileWidget(
                  (b) {
                    setState(() {
                      isFileSelected = b;
                    });
                  },
                ),
                SizedBox(
                  height: 60.toHeight,
                ),
                if (_welcomeScreenProvider.selectedContacts != null &&
                    filePickerModel.selectedFiles.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.topRight,
                    child: CommonButton(
                      TextStrings().buttonSend,
                      () async {
                        filePickerModel.sendFiles(filePickerModel.selectedFiles,
                            _welcomeScreenProvider.selectedContacts);
                        // _showScaffold(status: 0);
                        // filePickerModel.sendFiles(filePickerModel.selectedFiles,
                        //     _welcomeScreenProvider.selectedContacts);
                        // bool response = filePickerModel.sentStatus[0];
                        // if (filePickerModel.sentStatus != null) {
                        sendingFlushbar = _showScaffold(status: 0);
                        await sendingFlushbar.show(context);
                        // }

                        _showScaffold(status: 0);
                        // filePickerModel.sendFiles(filePickerModel.selectedFiles,
                        //     _welcomeScreenProvider.selectedContacts);

                        bool response;

                        response = Provider.of<FilePickerProvider>(context,
                                listen: false)
                            .sentStatus;

                        // bool response = true;
                        // bool response = await backendService.sendFile(
                        //     contactPickerModel.selectedContacts,
                        //     filePickerModel.selectedFiles[0].path);

                        // Provider.of<HistoryProvider>(context, listen: false)
                        //     .setFilesHistory(
                        //         atSignName: _filePickerProvider
                        //             .temporaryContactList[0].atSign,
                        //         historyType: HistoryType.send,
                        //         files: [
                        //       FilesDetail(
                        //           filePath:
                        //               filePickerModel.selectedFiles[0].path,
                        //           size: filePickerModel.totalSize,
                        //           fileName: filePickerModel.result.files[0].name
                        //               .toString(),
                        //           type: filePickerModel
                        //               .selectedFiles[0].extension
                        //               .toString())
                        //     ]);

                        // _showScaffold(status: 1);
                        if (response != null && response == true) {
                          sendingFlushbar = _showScaffold(status: 1);
                          await sendingFlushbar.show(context);
                        } else {
                          _showScaffold(status: 2);
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    height: 60.toHeight,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
