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
  RegExp phone_validator = new RegExp(
    r"\+407[0-9]{8}",
    caseSensitive: false,
    multiLine: false,
  );

  String _phoneNumber;
  String _verificationId;
  String _smsCode;
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
                      children: !kIsWeb
                          ? <Widget>[
                                Image.asset('assets/reserve_logo.png'),
                                SizedBox(
                                  height: 10,
                                )
                              ] +
                              getMobileForm() +
                              [
                                SizedBox(
                                  height: 0,
                                ),
                                getGoogleButton(),
                                SizedBox(
                                  height: 10,
                                ),
                                getFacebookButton()
                              ]
                          : <Widget>[Image.asset('assets/reserve_logo.png')] +
                              [
                                getAnonymouslyButton(),
                                SizedBox(
                                  height: 10,
                                ),
                                getGoogleButton(),
                                SizedBox(
                                  height: 10,
                                ),
                                getFacebookButton()
                              ]),
                )))));
  }

  Future<void> verifyPhone(phoneNumber) async {
    final PhoneVerificationCompleted verified = (AuthCredential authResult) {
      AuthService().signIn(authResult);
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
      this._verificationId = verId;
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verified,
        verificationFailed: verificationFailed,
        codeSent: smsSent,
        codeAutoRetrievalTimeout: autoTimeout);
  }

  /*
  * Return the button for the Login with
  * Facebook option.
  * */
  Widget getFacebookButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () => AuthService().initiateFacebookLogin(),
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
  * Return the button for the Login with
  * Google Account option.
  * */
  Widget getGoogleButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () async {
        await AuthService().signInWithGoogle();
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

  Widget getVerifyButton(String text) {
    return OutlineButton(
        splashColor: Colors.grey,
        onPressed: () {
          if (validateInput()) {
            _sentVerificationCode
                ? AuthService().signInWithSmsCode(_smsCode, _verificationId)
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

  Widget getAnonymouslyButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () async {
        await AuthService().signInAnonymously();
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
  *  are required in order to submit the form.
  * */
  bool validateInput() {
    final form = formKey.currentState;

    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

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
          new SizedBox(height: 8)
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
                    return null;
                  },
                  onSaved: (value) => _smsCode = value,
                )
              : Container()
        ] +
        [
          SizedBox(height: 15),
          _sentVerificationCode
              ? getVerifyButton('Login')
              : getVerifyButton('Submit'),
          SizedBox(height: 10),
        ];
  }
}
