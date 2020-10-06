import 'package:flutter/material.dart';

class BaseModel with ChangeNotifier {
  Map<String, Status> status = {'main': Status.Idle};
  // bool isLoading = false;
  // Status status;
  setStatus(String function, Status _status) {
    // status = localStatus;
    this.status[function] = _status;
    notifyListeners();
  }

  // used while fetching the count
  bool isCountLoading = true;
  // used for pagination calculation
  int pageNumber;
  // used while fetching next page
  bool isNextPageLoading = true;
  // used for storing the response body
  var data;
  // used for displaying the exceptions during API calls
  String errorMessage;
  // for search screen loader
  // bool isPostLoading = true;
  // bool isUserLoading = true;
  // bool hasError = false;
  // bool netwotkIssue = false;
}

enum Status { Loading, Done, Error, Idle }
