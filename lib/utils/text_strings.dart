class TextStrings {
  TextStrings._();
  static TextStrings _instance = TextStrings._();
  factory TextStrings() => _instance;

  // home screen texts
  String homeFileTransferItsSafe = 'File transfer.\nIt’s safe!';
  String homeHassleFree = 'Hassle free.\n';
  String homeWeWillSetupAccount = 'We will set up your account right away.';

  // onboarding flow texts
  String saveKeyTitle = 'Save your Private Key';
  String importantTitle = 'IMPORTANT!';
  String saveKeyDescription =
      "Please save your private key. For security reasons, it's highly recommended to save it in GDrive/iCloudDrive.";
  String buttonSave = 'SAVE';
  String buttonContinue = 'CONTINUE';

  // welcome screen texts
  String welcomeUser(String userName) => 'Welcome\n $userName!';
  String welcomeRecipient = 'Select a recipient and start sending them files.';
  String welcomeSendFilesTo = 'Send file to';
  String welcomeContactPlaceholder = '@sign';
  String welcomeFilePlaceholder = 'Select file to transfer';
  String welcomeAddFilePlaceholder = 'Add file to transfer';

  //sidebar menu texts
  String sidebarContact = 'Contact';
  String sidebarTransferHistory = 'Transfer History';
  String sidebarBlockedUser = 'Blocked User';
  String sidebarTermsAndConditions = 'Terms and Conditions';
  String sidebarPrivacyPolicy = "Privacy policy";
  String sidebarFaqs = 'FAQ';
  String sidebarAutoAcceptFile = 'Auto Accept Files';
  String sidebarEnablingMessage =
      'Enabling this will auto accept all the files sent by your contacts.';
  String sidebarSwitchOut = 'Switch @sign';
  String sidebarDeleteAtsign = 'Delete @sign';

  //FAQs texts
  String faqs = 'FAQ';

  //Contact texts
  String searchContact = 'Search Contact';
  String addContactSearch = 'Search @sign';
  String contactSearchResults = 'Search Results';
  String addContact = 'Add Contact';
  String addtoContact = 'Add to Contact';
  // buttons text
  String buttonStart = 'Start';
  String buttonSend = 'Send';
  String buttonClose = 'Close';
  String accept = 'Accept';
  String reject = 'Reject';
  String upload = 'Upload QR code image';
  String uploadKey = 'Upload key file';
  String buttonCancel = 'CANCEL';
  String buttonDelete = 'DELETE';
  String buttonDismiss = 'DISMISS';

  //history screen texts
  String sent = 'Sent';
  String received = 'Received';
  String moreDetails = 'More Details';
  String lesserDetails = 'Lesser Details';

  //receive files texts
  String blockUser = 'Block User';

  //add contact texts
  String addContactHeading =
      'Are you sure you want to add the user to your contact list?';
  String yes = 'Yes';
  String no = 'No';

  // terms and conditions texts
  String termsAppBar = 'Terms and Conditions';
  String termsAndConditions =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.\n\n Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. \n\n Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';

  // scan qr texts
  String scanQrTitle = 'Scan QR Code';
  String scanQrMessage = 'Just scan the QR code displayed at www.atsign.com';
  String scanQrFooter = 'Don’t have an @sign? Get now.';
  String websiteTitle = 'Atsign';

  //error texts
  String errorOccured = 'Some Error occured';

  // File choice dialog texts
  String fileChoiceQuestion = 'What would you like to send?';
  String choice1 = 'Photos';
  String choice2 = 'Other files';

  // history no file to open
  String noFileFound = 'Sorry, unable to open this file';

  List<String> contactFields = [
    'firstname.persona',
    'lastname.persona',
    'image.persona',
  ];

  String unknownAtsign(String atSign) =>
      '$atSign is not found. Please check and try again.';
  String atsignExists(String atSign) => '$atSign already exists';
  String emptyAtsign = 'Please type in an atsign';
}
