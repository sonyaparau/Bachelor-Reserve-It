class InputValidators {
  static RegExp phoneValidator = new RegExp(
    r"07[0-9]{8}",
    caseSensitive: false,
    multiLine: false,
  );

  static bool validateNumberPersons(String number) {
    try {
      int numberPersons = int.tryParse(number);
      if (numberPersons <= 0) return false;
      return true;
    } catch (exception) {
      return false;
    }
  }

  static bool validateName(String name) {
    RegExp nameValidator = new RegExp(
      r"([A-Z])+[A-Za-z\s-]*",
      caseSensitive: false,
      multiLine: false,
    );

    if (nameValidator.hasMatch(name)) return true;
    return false;
  }
}
