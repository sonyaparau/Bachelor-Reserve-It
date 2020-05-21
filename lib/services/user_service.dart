import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reserve_it_app/models/user.dart';
import 'package:reserve_it_app/services/device_service.dart';

/*
* Service for the entity User.
* */
class UserService {
  //user collection reference
  final CollectionReference userCollection =
      Firestore.instance.collection('users');
  DeviceService _notificationService = new DeviceService();

  /*
  * Creates a new document in the User collection
  * from the Firestore with the UID of the currently
  * logged user containing the email/ phone number/
  * profile picture url depending on the chosen login
  * option.
  * */
  Future addUser(User user) async {
    bool documentExists;
    await _checkDocumentExistence(user.uid).then((exists) => documentExists = exists);
    String deviceToken;
    await _notificationService.getDeviceToken().then((token) => deviceToken = token);
    if(!documentExists) {
      return await userCollection.document(user.uid).setData({
        'photoUrl': user.photoUrl,
        'email': user.email,
        'phoneNumber': user.phone,
        'firstName': user.firstName,
        'lastName': user.lastName,
        'deviceToken': deviceToken
      });
    }
  }

  Future<User> findUserById(String id) async {
    User user = User();
    await userCollection
        .document(id)
        .get()
        .then((document) => user = _retrieveUserData(document, id));
    return user;
  }

  Future<bool> _checkDocumentExistence(String id) async {
    bool documentExists = false;
    await userCollection.document(id).get().then((document) => documentExists = document.exists);
    return documentExists;
  }

  User _retrieveUserData(DocumentSnapshot documentSnapshot, String id) {
    User user = User();
    user.uid = id;
    Map<String, dynamic> userInformation = documentSnapshot.data;
    if (userInformation.containsKey('phoneNumber')) {
      user.phone = userInformation['phoneNumber'];
    }
    if (userInformation.containsKey('email')) {
      user.email = userInformation['email'];
    }
    if (userInformation.containsKey('firstName')) {
      user.firstName = userInformation['firstName'];
    }
    if (userInformation.containsKey('lastName')) {
      user.lastName = userInformation['lastName'];
    }
    return user;
  }

  updateUser(Map data, String id) {
    userCollection.document(id).updateData(data);
  }

  Future<String> findTokenUser(String phoneNumber) async {
    String deviceToken;
    QuerySnapshot snapshot = await userCollection.where('phoneNumber', isEqualTo: phoneNumber).getDocuments();
    snapshot.documents.forEach((element) {
      Map<String, dynamic> data = element.data;
      deviceToken = data['deviceToken'];
    });
    return deviceToken;
  }
}
