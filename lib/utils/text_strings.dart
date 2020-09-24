class TextStrings {
  TextStrings._();
  static TextStrings _instance = TextStrings._();
  factory TextStrings() => _instance;

  // home screen texts
  String homeFileTransferItsSafe = 'File transfer.\nIt’s safe!';
  String homeHassleFree = 'Hassle free.\n';
  String homeWeWillSetupAccount = 'We will set up your account right away.';

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
  String sidebarFaqs = 'FAQ';
  String sidebarAutoAcceptFile = 'Auto Accept Files';
  String sidebarEnablingMessage =
      'Enabling this will auto accept all the files sent by your contacts.';
  String sidebarSwitchOut = 'Switch @sign';

  //FAQs texts
  String faqs = 'FAQ';

  //Contact texts
  String searchContact = 'Search Contact';
  String addContactSearch = 'Search @sign';
  String contactSearchResults = 'Search Results';
  String addContact = 'Add Contact';

  // buttons text
  String buttonStart = 'Start';
  String buttonSend = 'Send';
  String buttonClose = 'Close';
}
