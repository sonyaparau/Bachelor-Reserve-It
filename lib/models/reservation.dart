import 'package:reserve_it_app/enums/reservation_status.dart';
import 'package:reserve_it_app/models/local.dart';
import 'package:reserve_it_app/models/user.dart';

class Reservation {
  String id;
  User user;
  Local local;
  ReservationStatus status;
  String date;
  String time;
  int numberPeople;
  String deviceToSend;

  Reservation(
      {this.id, this.user, this.local, this.status, this.date, this.time, this.numberPeople, this.deviceToSend});
}
