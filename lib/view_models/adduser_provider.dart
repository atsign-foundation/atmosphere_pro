import 'package:atsign_atmosphere_app/view_models/base_model.dart';

class AdduserProvider extends BaseModel {
  AdduserProvider._();
  static AdduserProvider _instance = AdduserProvider._();
  factory AdduserProvider() => _instance;
  String Addusers = 'addusers';
  List<Map<String, dynamic>> addusers = [];

  getaddusers() async {
    setStatus(Addusers, Status.Loading);
    await Future.delayed(Duration(seconds: 1), () {
      addusers = [];
      for (int i = 0; i < 10; i++) {
        addusers.add({
          'name': 'User $i',
        });
      }
    });
    setStatus(Addusers, Status.Done);
  }
}
