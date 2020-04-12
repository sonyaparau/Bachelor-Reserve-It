import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reserve_it_app/models/user.dart';
import 'package:reserve_it_app/services/auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:reserve_it_app/services/user_service.dart';
import 'package:reserve_it_app/utils/custom_widgets.dart';
import 'package:reserve_it_app/utils/loading.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = new GlobalKey<FormState>();
  final AuthService _authService = new AuthService();
  final CustomWidgets _utils = new CustomWidgets();

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
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Loading()
        : Scaffold(
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
                                        _utils.getHeightSizedBox(10.0)
                                      ] +
                                      getMobileForm() +
                                      [
                                        getGoogleButton(),
                                        _utils.getHeightSizedBox(10.0),
                                        getFacebookButton()
                                      ]
                                  //if the Platform is Web then allow logging in anonymously
                                  : <Widget>[
                                        Image.asset('assets/reserve_logo.png')
                                      ] +
                                      [
                                        getAnonymousButton(),
                                        _utils.getHeightSizedBox(10.0),
                                        getGoogleButton()
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
        setLoadingState(true);
        dynamic result = await _authService.signInWithFacebook();
        if (result == null) {
          setLoadingState(false);
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
        setLoadingState(true);
        dynamic result = await _authService.signInWithGoogle();
        if (result == null) {
          setLoadingState(false);
        }
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
            if (_sentVerificationCode) {
              setLoadingState(true);
              dynamic result = signInWithSmsCode(_smsCode, _verificationId);
              if (result == null) {
                setLoadingState(false);
              }
            } else {
              verifyPhone(_phoneNumber);
            }
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
        setLoadingState(true);
        dynamic result = await _authService.signInAnonymously();
        if (result == null) {
          setLoadingState(false);
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
          _utils.getHeightSizedBox(8.0)
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
          _utils.getHeightSizedBox(15.0),
          _sentVerificationCode
              ? getVerifyButton('Login')
              : getVerifyButton('Verify phone number'),
          _utils.getHeightSizedBox(15.0),
        ];
  }

  /*
  * Login method with mobile number. A verification
  * code is sent via SMS and the user must enter
  * it in the application in order to log in.
  * */
  Future<void> verifyPhone(phoneNumber) async {
    final PhoneVerificationCompleted verified = (AuthCredential authResult) {
      signInWithPhoneOption(authResult);
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

  // Sign in with Phone number
  signInWithSmsCode(smsCode, verId) {
    AuthCredential authCredential = PhoneAuthProvider.getCredential(
        verificationId: verId, smsCode: smsCode);
    return signInWithPhoneOption(authCredential);
  }

  // Sign in on Firebase with Credentials
  signInWithPhoneOption(AuthCredential authCredential) async {
    await _authService.firebaseAuth
        .signInWithCredential(authCredential)
        .then((AuthResult value) {
      AuthService.urlProfilePhoto = value.user.photoUrl;
      User user = new User(
          uid: value.user.uid,
          email: value.user.email,
          phone: value.user.phoneNumber,
          photoUrl: value.user.photoUrl);
      UserService().addUser(user);
    }).catchError((onError) {
      setLoadingState(false);
      _utils.getPopup(
          'Problem logging in',
          'Something went wrong. Please try again!',
          context,
          [getFlatButton('OK')]);
    });
  }

  /*
  * Sets the Loading screen
  * variable
  * */
  setLoadingState(bool isLoading) {
    setState(() {
      _loading = isLoading;
    });
  }

  /*
  * Returns a flat button for the
  * AlertDialog which appears when
  * the login process is not successful.
  * */
  Widget getFlatButton(String text) {
    return new FlatButton(
      child: new Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }
}
