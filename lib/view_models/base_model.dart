import 'package:flutter/material.dart';

class BaseModel with ChangeNotifier {
  Map<String, Status> status = {'main': Status.Idle};
  Map<String, String?> error = {};

  setStatus(String function, Status _status) {
    this.status[function] = _status;
    notifyListeners();
  }

  setError(String function, String _error, [Status? _status]) {
    error[function] = _error;
    status[function] = Status.Error;
    notifyListeners();
  }

  reset(String function) {
    this.data?.remove(function);
    this.error.remove(function);
    this.status.remove(function);
  }

  // used while fetching the count
  bool isCountLoading = true;

  // used for pagination calculation
  int? pageNumber;

  // used while fetching next page
  bool isNextPageLoading = true;

  // used for storing the response body
  var data;

  // used for displaying the exceptions during API calls
  String? errorMessage;
}

enum Status { Loading, Done, Error, Idle }
