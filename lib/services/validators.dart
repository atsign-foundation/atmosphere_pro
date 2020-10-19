//It validates different input fields

class Validators {
  static String validateAdduser(String value) {
    if (value.isEmpty) return "User name should not be empty";
    String username = value.trim();
    if (username.length < 3) return "User name should be 3 character long";

    return null;
  }
}
