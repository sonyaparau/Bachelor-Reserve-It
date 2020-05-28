import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reserve_it_app/models/notification.dart';

/*
* Service for the entity Notification.
* */
class NotificationService {
  //notification collection
  final CollectionReference notificationCollection =
      Firestore.instance.collection('notifications');

  /*
  * Creates a new document for the notification
  * entity and saves it in the database to the
  * notifications collection
  * */
  Future addNotification(Notification notification) async {
    return await notificationCollection.document().setData({
      'message': notification.message,
      'restaurantId': notification.restaurantId,
      'status': notification.status,
      'reservationId': notification.reservationId,
      'userId': notification.userId,
      'localName': notification.localName,
      'localPicture': notification.localPicture,
      'read': false,
      'type': notification.type
    });
  }

  /*
  * Updates a notification based on the data
  * provided in the map.
  * */
  updateNotification(String id, Map<String, dynamic> data) {
    notificationCollection.document(id).updateData(data);
  }

  /*
  * Returns all the reservations for a local that have no
  * response.
  * status 0: pending
  * type 0: request
  * */
  Future<List<Notification>> findUnrespondedNotificationsForLocal(
      String localId) async {
    List<Notification> notifications = [];
    QuerySnapshot snapshot = await notificationCollection
        .where('restaurantId', isEqualTo: localId)
        .getDocuments();
    snapshot.documents.forEach((element) {
      Map<String, dynamic> data = element.data;
      if (data.containsKey('status') && data.containsKey('type')) {
        if (data['type'] == 0 && data['status'] == 0) {
          Notification notification = new Notification();
          notification.message = data['message'];
          notification.reservationId = data['reservationId'];
          notification.status = data['status'];
          notification.read = data['read'];
          notification.id = element.documentID;
          notification.type = data['type'];
          notifications.add(notification);
        }
      }
    });
    return notifications;
  }

  /*
  * Returns all the unread notifications for a specific
  * user found by id.
  * */
  Future<List<Notification>> findNotificationsForUser(String userId) async {
    List<Notification> notifications = [];
    QuerySnapshot snapshot = await notificationCollection
        .where('userId', isEqualTo: userId)
        .getDocuments();
    snapshot.documents.forEach((element) {
      Map<String, dynamic> data = element.data;
      if (data.containsKey('status') && data.containsKey('read')) {
        //restaurant new reservation
        if ((data['status'] == 1 || data['status'] == 2) && data['read'] == false) {
          Notification notification = new Notification();
          notification.message = data['message'];
          notification.reservationId = data['reservationId'];
          notification.localPicture = data['localPicture'];
          notification.localName = data['localName'];
          notification.id = element.documentID;
          notification.type = data['type'];
          notification.read = data['read'];
          notification.status = data['status'];
          notifications.add(notification);
        }
      }
    });
    return notifications;
  }
}
