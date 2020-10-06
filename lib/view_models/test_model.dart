import 'package:atsign_atmosphere_app/view_models/base_model.dart';

class TestModel extends BaseModel {
  TestModel._();
  static TestModel _instance = TestModel._();
  factory TestModel() => _instance;
  int testValue;

  increment() async {
    setStatus(Status.Loading);
    await Future.delayed(Duration(seconds: 1), () {
      testValue++;
    });

    setStatus(Status.Done);
    notifyListeners();
  }

  decrement() {
    setStatus(Status.Loading);
    testValue--;
    setStatus(Status.Done);
    notifyListeners();
  }
}
