class TextStrings {
  TextStrings._();
  static TextStrings _instance = TextStrings._();
  factory TextStrings() => _instance;

  // home screen texts
  // String homeFileTransferItsSafe = 'File transfer.\nIt’s safe!';
  // String homeHassleFree = 'Hassle free.\n';
  // String homeWeWillSetupAccount = 'We will set up your account right away.';
  String homeDescriptionMobile = 'Truly\nencrypted file\ntransfer.';
  String homeDescriptionDesktop = 'Truly encrypted\nfile transfer.';
  String homeDescriptionSub = 'Private. Simple. Secure.';
  String appName = '@mospherePro';
  String copyRight = '© 2022 The @ Company';
  String homeFileTransferItsSafe = 'File transfer.\nIt’s safe!';
  String homeHassleFree = 'Hassle free.\n';
  String homeWeWillSetupAccount = 'We will set up your account right away.';
  String loggingIn = 'Logging in';

  // onboarding flow texts
  String saveKeyTitle = 'Save your Private Key';
  String importantTitle = 'IMPORTANT!';
  String saveKeyDescription =
      "Please save your private key. For security reasons, it's highly recommended to save it in GDrive/iCloudDrive.";
  String buttonSave = 'SAVE';
  String buttonContinue = 'CONTINUE';

  // welcome screen texts
  String welcomeUser(String userName) => 'Welcome\n $userName';
  String welcome = 'Welcome';
  String welcomeRecipient = 'Select a recipient and start sending them files.';
  String welcomeSendFilesTo = 'Send file(s) to';
  String welcomeContactPlaceholder = '@sign';
  String welcomeFilePlaceholder = 'Select file(s) to transfer';
  String welcomeAddFilePlaceholder = 'Add file(s) to transfer';
  String welcomeAddTranscripts = 'Add a note (Optional)';
  String sendingFiles = 'Sending file ...';
  String oopsSomethingWentWrong = 'Oops! something went wrong';
  String hello = 'hello';
  String reset = 'Reset';

  //sidebar menu texts
  String sidebarHome = 'Home';
  String sidebarContact = 'Contacts';
  String sidebarTransferHistory = 'Transfer History';
  String sidebarBlockedUser = 'Blocked @signs';
  String sidebarMyFiles = 'My Files';
  String sidebarTrustedSenders = 'Trusted Senders';
  String sidebarMyGroups = 'My Groups';
  String sidebarBackupKey = 'Backup Your keys';
  String sidebarTermsAndConditions = 'Terms and Conditions';
  String sidebarPrivacyPolicy = "Privacy Policy";
  String sidebarFaqs = 'FAQ';
  String sidebarAutoAcceptFile = 'Auto-Accept Files';
  String sidebarEnablingMessage =
      'Enabling this will auto-accept all the files sent by your contacts.';
  String sidebarSwitchOut = 'Switch @sign';
  String sidebarDeleteAtsign = 'Delete @sign(s)';

  String atSign = '@sign';
  String switchingAtSign = 'Switching atsign...';
  String deleteDataMessage =
      'Are you sure you want to delete all data associated with';
  String typeAtsignAbove = 'Type the @sign above to proceed';
  String actionCannotUndone = "Caution: this action can't be undone";
  //FAQs texts
  String faqs = 'FAQ';

  //Contact texts
  String searchContact = 'Search Contacts';
  String addContactSearch = 'Search @sign';
  String contactSearchResults = 'Search Results';
  String addContact = 'Add Contact';
  String addtoContact = 'Add to Contacts';
  // buttons text
  String buttonStart = 'Start';
  String buttonSend = 'Send';
  String buttonClose = 'Close';
  String buttonResend = 'Resend';

  String accept = 'Accept';
  String reject = 'Reject';
  String upload = 'Upload QR code image';
  String uploadKey = 'Upload key file';
  String buttonCancel = 'Cancel';
  String buttonDelete = 'DELETE';
  static final String buttonDismiss = 'DISMISS';
  static final String buttonShowMore = 'Show More';
  String ok = 'Ok';

  //history screen texts
  String sent = 'Sent';
  String received = 'Received';

  String showDetails = 'Show Details';
  String hideDetails = 'Hide Details';

  String seeFiles = 'See Files';
  String hideFiles = 'Hide Files';

  String history = 'History';
  String noFilesSent = 'No files sent';
  String noFilesRecieved = 'No files received';

