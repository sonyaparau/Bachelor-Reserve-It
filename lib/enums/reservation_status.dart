/*
* Status of a reservation.
* When a reservation is created, it's status
* is PENDING. After the local responds to it,
* it updates it's status depending on the response
* of the local: either ACCEPTED or DECLINED.
* */
enum ReservationStatus { PENDING, ACCEPTED, DECLINED }