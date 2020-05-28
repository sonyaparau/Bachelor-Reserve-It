import 'package:firebase_messaging/firebase_messaging.dart';

/*
* Service that manages the device token
* of the logged user. It uses Firebase
* Messaging.
* */
class DeviceService {
  //Firebase Messaging dependency
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  /*
  * Returns a future containing the token of the
  * user's device.
  * */
  Future<String> getDeviceToken() async{
    String deviceToken;
    await _firebaseMessaging.getToken().then((token) => deviceToken = token);
    return deviceToken;
  }
}