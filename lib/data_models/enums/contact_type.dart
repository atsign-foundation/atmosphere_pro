enum ListContactType { contact, trusted, groups, all }

extension ContactsTypeExtension on ListContactType {
  String get display {
    switch (this) {
      case ListContactType.contact:
        return "Contacts";
      case ListContactType.trusted:
        return "Trusted";
      case ListContactType.groups:
        return "Groups";
      case ListContactType.all:
        return "All";
    }
  }
}


enum SortedListContactType {contact, groups}

extension SortedContactsTypeExtension on SortedListContactType {
  String get display {
    switch (this) {
      case SortedListContactType.contact:
        return "Contacts";
      case SortedListContactType.groups:
        return "Groups";
    }
  }
}