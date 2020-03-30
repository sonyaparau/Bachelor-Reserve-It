import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reserve_it_app/services/auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = new GlobalKey<FormState>();
  final AuthService _authService = new AuthService();

  // Phone mobile number must start with +4 and
  // continue with 07 followed by 8 digits as it
  //is a Romanian number
  RegExp phone_validator = new RegExp(
    r"\+407[0-9]{8}",
    caseSensitive: false,
    multiLine: false,
  );

  String _phoneNumber;
  String _smsCode;
  String _verificationId;
  bool _sentVerificationCode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(backgroundColor: Colors.deepPurple),
        backgroundColor: Colors.white,
        resizeToAvoidBottomPadding: true,
        body: new Center(
            child: new Container(
                width: !kIsWeb ? 320 : 370,
                padding: new EdgeInsets.all(4.0),
                child: SingleChildScrollView(
                    child: new Form(
                  key: formKey,
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          //if the Platform is Android/Ios then allow logging in with phone number
                          !kIsWeb
                              ? <Widget>[
                                    Image.asset('assets/reserve_logo.png'),
                                    getSizedBox(10)
                                  ] +
                                  getMobileForm() +
                                  [
                                    getGoogleButton(),
                                    getSizedBox(10),
                                    getFacebookButton()
                                  ]
                              //if the Platform is Web then allow logging in anonymously
                              : <Widget>[
                                    Image.asset('assets/reserve_logo.png')
                                  ] +
                                  [
                                    getAnonymousButton(),
                                    getSizedBox(10),
                                    getGoogleButton(),
                                    getSizedBox(10),
                                    getFacebookButton()
                                  ]),
                )))));
  }

  /*
  * Returns the button for login with
  * Facebook option.
  * */
  Widget getFacebookButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () async {
        await _authService.signInWithFacebook();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage("assets/facebook_logo.png"), height: 30.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign in with Facebook',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            )
          ],
        ),
      ),
    );
  }

  /*
  * Returns the button for the Login with
  * Google Account option.
  * */
  Widget getGoogleButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () async {
        await _authService.signInWithGoogle();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 15, 20, 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage("assets/google_logo.png"), height: 30.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign in with Google',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            )
          ],
        ),
      ),
    );
  }

  /*
  * Returns the button for the verification of the
  * phone number or the button for the logging in
  * with the phone number.
  *
  * @param text - the text for the button
  * */
  Widget getVerifyButton(String text) {
    return OutlineButton(
        splashColor: Colors.grey,
        onPressed: () {
          if (validateInput()) {
            _sentVerificationCode
                ? _authService.signInWithSmsCode(_smsCode, _verificationId)
                : verifyPhone(_phoneNumber);
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        highlightElevation: 0,
        borderSide: BorderSide(color: Colors.grey),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  text,
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                ),
              )
            ],
          ),
        ));
  }

  /*
  * Returns the button for loging in
  * anonymously. This button only exists
  * for the web platform.
  * */
  Widget getAnonymousButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () async {
        await _authService.signInAnonymously();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage("assets/anonymous.png"), height: 30.0),
            new Text(
              '   Sign in as Anonymous',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            )
          ],
        ),
      ),
    );
  }

  /*
  * Validates the input of the form.
  * Phone number and code received in the SMS
  * are required in order to submit the form.
  * Code received must have exactly 6 characters.
  * */
  bool validateInput() {
    final form = formKey.currentState;

    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  /*
  * Returns the textfields for the phone
  * number and the code verification. These are
  * available only for the mobile platforms.
  * */
  List<Widget> getMobileForm() {
    return [
          new TextFormField(
            keyboardType: TextInputType.phone,
            decoration: new InputDecoration(
                labelText: 'Phone number', labelStyle: TextStyle(fontSize: 18)),
            validator: (value) {
              if (value.isEmpty) return 'Phone number is required!';
              if (!phone_validator.hasMatch(value.trim()))
                return 'Phone number format is invalid!';
              return null;
            },
            onSaved: (value) => _phoneNumber = value,
          ),
          getSizedBox(8)
        ] +
        [
          _sentVerificationCode
              ? TextFormField(
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                      labelText: 'Enter SMS code',
                      labelStyle: TextStyle(fontSize: 18)),
                  validator: (value) {
                    if (value.isEmpty) return 'SMS code cannot be empty!';
                    if (value.length != 6)
                      return 'SMS code must have 6 characters!';
                    return null;
                  },
                  onSaved: (value) => _smsCode = value,
                )
              : Container()
        ] +
        [
          getSizedBox(15),
          _sentVerificationCode
              ? getVerifyButton('Login')
              : getVerifyButton('Verify phone number'),
          getSizedBox(15),
        ];
  }

  /*
  * Returns a SizedBox with the height given
  * as a parameter. SizedBox is uses as a padding
  * between to widgets.
  * */
  Widget getSizedBox(double height) {
    return new SizedBox(height: height);
  }

  /*
  * Login method with mobile number. A verification
  * code is sent via SMS and the user must enter
  * it in the application in order to log in.
  * */
  Future<void> verifyPhone(phoneNumber) async {
    final PhoneVerificationCompleted verified = (AuthCredential authResult) {
      _authService.signIn(authResult);
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      print('${authException.message}');
    };

    final PhoneCodeSent smsSent = (String verId, [int forceResend]) {
      this._verificationId = verId;
      setState(() {
        this._sentVerificationCode = true;
      });
    };

    final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
      _verificationId = verId;
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verified,
        verificationFailed: verificationFailed,
        codeSent: smsSent,
        codeAutoRetrievalTimeout: autoTimeout);
  }
}
