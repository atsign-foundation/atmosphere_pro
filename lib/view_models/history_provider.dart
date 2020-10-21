import 'dart:math';

import 'package:atsign_atmosphere_app/view_models/base_model.dart';

class HistoryProvider extends BaseModel {
  HistoryProvider._();
  static HistoryProvider _instance = HistoryProvider._();
  factory HistoryProvider() => _instance;
  String SENT_HISTORY = 'sent_history';
  String RECEIVED_HISTORY = 'received_history';
  List<Map<String, dynamic>> sentHistory = [];
  List<Map<String, dynamic>> receivedHistory = [];
  getSentHistory() async {
    setStatus(SENT_HISTORY, Status.Loading);
    try {
      await Future.delayed(Duration(seconds: 1), () {
        sentHistory = [];
        for (int i = 0; i < 10; i++) {
          Random r = Random();
          int random = r.nextInt(10) + 1;
          sentHistory.add({
            'name': 'User $i',
            'handle': '@user$i',
            'files_count': random,
            'total_size': random * 256,
            'date': '12 August 2020',
            'time': '1:12 PM',
            'files': List.generate(random, (index) {
              // print(random * 256 / index);
              return {
                'file_name': 'File_Name $index',
                'size': (random * 256 / 3).floor(),
                'type': 'JPG'
              };
            })
          });
        }
      });
      // int a = int.parse('source');
      setStatus(SENT_HISTORY, Status.Done);
    } catch (error) {
      print('ERROR IN SENT HISTORU======>$error');
      setError(SENT_HISTORY, error.toString());
    }
  }

  getRecievedHistory() async {
    setStatus(RECEIVED_HISTORY, Status.Loading);
    try {
      await Future.delayed(Duration(seconds: 1), () {
        receivedHistory = [];
        for (int i = 0; i < 10; i++) {
          Random r = Random();
          int random = r.nextInt(10) + 1;
          receivedHistory.add({
            'name': 'User $i',
            'handle': '@user$i',
            'files_count': random,
            'total_size': random * 256,
            'date': '12 August 2020',
            'time': '1:12 PM',
            'files': List.generate(random, (index) {
              // print(random * 256 / 0);
              return {
                'file_name': 'File_Name $index',
                'size': (random * 256 / 3).floor(),
                'type': 'JPG'
              };
            })
          });
        }
      });
      setStatus(RECEIVED_HISTORY, Status.Done);
    } catch (error) {
      setError(RECEIVED_HISTORY, error.toString());
    }
  }
}
