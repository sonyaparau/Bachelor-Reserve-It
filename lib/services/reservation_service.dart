import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reserve_it_app/enums/reservation_status.dart';
import 'package:reserve_it_app/models/local.dart';
import 'package:reserve_it_app/models/reservation.dart';
import 'package:reserve_it_app/models/user.dart';

/*
* Service for the entity Reservation.
* */
class ReservationService {
  final CollectionReference reservationCollection =
      Firestore.instance.collection('reservations');

  Future addReservation(Reservation reservation, DateTime dateTime) async {
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
      'localPicture' : reservation.local.mainPhoto,
      'dateTime': dateTime
    });
  }

  updateReservationStatus(Map<String, dynamic> data, String reservationId) {
    reservationCollection.document(reservationId).updateData(data);
  }

  Future<List<Reservation>> getReservationsHistory(String userId) async{
    List<Reservation> pastReservations = [];
    QuerySnapshot snapshot = await reservationCollection
        .where('person', isEqualTo: userId)
        .where("dateTime", isLessThan: new DateTime.now())
        .where("status", isEqualTo: ReservationStatus.ACCEPTED.index)
        .getDocuments();
    snapshot.documents.forEach((document) {
      Map<String, dynamic> data = document.data;
      Reservation reservation = _buildReservationEntity(document, data, userId);
      pastReservations.add(reservation);
    });
    return pastReservations;
  }

  Future<List<Reservation>> getFutureReservations(String userId) async{
    List<Reservation> futureReservations = [];
    QuerySnapshot snapshot = await reservationCollection
        .where('person', isEqualTo: userId)
        .where("dateTime", isGreaterThanOrEqualTo: new DateTime.now())
        .where("status", isEqualTo: ReservationStatus.ACCEPTED.index)
        .getDocuments();
    snapshot.documents.forEach((document) {
      Map<String, dynamic> data = document.data;
      Reservation reservation = _buildReservationEntity(document, data, userId);
      futureReservations.add(reservation);
    });
    return futureReservations;
  }

  Reservation _buildReservationEntity(DocumentSnapshot document, Map<String, dynamic> data, String userId) {
    Reservation reservation = Reservation();
    reservation.id = document.documentID;
    reservation.numberPeople = data['numberPeople'];
    reservation.date = data['resDate'];
    reservation.time = data['resTime'];
    Local local = Local(mainPhoto: data['localPicture'], name: data['localName']);
    reservation.local = local;
    reservation.user = User(uid:  userId, firstName: data['firstName'], lastName: data['lastName']);
    return reservation;
  }
}
