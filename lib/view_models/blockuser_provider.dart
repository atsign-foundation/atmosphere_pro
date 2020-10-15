import 'package:atsign_atmosphere_app/view_models/base_model.dart';

class BlockeduserProvider extends BaseModel {
  BlockeduserProvider._();
  static BlockeduserProvider _instance = BlockeduserProvider._();

  factory BlockeduserProvider() => _instance;
  String Blocked_USER = 'blockeduser';
  List<Map<String, dynamic>> blockedUser = [];

  getBlockedUser() async {
    setStatus(Blocked_USER, Status.Loading);
    await Future.delayed(Duration(seconds: 1), () {
      blockedUser = [];
      for (int i = 0; i < 10; i++) {
        blockedUser.add({
          'name': 'User $i',
          'handle': '@user$i',
        });
      }
    });
    setStatus(Blocked_USER, Status.Done);
  }
}
