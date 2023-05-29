enum ContactFilter { all, contacts, groups }

extension ContactFilterExtension on ContactFilter {
  String get display {
    switch (this) {
      case ContactFilter.all:
        return "All Contacts";
      case ContactFilter.contacts:
        return "Contacts";
      case ContactFilter.groups:
        return "Groups";
    }
  }
}
