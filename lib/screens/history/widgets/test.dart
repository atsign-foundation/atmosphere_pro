// class ksk {
//   getAllFileTransferData() async {
//     setStatus(GET_ALL_FILE_DATA, Status.Loading);
//     List<FileTransfer> tempReceivedHistoryLogs = [];
//
//     List<AtKey> fileTransferAtkeys =
//     await AtClientManager.getInstance().atClient.getAtKeys(
//       regex: MixedConstants.FILE_TRANSFER_KEY,
//     );
//
//     fileTransferAtkeys.retainWhere((element) =>
//     !element.key!.contains(MixedConstants.FILE_TRANSFER_ACKNOWLEDGEMENT));
//
//     bool isNewKeyAvailable = false;
//     fileTransferAtkeys.forEach((AtKey atkey) {
//       if (receivedItemsId[atkey.key] == null) {
//         isNewKeyAvailable = true;
//       }
//       receivedItemsId[atkey.key] = true;
//     });
//
//     if (!isNewKeyAvailable) {
//       return;
//     }
//
//     for (var atKey in fileTransferAtkeys) {
//       var isCurrentAtsign = compareAtSign(
//           atKey.sharedBy!, BackendService.getInstance().currentAtSign!);
//
//       if (!isCurrentAtsign && !checkRegexFromBlockedAtsign(atKey.sharedBy!)) {
//         receivedItemsId[atKey.key] = true;
//
//         AtValue atvalue = await AtClientManager.getInstance()
//             .atClient
//             .get(atKey)
//         // ignore: return_of_invalid_type_from_catch_error
//             .catchError((e) {
//           print("error in getting atValue in getAllFileTransferData : $e");
//           //// Removing exception as called in a loop
//           // ExceptionService.instance.showGetExceptionOverlay(e);
//           return AtValue();
//         });
//
//         if (atvalue != null && atvalue.value != null) {
//           try {
//             FileTransferObject fileTransferObject =
//             FileTransferObject.fromJson(jsonDecode(atvalue.value))!;
//
//             FileTransfer filesModel =
//             convertFiletransferObjectToFileTransfer(fileTransferObject);
//
//             filesModel.sender = atKey.sharedBy!;
//
//             if (filesModel.key != null) {
//               tempReceivedHistoryLogs.insert(0, filesModel);
//             }
//           } catch (e) {
//             print('error in getAllFileTransferData file model conversion: $e');
//           }
//         }
//       }
//     }
//
//     receivedHistoryLogs = tempReceivedHistoryLogs;
//     setStatus(GET_ALL_FILE_DATA, Status.Done);
//   }
// }