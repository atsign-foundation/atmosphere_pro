enum ContactsType { contact, trusted, groups }

extension ContactsTypeExtension on ContactsType {
  String get display {
    switch (this) {
      case ContactsType.contact:
        return "Contacts";
      case ContactsType.trusted:
        return "Trusted";
      case ContactsType.groups:
        return "Groups";
    }
  }
}
