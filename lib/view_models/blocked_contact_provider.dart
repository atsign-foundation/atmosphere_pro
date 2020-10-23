import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_app/view_models/base_model.dart';

class BlockedContactProvider extends BaseModel {
  BlockedContactProvider._();
  static BlockedContactProvider _instance = BlockedContactProvider._();

  factory BlockedContactProvider() => _instance;
  String BlockedContacts = 'blockedContacts';
  List<AtContact> blockedContacts = [];

  getBlockedContacts() async {
    print(' in blocked user get');
    setStatus(BlockedContacts, Status.Loading);
    try {
      await Future.delayed(Duration(seconds: 1), () {
        blockedContacts = [];
        for (int i = 0; i < 10; i++) {
          blockedContacts.add(AtContact(atSign: 'User $i'));
        }
      });
      setStatus(BlockedContacts, Status.Done);
    } catch (error) {
      setError(BlockedContacts, error.toString());
    }
  }
}
