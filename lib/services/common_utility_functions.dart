import 'dart:typed_data';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';

class CommonUtilityFunctions {
  static final CommonUtilityFunctions _singleton =
      CommonUtilityFunctions._internal();
  CommonUtilityFunctions._internal();

  factory CommonUtilityFunctions() {
    return _singleton;
  }

  getCachedContactImage(String atsign) {
    Uint8List image;
    AtContact contact = checkForCachedContactDetail(atsign);

    if (contact != null &&
        contact.tags != null &&
        contact.tags['image'] != null) {
      List<int> intList = contact.tags['image'].cast<int>();
      image = Uint8List.fromList(intList);
    }

    return image;
  }
}
