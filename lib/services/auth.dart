import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:reserve_it_app/screens/login_page.dart';
import 'package:reserve_it_app/screens/dashboard.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class AuthService {

  FirebaseAuth loggedUser = FirebaseAuth.instance;

  bool isLoggedIn = false;

  //Handles Authentication
  handleAuthentication() {
    return StreamBuilder(
      stream: loggedUser.onAuthStateChanged,
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          return DashboardPage();
        } else {
          return LoginPage();
        }
      },
    );
  }

  //Sign out
  signOut() {
    loggedUser.signOut();
  }

  //sign in
  signIn(AuthCredential authCredential) {
    loggedUser.signInWithCredential(authCredential);
  }

  //sign in with Google Account
  Future<bool> signInWithGoogle() async {
    try {
      GoogleSignIn googleSignIn = GoogleSignIn();
      GoogleSignInAccount account = await googleSignIn.signIn();
      if (account == null) {
        return false;
      }
      AuthResult result = await loggedUser.signInWithCredential(
          GoogleAuthProvider.getCredential(
              idToken: (await account.authentication).idToken,
              accessToken: (await account.authentication).accessToken));
      if (result.user == null) return false;
      return true;
    } catch (exception) {
      return false;
    }
  }

  //sign in with verificating the phone number
  signInWithSmsCode(smsCode, verId) {
    AuthCredential authCredential = PhoneAuthProvider.getCredential(
        verificationId: verId, smsCode: smsCode);
    signIn(authCredential);
  }

  void initiateFacebookLogin() async {
    FacebookLogin facebookLogin = FacebookLogin();
    FacebookLoginResult facebookLoginResult =
    await facebookLogin.logIn(['email']);
    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        print("Error");
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.cancelledByUser:
        print("CancelledByUser");
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.loggedIn:
        print("LoggedIn");
        onLoginStatusChanged(true);
        break;
    }
  }

  void onLoginStatusChanged(bool isLoggedIn) {
      this.isLoggedIn = isLoggedIn;
  }

  // sign in anonymously for the web version
  Future<String> signInAnonymously() async {
    try {
      AuthResult result = await loggedUser.signInAnonymously();
      return result.user.uid;
    } catch (exception) {
      print('ERROR!');
      return exception.toString();
    }
  }
}