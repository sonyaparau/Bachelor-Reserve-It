import 'package:reserve_it_app/models/user.dart';
import 'package:reserve_it_app/services/authentication_service.dart';

class CommonMethods {
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