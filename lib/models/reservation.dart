import 'package:reserve_it_app/enums/reservation_status.dart';
import 'package:reserve_it_app/models/local.dart';
import 'package:reserve_it_app/models/user.dart';

/*
* Reservation entity.
* */
class Reservation {
  String id;
  User user;
  Local local;
  ReservationStatus status;
  String date;
  String time;
  int numberPeople;

  //device of the local
  String deviceToSend;

  //device of the user that made the reservation
  String userDevice;

  Reservation(
      {this.id,
      this.user,
      this.local,
      this.status,
      this.date,
      this.time,
      this.numberPeople,
      this.deviceToSend,
      this.userDevice});
}
