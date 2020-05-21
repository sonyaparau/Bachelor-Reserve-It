import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:reserve_it_app/models/user.dart';
import 'package:reserve_it_app/screens/login.dart';
import 'package:reserve_it_app/screens/dashboard.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:reserve_it_app/services/user_service.dart';

/*
* Service for the Firebase Authentication.
* */
class AuthService {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  UserService userService = new UserService();

  static String urlProfilePhoto;

  AuthService() {
    getCurrentProfilePicture();
  }

  /*
  * Checks when the application is started
  * if the user is already logged in.
  * If the user is logged in with one of the
  * sign in methods, then the application opens
  * directly with the Dashboard Page. Otherwise,
  * the application opens with the Login Page.
  * */
  handleAuthentication() {
    return StreamBuilder(
      stream: firebaseAuth.onAuthStateChanged,
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          return DashboardPage();
        } else {
          return LoginPage();
        }
      },
    );
  }

  // Sign in with Google Account
  Future<bool> signInWithGoogle() async {
    try {
      GoogleSignIn googleSignIn = GoogleSignIn();
      GoogleSignInAccount account = await googleSignIn.signIn();
      if (account == null) {
        return false;
      }
      AuthResult result = await firebaseAuth.signInWithCredential(
          GoogleAuthProvider.getCredential(
              idToken: (await account.authentication).idToken,
              accessToken: (await account.authentication).accessToken));
      if (result.user == null)
        return false;
      else {
        urlProfilePhoto = result.user.photoUrl;
        User user = new User(
            uid: result.user.uid,
            email: result.user.email,
            phone: result.user.phoneNumber,
            photoUrl: result.user.photoUrl);
        userService.addUser(user);
        return true;
      }
    } catch (exception) {
      print(exception.toString());
      return false;
    }
  }

  // Sign in on Firebase with Credentials
  signIn(AuthCredential authCredential) async {
    AuthResult result = await firebaseAuth.signInWithCredential(authCredential);
    urlProfilePhoto = result.user.photoUrl;
    User user = new User(
        uid: result.user.uid,
        email: result.user.email,
        phone: result.user.phoneNumber,
        photoUrl: result.user.photoUrl);
    userService.addUser(user);
  }

  // Sign in with Facebook Account
  Future<bool> signInWithFacebook() async {
    FacebookLogin facebookLogin = FacebookLogin();
    FacebookLoginResult facebookLoginResult =
        await facebookLogin.logIn(['email']);

    bool loggedInFacebook = false;

    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        loggedInFacebook = false;
        break;
      case FacebookLoginStatus.cancelledByUser:
        loggedInFacebook = false;
        break;
      case FacebookLoginStatus.loggedIn:
        loggedInFacebook = true;
        break;
    }
    if (loggedInFacebook) {
      FacebookAccessToken facebookAccessToken = facebookLoginResult.accessToken;
      AuthCredential authCredential = FacebookAuthProvider.getCredential(
          accessToken: facebookAccessToken.token);
      signIn(authCredential);
    }
    return loggedInFacebook;
  }

  // Sign in anonymously for the web version
  Future<String> signInAnonymously() async {
    try {
      AuthResult result = await firebaseAuth.signInAnonymously();
      urlProfilePhoto = result.user.photoUrl;
      return result.user.uid;
    } catch (exception) {
      return exception.toString();
    }
  }

  // Sign out from the application
  signOut() {
    firebaseAuth.signOut();
  }

  getCurrentProfilePicture() async {
    try {
      await firebaseAuth
          .currentUser()
          .then((user) => urlProfilePhoto = user.photoUrl);
    } catch (exception) {
      print('No user profile.');
    }
  }

  Future<bool> isAnonymousUser() async{
    bool isAnon = false;
    try {
      await firebaseAuth.currentUser().then((user) => isAnon = user.isAnonymous);
      return isAnon;
    } catch(exception) {
      print('Error getting current user.');
      return isAnon;
    }
  }

  Future<User> getUser() async {
    User user;
    FirebaseUser temporaryUser;
    try {
      await firebaseAuth.currentUser().then((user) => temporaryUser = user);
    } catch (exception) {
      print('Error getting current user.');
    }
    if (!temporaryUser.isAnonymous) {
      try {
        await userService.findUserById(temporaryUser.uid).then((value) => user = value);
      } catch (exception) {
        print('Error finding user document.');
      }
    } else {
      user.uid = temporaryUser.uid;
    }
    return user;
  }
}