  // sent file list tile texts
  String files = 'Files';
  String kb = 'Kb';
  String mb = 'Mb';
  String deliveredTo = 'Delivered to';

  // recieve file list tile texts
  String video = 'Video';

  //receive files texts
  String blockUser = 'Block User';
  String receiverNotification = 'Receivers Notification';
  String wantToSendFile = ' wants to send you a file?';

  //add contact texts
  String addContactHeading =
      'Are you sure you want to add this person to your contacts list?';
  String yes = 'Yes';
  String no = 'No';
  String add = 'Add';
  String done = 'Done';
  //my files
  String myFiles = 'My Files';
  String recents = 'Recents';
  String photos = 'Photos';
  String videos = 'Videos';
  String audio = 'Audio';
  String apk = 'APK';
  String documents = 'Documents';
  String openFileLocation = 'Open file location';

  // trusted sender screens
  String trustedSenders = 'Trusted Senders';
  String selectperson = 'Select Person';
  String noTrustedSenders = 'No Trusted Senders';
  String addTrustedSender =
      'Would you like to add people to your trusted senders list?';
  String removeTrustedSender =
      "Are you sure you want to remove this person from your trusted senders list?";
  String removeGroupMember =
      "Are you sure you want to remove this person from Group ?";

  // my groups
  String groups = 'Groups';
  String downloadAllFiles = 'Download all files';
  String downloadFailed = 'Download failed, please try again.';
  String fileDownloadd = 'File(s) downloaded';
  String noGroups = 'No Groups';
  String newGroup = 'New Group';
  String addGroups = 'Would you like to create a group';
  String create = 'Create';
  String groupName = 'Group Name';
  String enterGroupName = 'Enter group name';
  String removeGroup =
      'Are you sure you want to remove this contact(s) from this group?';
  String changeGroupPhoto = 'Change Group Photo';
  String removeGroupPhoto = 'Remove Group Photo';

  // terms and conditions texts
  String termsAppBar = 'Terms and Conditions';
  String termsAndConditions =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.\n\n Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. \n\n Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';

  // scan qr texts
  String scanQrTitle = 'Scan QR Code';
  String scanQrMessage = 'Just scan the QR Code displayed at my.atsign.com';
  String scanQrFooter = 'Don’t have an @sign? Get one now.';
  String websiteTitle = 'Atsign';

  //error texts
  String errorOccured = 'An Error Occurred';

  // File choice dialog texts
  String fileChoiceQuestion = 'What would you like to send?';
  String choice1 = 'Photos and Videos ';
  String choice2 = 'Other files';

  // history no file to open
  String noFileFound = 'Sorry, file not found';

  List<String> contactFields = [
    'firstname.persona',
    'lastname.persona',
    'image.persona',
  ];

  String unknownAtsign(String atSign) =>
      '$atSign is not found. Please check and try again.';
  String atsignExists(String atSign) => '$atSign already exists';
  String emptyAtsign = 'Please enter an @sign';

  // sort strings
  static const String SORT_NAME = 'Sort By Name';
  static const String SORT_DATE = 'Sort By Date';
  static const String SORT_SIZE = 'Sort By Size';

  // Flushbar messages
  String receivingFile = 'Receiving file(s)';
  String sendingFile = 'Sending file(s)';
  String fileReceived = 'File(s) received';
  String fileSent = 'File(s) sent';
  String expired = 'Expired';
  String fileSentSuccessfully = 'File(s) sent successfully';

  String selectFile = 'Select a File';

  // downloads folder text
  String atmosphereDownloadFolder = 'Atmosphere download folder';

  // private key qrcode generator
  String atsignRequired = 'An @sign is required.';

  // transfer overlapping
  String and = 'and';
  String other = 'other';
  String others = 'others';
  // desktop text constants
  String addNewAtsign = 'add_new_atsign';
  String saveBackupKey = 'save_backup_key';
  String contactSelectionConfirmation =
      'Selected contacts will not be added, confirm?';

  // Desktop Selected file
  String selectedFiles = 'Selected files';

  // Desktop download all files
  String recievedFileDownloadMsg =
      'All the files you have received will be downloaded in the folder you select.';
  String selectedDownloadFolder = 'Selected download folder: ';
  static const String selectDownloadFolder = 'Select download folder';
  String downloadingFiles = 'Downloading file(s)...';
  String downloadComplete = 'Download complete';
  String selectFolderToDownload = 'Select folder to download';
  String downloadInProgress = 'Download in progress';
  String failedToDownload = 'failed to download';
  String filesFrom = 'file(s) from';

