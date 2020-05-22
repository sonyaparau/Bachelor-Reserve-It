/*
* Notification entity that provides
* the communication between the local and
* the user.
* */
class Notification {
  String id;
  String message;
  String restaurantId;
  int status;
  String reservationId;
  String userId;
  bool read;
  int type;

  Notification(
      {this.message,
      this.restaurantId,
      this.status,
      this.reservationId,
      this.read,
      this.type,
      this.userId});
}
