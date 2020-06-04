import 'package:flutter_test/flutter_test.dart';
import 'package:reserve_it_app/screens/screenUtils/input_validators.dart';

/*
* Test all the existing validators for the
* input fields.
* */
void main() {
  test('Empty field', () {
    bool isEmptyField = InputValidators.checkEmptyField('');
    expect(isEmptyField, true);
  });

  test('Not empty field', () {
    bool isEmptyField = InputValidators.checkEmptyField('+40720885258');
    expect(isEmptyField, false);
  });

  test('Invalid SMS Code', () {
    String smsCode1 = '12344'; //too short
    String smsCode2 = '12a444'; //not only digits
    String smsCode3 = 'aa3548'; //not only digits
    String smsCode4 = '485maj'; //not only digits
    String smsCode5 = 'a8a8a8'; //not only digits
    String smsCode6 = 'aaaaaa'; //not only digits
    String smsCode7 = '?we928'; //not only digits
    String smsCode8 = '12345?'; //not only digits
    String smsCode9 = '6   89'; //not only digits
    String smsCode10 = '??????'; //not only digits

    bool sms1 = InputValidators.validSMSCodeLength(smsCode1);
    bool sms2 = InputValidators.validSMSCodeLength(smsCode2);
    bool sms3 = InputValidators.validSMSCodeLength(smsCode3);
    bool sms4 = InputValidators.validSMSCodeLength(smsCode4);
    bool sms5 = InputValidators.validSMSCodeLength(smsCode5);
    bool sms6 = InputValidators.validSMSCodeLength(smsCode6);
    bool sms7 = InputValidators.validSMSCodeLength(smsCode7);
    bool sms8 = InputValidators.validSMSCodeLength(smsCode8);
    bool sms9 = InputValidators.validSMSCodeLength(smsCode9);
    bool sms10 = InputValidators.validSMSCodeLength(smsCode10);

    expect(sms1, false);
    expect(sms2, false);
    expect(sms3, false);
    expect(sms4, false);
    expect(sms5, false);
    expect(sms6, false);
    expect(sms7, false);
    expect(sms8, false);
    expect(sms9, false);
    expect(sms10, false);

  });

  test('Valid SMS Code', () {
    String smsCode1 = '123456';
    String smsCode2 = '001122';
    String smsCode3 = '938475';

    bool sms1 = InputValidators.validSMSCodeLength(smsCode1);
    bool sms2 = InputValidators.validSMSCodeLength(smsCode2);
    bool sms3 = InputValidators.validSMSCodeLength(smsCode3);

    expect(sms1, true);
    expect(sms2, true);
    expect(sms3, true);
  });

  test('Invalid phone number', () {
    String phoneNumber1 = '0720394'; //too short
    String phoneNumber2 = '07203945769385'; //too long
    String phoneNumber3 = '0729ao2839'; //not only digits
    String phoneNumber4 = '07209938i4'; //not only digits
    String phoneNumber5 = '0720384nna'; //not only digits
    String phoneNumber6 = 'abcdefghij'; //not only digits

    bool number1 = InputValidators.validPhoneNumber(phoneNumber1);
    bool number2 = InputValidators.validPhoneNumber(phoneNumber2);
    bool number3 = InputValidators.validPhoneNumber(phoneNumber3);
    bool number4 = InputValidators.validPhoneNumber(phoneNumber4);
    bool number5 = InputValidators.validPhoneNumber(phoneNumber5);
    bool number6 = InputValidators.validPhoneNumber(phoneNumber6);

    expect(number1, false);
    expect(number2, false);
    expect(number3, false);
    expect(number4, false);
    expect(number5, false);
    expect(number6, false);

  });

  test('Valid phone number', () {
    String phoneNumber1 = '0720885258';
    String phoneNumber2 = '0743433975';
    String phoneNumber3 = '1010109238';

    bool number1 = InputValidators.validPhoneNumber(phoneNumber1);
    bool number2 = InputValidators.validPhoneNumber(phoneNumber2);
    bool number3 = InputValidators.validPhoneNumber(phoneNumber3);

    expect(number1, true);
    expect(number2, true);
    expect(number3, true);
  });

  test('Valid name', () {
    String name1 = 'Sonya-Roxana';
    String name2 = 'sonya';
    String name3 = 'Sonya Parau';

    bool validName1 = InputValidators.validateName(name1);
    bool validName2 = InputValidators.validateName(name2);
    bool validName3 = InputValidators.validateName(name3);

    expect(validName1, true);
    expect(validName2, true);
    expect(validName3, true);
  });

  test('Invalid name', () {
    String name1 = 'Sonya9'; //contains digits
    String name2 = 'Sonya???'; //contains invalid char
    String name3 = '334Sonya???'; //contains invalid char and digits

    bool invalidName1 = InputValidators.validateName(name1);
    bool invalidName2 = InputValidators.validateName(name2);
    bool invalidName3 = InputValidators.validateName(name3);

    expect(invalidName1, false);
    expect(invalidName2, false);
    expect(invalidName3, false);
  });

  test('Valid number persons', () {
    String number1 = '12';
    String number2 = '2';
    String number3 = '50';

    bool validNumber1 = InputValidators.validateNumberPersons(number1);
    bool validNumber2 = InputValidators.validateNumberPersons(number2);
    bool validNumber3 = InputValidators.validateNumberPersons(number3);

    expect(validNumber1, true);
    expect(validNumber2, true);
    expect(validNumber3, true);

  });

  test('Invalid number persons', () {
    String number1 = '-1'; //negative number
    String number2 = '0'; //not greater than 0
    String number3 = '5a'; //cannot parse in int
    String number4 = 'aa'; //cannot parse in int

    bool invalidNumber1 = InputValidators.validateNumberPersons(number1);
    bool invalidNumber2 = InputValidators.validateNumberPersons(number2);
    bool invalidNumber3 = InputValidators.validateNumberPersons(number3);
    bool invalidNumber4 = InputValidators.validateNumberPersons(number4);

    expect(invalidNumber1, false);
    expect(invalidNumber2, false);
    expect(invalidNumber3, false);
    expect(invalidNumber4, false);
  });

  test('Invalid email adress', () {
      String email1 = 'sonyaparau';
      String email2 = 'sonyaparau.com';
      String email3 = 'sonyaparau>DWEijoihe^&(@*(?@kmsakf.fwelj.com';

      bool invalidEmail1 = InputValidators.validateEmail(email1);
      bool invalidEmail2 = InputValidators.validateEmail(email2);
      bool invalidEmail3 = InputValidators.validateEmail(email3);

      expect(invalidEmail1, false);
      expect(invalidEmail2, false);
      expect(invalidEmail3, false);
  });

  test('Valid email adress', () {
    String email1 = 'sonyaparau@yahoo.com';
    String email2 = 'sonyaparau15@gmail.com';
    String email3 = 'sonya_parau@gmail.com';
    String email4 = 'sonyaparau@msg.group';

    bool validEmail1 = InputValidators.validateEmail(email1);
    bool validEmail2 = InputValidators.validateEmail(email2);
    bool validEmail3 = InputValidators.validateEmail(email3);
    bool validEmail4 = InputValidators.validateEmail(email4);

    expect(validEmail1, true);
    expect(validEmail2, true);
    expect(validEmail3, true);
    expect(validEmail4, true);
  });

}