  // Desktop recieved file detail
  String details = 'Details';
  String downloadsFolder = 'Downloads folder';
  String fileNamed = 'A file named ';
  String alreadyExistsMsg = ' already exists. Do you want to overwrite it?';
  String fileExists = 'These files already exist: ';
  String overWriteMsg = '\nDo you want to overwrite them?';

  // Desktop sent file details
  String successfullyTransfered = 'Successfully transfered';
  String file_s = 'File(s)';

  // Desktop transfer overlapping
  String downloadedBy = 'Downloaded by';
  String failedToSend = 'Failed to send to';
  String retry = 'Retry';

  // Desktop home
  String remove = 'Remove';
  String selectAll = 'Select All';
  String desktopAppName = '@mospherePro';
  String desktopCopyRight = 'The @company Copyrights';
  String enterAtSign = 'Enter @sign';
  String authenticating = 'Authenticating...';
  String initialisingFor = 'Initialising for ';
  String itsSafe = "It's safe!";
  String fileTransfer = 'File transfer.';
  String easyFileSharing = 'Simple file sharing';
  String shareAnyFiles = 'Share any file type unmodified';
  String fastAndSecure = 'fast and secure across your contacts';
  String shareWithGroup = 'Share with groups';
  String createGroupAndTransferFile = 'Create groups and transfer files to';
  String allMembers = 'all group members';
  String trustedContacts = 'Trusted Contacts';
  String customiseFiles = 'Customize contacts and receive files';
  String fromTrustedSenders = 'from trusted contacts';

  // Desktop apk
  String noFilesFound = 'No file found';

  // Desktop Welcome screen
  String error = 'Error';

  // Desktop trusted senders
  String somethingWentWrong = 'Something went wrong.';
  String search = 'Search...';
  String sortBy = 'Sort by';
  String byName = 'By name';
  String byDate = 'By date';
  String apply = 'Apply';

  String downloading = 'Downloading';

  // Error Message

  String unableToPerform = 'Unable to perform this action. Please try again.';
  String unableToAuthenticate = 'Unable to authenticate. Please try again.';
  String failedInProcessing = 'Failed in processing. Please try again.';
  String unableToConnectServer =
      'Unable to connect server. Please try again later.';
  String unableToPerformRead_Write =
      'Unable to perform read/write operation. Please try again.';
  String unableToActivateServer =
      'Unable to activate server. Please contact admin.';
  String serverIsUnavailable = 'Server is unavailable. Please try again later.';
  String unableToConnect =
      'Unable to connect. Please check with network connection and try again.';
  String invalidAtSign = 'Invalid atsign is provided. Please contact admin.';
  String unknownError = 'Unknown error.';

  // Backend Service
  String syncFailed = 'Sync Failed.';

  // Common Utility Functions
  String deleteAtSign = 'Delete @sign';
  String atSignDoesNotMatch = "The @sign doesn't match. Please retype.";

  // Version Service
  String updateAppMsg = 'You can update this app from';
  String update = 'Update';
  String mayBeLater = 'Maybe later';
  String to = 'to';

  static final String resetButton = 'Reset';
  static const String resetDescription =
      'This will remove the selected @sign and its details from this app only.';
  static const String noAtsignToReset =
      'There are no @signs paired with this device. ';
  static const String resetErrorText =
      'Please select at least one @sign to reset';
  static const String resetWarningText =
      'Warning: This action cannot be undone!';
  static const String noInternet =
      'Offline. Please check your internet connection and try again.';
  static const uploaded = 'Uploaded';
  static const reUploadFileMsg = 'Do you want to re-upload file ?';
  static const uploadFile = 'Please upload file first.';
  static const deleteFileConfirmationMsg = 'Are you sure to delete this item ?';
  static const delete = 'Delete';
  static const fileSizeLimit = 'File size can not exceed 50 Mb.';
  static const releaseTagError = 'Error in fetching release tag.';
  static const upgradeDialogShowError =
      'Error in showing app upgrade dialog box.';
  static const appVersionFetchError =
      'Could not fetch latest app version details.';
  static const noInternetMsg = 'No internet available';
  static const permissionRequireMessage =
      'This action cannot be completed because the app does not have permission to access the required items. Please change the app permission settings to continue.';
}
