import 'package:atsign_atmosphere_pro/view_models/base_model.dart';

class SwitchAtsignProvider extends BaseModel {
  SwitchAtsignProvider();
  String switchAtsign = 'switchAtsign';

  bool isModalOpen = true;

  update() {
    setStatus(switchAtsign, Status.Done);
  }

  toggleModal() {
    isModalOpen = !isModalOpen;
    notifyListeners();
  }
}
