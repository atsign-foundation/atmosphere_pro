import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:flutter/foundation.dart';

class NotificationService extends ChangeNotifier {
  NotificationService._();
  static NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  static final fileObjectKey = 'fileObject';
  static final flushBarStatusKey = 'flushbarStatus';

  List<FileHistory> _recentNotifications = [];
  Map<String, dynamic> _currentFileShareStatus = {
    fileObjectKey: null,
    flushBarStatusKey: null
  };

  List<FileHistory> get recentNotification => _recentNotifications;
  Map<String, dynamic> get currentFileShareStatus => _currentFileShareStatus;
  int _notificationCount = 0;

  int get notificationCount => _notificationCount;

  resetNotificationCount() {
    _notificationCount = 0;
    notifyListeners();
  }

  updateCurrentFileShareStatus(
      FileTransfer? fileObject, FlushBarStatus flushBarStatus) {
    _currentFileShareStatus = {
      fileObjectKey: fileObject,
      flushBarStatusKey: flushBarStatus
    };
    notifyListeners();
  }

  addRecentNotifications(FileHistory fileHistory) {
    _recentNotifications.insert(0, fileHistory);
    ++_notificationCount;
    notifyListeners();
  }
}
