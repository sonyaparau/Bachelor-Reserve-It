import 'package:reserve_it_app/enums/reservation_status.dart';

/*
* Notification entity that provides
* the communication between the local and
* the user.
* */
class Notification {
  String id;
  String message;
  String restaurantId;
  ReservationStatus status;
  String reservationId;
  bool read;
  int type;

  Notification(
      {this.message,
      this.restaurantId,
      this.status,
      this.reservationId,
      this.read,
      this.type});
}
