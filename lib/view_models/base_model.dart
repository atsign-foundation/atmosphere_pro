import 'package:flutter/material.dart';

class BaseModel with ChangeNotifier {
  Map<String, Status> status = {'main': Status.Idle};
  Map<String, String?> error = {};

  setStatus(String function, Status inputStatus) {
    status[function] = inputStatus;
    notifyListeners();
  }

  setError(String function, String inputError, [Status? inputStatus]) {
    error[function] = inputError;
    status[function] = Status.Error;
    notifyListeners();
  }

  reset(String function) {
    data?.remove(function);
    error.remove(function);
    status.remove(function);
  }

  // used while fetching the count
  bool isCountLoading = true;

  // used for pagination calculation
  int? pageNumber;

  // used while fetching next page
  bool isNextPageLoading = true;

  // used for storing the response body
  List? data;

  // used for displaying the exceptions during API calls
  String? errorMessage;
// for search screen loader
// bool isPostLoading = true;
// bool isUserLoading = true;
// bool hasError = false;
// bool netwotkIssue = false;
}

enum Status { Loading, Done, Error, Idle }
