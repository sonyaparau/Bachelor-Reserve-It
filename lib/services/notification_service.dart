import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reserve_it_app/enums/notification_type.dart';
import 'package:reserve_it_app/enums/reservation_status.dart';
import 'package:reserve_it_app/models/notification.dart';

class NotificationService {
  final CollectionReference notificationCollection =
      Firestore.instance.collection('notifications');

  Future addNewNotificationReservation(Notification notification) async {
    return await notificationCollection.document().setData({
      'message': notification.message,
      'restaurantId': notification.restaurantId,
      'status': ReservationStatus.PENDING.index,
      'reservationId': notification.reservationId,
      'read': false,
      'type': NotificationType.REQUEST.index
    });
  }

  Future<List<Notification>> findNewNotificationByLocalId(
      String localId) async {
    List<Notification> notifications = [];
    QuerySnapshot snapshot = await notificationCollection
        .where('restaurantId', isEqualTo: localId)
        .getDocuments();
    snapshot.documents.forEach((element) {
      Map<String, dynamic> data = element.data;
      if (data.containsKey('status')) {
        if (data['status'] == 0) {
          Notification notification = new Notification();
          notification.message = data['message'];
          notification.reservationId = data['reservationId'];
          notification.id = element.documentID;
          notification.type = data['type'];
          notifications.add(notification);
        }
      }
    });
    return notifications;
  }

  updateNotificationStatus(String id, Map<String, dynamic> data) {
    notificationCollection.document(id).updateData(data);
  }
}
