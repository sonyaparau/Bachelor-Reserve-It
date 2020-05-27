/*
* Validators for the input fields
* of the application.
* */
class InputValidators {

  /*
  * Validates a Romanian phone number which starts
  * with 07 and continues with exactly 8 digits.
  * */
  static RegExp phoneValidator = new RegExp(
    r"07[0-9]{8}",
    caseSensitive: false,
    multiLine: false,
  );

  /*
   * Validates the number of persons for a
   * reservation. This must be a number greater
   * than 0.
   * */
  static bool validateNumberPersons(String number) {
    try {
      int numberPersons = int.tryParse(number);
      if (numberPersons <= 0) return false;
      return true;
    } catch (exception) {
      return false;
    }
  }

  /*
   * Validates the first/last name
   * */
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
