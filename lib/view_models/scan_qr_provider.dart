import 'dart:io';

import 'package:atsign_atmosphere_app/services/backend_service.dart';
import 'package:atsign_atmosphere_app/view_models/base_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_qr_reader/flutter_qr_reader.dart';

class ScanQrProvider extends BaseModel {
  ScanQrProvider._();
  static ScanQrProvider _instance = ScanQrProvider._();
  factory ScanQrProvider() => _instance;
  BackendService backendService = BackendService.getInstance();
  String cramWithoutQr = 'cram_without_qr';
  String uploadKey = 'upload_key_file';
  void cramAuthWithoutQR() async {
    setStatus(cramWithoutQr, Status.Loading);
    bool response = false;
    try {
      String colinSecret =
          "540f1b5fa05b40a58ea7ef82d3cfcde9bb72db8baf4bc863f552f82695837b9fee631f773ab3e34dde05b51e900220e6ae6f7240ec9fc1d967252e1aea4064ba";
      String kevinSecret =
          'e0d06915c3f81561fb5f8929caae64a7231db34fdeaff939aacac3cb736be8328c2843b518a2fc7a58fcec8c0aa98c735c0ce5f8ce880e97cd61cf1f2751efc5';
      response = await backendService.authenticateWithCram("@colin🛠",
          cramSecret: colinSecret);
      // .then((response) async {
      print("auth successful $response");
      if (response != null) {
        await backendService.startMonitor();
      }
      setStatus(cramWithoutQr, Status.Done);
    } catch (e) {
      setError(cramWithoutQr, e.toString());
      print('ERROR IN CRAM=====>$e');
    }
  }

  bool loading = false;
  void uploadKeyFile() async {
    print("upload file");
    setStatus(uploadKey, Status.Loading);
    try {
      String fileContents, aesKey, atsign;
      FilePickerResult result = await FilePicker.platform
          .pickFiles(type: FileType.any, allowMultiple: true);
      // setState(() {
      loading = true;
      // });
      for (var file in result.files) {
        if (file.path.contains('atKeys')) {
          fileContents = File(file.path).readAsStringSync();
        } else if (aesKey == null &&
            atsign == null &&
            file.path.contains('_private_key.png')) {
          String result = await FlutterQrReader.imgScan(File(file.path));
          List<String> params = result.split(':');
          atsign = params[0];
          aesKey = params[1];
          //read scan QRcode and extract atsign,aeskey
        }
      }
      if (fileContents == null || (aesKey == null && atsign == null)) {
        // _showAlertDialog(_incorrectKeyFile);
        print("show file content error");
      }
      await _processAESKey(atsign, aesKey, fileContents);
      setStatus(uploadKey, Status.Done);
    } catch (error) {
      setError(uploadKey, error.toString());
    }
    //  on Error catch (error) {
    //   // setState(() {
    //   loading = false;
    //   set
    //   // });
    //   // _logger.severe('Processing files throws $error');
    //   // _showAlertDialog(_failedFileProcessing);
    // } on Exception catch (ex) {
    //   // setState(() {
    //   loading = false;
    //   // });
    //   // _logger.severe('Processing files throws $ex');
    //   // _showAlertDialog(_failedFileProcessing);
    // }
  }

  var aesKeyResponse = false;
  _processAESKey(String atsign, String aesKey, String contents) async {
    assert(aesKey != null || aesKey != '');
    assert(atsign != null || atsign != '');
    assert(contents != null || contents != '');
    try {
      setStatus(uploadKey, Status.Loading);
      aesKeyResponse = await backendService.authenticateWithAESKey(atsign,
          jsonData: contents, decryptKey: aesKey);
      setStatus(uploadKey, Status.Done);
    } catch (error) {
      setError(uploadKey, error.toString());
    }
    //     .then((response) async {
    //   if (response) {
    //     // await Navigator.of(context).pushNamed(Routes.WELCOME_SCREEN);
    //   }
    //   // setState(() {
    //   loading = false;
    //   // });
    // }).catchError((err) {
    //   print("Error in authenticateWithAESKey");
    //   // _showAlertDialog(err);
    //   // setState(() {
    //   //   loading = false;
    //   // });
    //   // _logger.severe('Scanning QR code throws $err Error');
    // });
  }
}
