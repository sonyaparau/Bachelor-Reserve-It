import 'package:firebase_messaging/firebase_messaging.dart';

class DeviceService {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  Future<String> getDeviceToken() async{
    String deviceToken;
    await _firebaseMessaging.getToken().then((token) => deviceToken = token);
    print('Device token: ' + deviceToken);
    return deviceToken;
  }
}