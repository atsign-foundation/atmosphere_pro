class TextStrings {
  TextStrings._();
  static TextStrings _instance = TextStrings._();
  factory TextStrings() => _instance;

  // home screen texts
  String homeFileTransferItsSafe = 'File transfer.\nIt’s safe!';
  String homeHassleFree = 'Hassle free.\n';
  String homeWeWillSetupAccount = 'We will set up your account right away.';

  // buttons text
  String buttonStart = 'Start';
  String buttonClose = 'Close';
  String accept = 'Accept';
  String reject = 'Reject';

  //history screen texts
  String sent = 'Sent';
  String received = 'Received';
  String moreDetails = 'More Details';
  String lesserDetails = 'Lesser Details';

  //receive files texts
  String blockUser = 'Block User';
}
