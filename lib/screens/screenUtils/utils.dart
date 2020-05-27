import 'package:reserve_it_app/models/user.dart';
import 'package:reserve_it_app/services/authentication_service.dart';

/*
* Contains methods which are called in more than
* one class/screen.
* */
class Utils {

  /*
  * Checks if a local is in the favourite list of locals
  * of the current logged user and returns true or false.
  * */
  Future<bool> isFavouriteLocal(String localId) async{
    User currentUser;
    await AuthService().getUser().then((user) => currentUser = user);
    if(currentUser != null && currentUser.favouriteLocals.isNotEmpty) {
      List<String> favouriteLocals = currentUser.favouriteLocals;
      print(favouriteLocals.length);
      for(String local in favouriteLocals) {
        print(local);
        if(local == localId) {
          return true;
        }
      }
    } else {
      return false;
    }
    return false;
  }
}