import 'package:cloud_firestore/cloud_firestore.dart';

/*
* Service for the entity Reservation.
* */
class ReservationService {
  //reservation collection reference
  final CollectionReference RESERVATION_COLLECTION =
      Firestore.instance.collection('reservations');
}
