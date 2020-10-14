/// [TEST MODEL DELETE AFTER DEVELOPMENT]

import 'package:atsign_atmosphere_app/view_models/base_model.dart';

class TestModel extends BaseModel {
  TestModel._();
  static TestModel _instance = TestModel._();
  factory TestModel() => _instance;
  int testValue = 0;
  String INCREMENT = 'increment';
  String DECREMENT = 'decrement';
  increment() async {
    setStatus(INCREMENT, Status.Loading);
    await Future.delayed(Duration(seconds: 1), () {
      testValue++;
    });
    setStatus(INCREMENT, Status.Error);
    notifyListeners();
  }

  decrement() async {
    setStatus(DECREMENT, Status.Loading);
    await Future.delayed(Duration(seconds: 1), () {
      testValue--;
    });
    setStatus(DECREMENT, Status.Done);
    notifyListeners();
  }
}
