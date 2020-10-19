import 'package:atsign_atmosphere_app/view_models/base_model.dart';

class BlockedContactProvider extends BaseModel {
  BlockedContactProvider._();
  static BlockedContactProvider _instance = BlockedContactProvider._();

  factory BlockedContactProvider() => _instance;
  String BlockedContacts = 'blockedContacts';
  List<Map<String, dynamic>> blockedContacts = [];

  getBlockedContacts() async {
    setStatus(BlockedContacts, Status.Loading);
    await Future.delayed(Duration(seconds: 1), () {
      blockedContacts = [];
      for (int i = 0; i < 10; i++) {
        blockedContacts.add({
          'name': 'User $i',
          'handle': '@user$i',
        });
      }
    });
    setStatus(BlockedContacts, Status.Done);
  }
}
