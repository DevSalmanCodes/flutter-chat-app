class ValidationConstants {
  static const String emailRegex =
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";

  static String? isValidEmail(String? email) {
    RegExp regExp = RegExp(emailRegex);
    if (!regExp.hasMatch(email!)) {
      return 'Invalid email';
    }
    return null;
  }

  static String? isValidPassword(String? password) {
    if (password!.length < 6) {
      return 'Password should be at least 6 characters';
    }
    return null;
  }
}
