import 'package:atsign_atmosphere_pro/view_models/base_model.dart';

class SwitchAtSignProvider extends BaseModel {
  SwitchAtSignProvider();
  String switchAtSign = 'switchAtsign';

  update() {
    setStatus(switchAtSign, Status.Done);
  }
}
