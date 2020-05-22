import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reserve_it_app/models/reservation.dart';

/*
* Service for the entity Reservation.
* */
class ReservationService {
  final CollectionReference reservationCollection =
      Firestore.instance.collection('reservations');

  Future addReservation(Reservation reservation) async {
    return await reservationCollection.document().setData({
      'numberPeople': reservation.numberPeople,
      'resDate': reservation.date,
      'resTime': reservation.time,
      'restaurant': reservation.local.id,
      'firstName': reservation.user.firstName,
      'lastName': reservation.user.lastName,
      'mobileNumber': reservation.user.phone,
      'person': reservation.user.uid,
      'status': reservation.status.index,
      'device': reservation.deviceToSend,
      'userDevice': reservation.userDevice,
      'localName' : reservation.local.name,
      'localPicture' : reservation.local.mainPhoto
    });
  }

  updateReservationStatus(Map<String, dynamic> data, String reservationId) {
    reservationCollection.document(reservationId).updateData(data);
  }
}
