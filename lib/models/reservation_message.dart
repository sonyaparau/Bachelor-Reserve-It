/*
* Entity that keeps the message text and
* details of a reservation.
* */
class ReservationMessage {
  String title;
  String body;
  String message;
  String reservationId;
  String userId;

  ReservationMessage(String title, String body, String message,
      String reservationId, String userId) {
    this.title = title;
    this.body = body;
    this.message = message;
    this.reservationId = reservationId;
    this.userId = userId;
  }
}
