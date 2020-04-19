import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reserve_it_app/models/user.dart';

/*
* Service for the entity User.
* */
class UserService {
  //user collection reference
  final CollectionReference USER_COLLECTION =
      Firestore.instance.collection('users');

  /*
  * Creates a new document in the User collection
  * from the Firestore with the UID of the currently
  * logged user containing the email/ phone number/
  * profile picture url depending on the chosen login
  * option.
  * */
  Future addUser(User user) async {
    return await USER_COLLECTION.document(user.uid).setData({
      'photoUrl': user.photoUrl,
      'email': user.email,
      'phoneNumber': user.phone
    });
  }
}
