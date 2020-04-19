import 'package:reserve_it_app/models/local.dart';
import 'package:reserve_it_app/models/user.dart';

//TODO add all necessary attributes
class Reservation {
  String id;
  User user;
  Local local;
  bool confirmed;
}