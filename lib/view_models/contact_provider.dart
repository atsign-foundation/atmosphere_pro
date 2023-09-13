import 'package:atsign_atmosphere_pro/view_models/base_model.dart';

class ContactProvider extends BaseModel {
  int indexTab = 0;

  void setIndexTab(int index) {
    indexTab = index;
    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }
}
