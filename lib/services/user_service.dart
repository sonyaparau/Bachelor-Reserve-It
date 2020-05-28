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
  * option. It also adds the device token of the
  * user so that future notifications can be sent
  * to him.
  * */
  Future addUser(User user) async {
    bool documentExists;
    await _checkDocumentExistence(user.uid)
        .then((exists) => documentExists = exists);
    String deviceToken;
    await _notificationService
        .getDeviceToken()
        .then((token) => deviceToken = token);
    if (!documentExists) {
      return await userCollection.document(user.uid).setData({
        'photoUrl': user.photoUrl,
        'email': user.email,
        'phoneNumber': user.phone,
        'firstName': user.firstName,
        'lastName': user.lastName,
        'deviceToken': deviceToken,
        'favouriteLocals': user.favouriteLocals
      });
    }
  }

  /*
  * Searches for a document by the Id of the user
  * and returns a future user if this is found.
  * */
  Future<User> findUserById(String id) async {
    User user = User();
    await userCollection
        .document(id)
        .get()
        .then((document) => user = _retrieveUserData(document, id));
    return user;
  }

  /*
  * Searches for a document by the Id of the user
  * and returns a future bool if this is found.
  * */
  Future<bool> _checkDocumentExistence(String id) async {
    bool documentExists = false;
    await userCollection
        .document(id)
        .get()
        .then((document) => documentExists = document.exists);
    return documentExists;
  }

  /*
  * Updates the document of a user given by
  * a map of data.
  * @param data - data that must be updated
  * @param id - the id of the document/user
  * that must be updated
  * */
  updateUser(Map data, String id) {
    userCollection.document(id).updateData(data);
  }

  /*
  * Adds a favourite local to a user in the favourite
  * locals list
  * */
  addFavouriteLocalToUser(String userId, dynamic local) {
    userCollection
        .document(userId)
        .updateData({"favouriteLocals": FieldValue.arrayUnion([local])});
  }

  /*
  * Removes a local from the favourite locals list of the
  * user if the user islikes one.
  * */
  deleteFavouriteLocalUser(String userId, dynamic local) {
    userCollection
        .document(userId)
        .updateData({"favouriteLocals": FieldValue.arrayRemove([local])});
  }

  /*
  * Finds the token of a device in the document after
  * a phone number. Each user has a unique phone number
  * and in this way information about a user can be found.
  * */
  Future<String> findTokenUser(String phoneNumber) async {
    String deviceToken;
    QuerySnapshot snapshot = await userCollection
        .where('phoneNumber', isEqualTo: phoneNumber)
        .getDocuments();
    snapshot.documents.forEach((element) {
      Map<String, dynamic> data = element.data;
      deviceToken = data['deviceToken'];
    });
    return deviceToken;
  }

  /*
  * Creates a user object based on the data retrieved from the
  * database that is sent through a map.
  * */
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
    if (userInformation.containsKey('favouriteLocals')) {
      user.favouriteLocals = List.from(userInformation['favouriteLocals']);
    }
    return user;
  }
}
