/*
* Validators for the input fields
* of the application.
* */
class InputValidators {

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

  static bool validateEmail(String email) {
    if(RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)) {
      return true;
    } else {
      return false;
    }
  }

  /*
   * Validates the first/last name
   * */
  static bool validateName(String name) {
    if(RegExp('[0-9!@#%^&*()_+>?<]').hasMatch(name)) {
      return false;
    } else {
      return true;
    }
  }

  /*
  * Checks if a field is empty and returns
  * the response.
  * */
  static bool checkEmptyField(String field) {
    if(field.isEmpty) {
      return true;
    } else {
      return false;
    }
  }
  
  /*
  * Check if the sms code is of length 6 and
  * contains only digits.
  * */
  static bool validSMSCodeLength(String smsCode) {
    if(smsCode.length != 6 || RegExp('[a-zA-Z>?_ !@#%^*()]').hasMatch(smsCode)) {
      return false;
    } else {
      return true;
    }
  }

  /*
  * Phone number must have exactly 10 digits.
  * */
  static bool validPhoneNumber(String phoneNumber) {
    if(phoneNumber.length != 10 || RegExp('[a-zA-Z>?_ !@#%^*()]').hasMatch(phoneNumber)) {
      return false;
    } else {
      return true;
    }
  }
}
