import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reserve_it_app/enums/reservation_status.dart';
import 'package:reserve_it_app/models/notification.dart' as model;
import 'package:reserve_it_app/screens/screenUtils/custom_widgets.dart';
import 'package:reserve_it_app/services/notification_service.dart';
import 'package:reserve_it_app/services/reservation_service.dart';

class NotificationsScreen extends StatefulWidget {
  final List<model.Notification> notifications;

  NotificationsScreen({Key key, @required this.notifications})
      : super(key: key);

  @override
  _NotificationsScreenState createState() =>
      _NotificationsScreenState(notifications);
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<model.Notification> notifications;
  CustomWidgets _customWidgets = CustomWidgets();
  final ReservationService _reservationService = ReservationService();
  final NotificationService _notificationService = NotificationService();

  _NotificationsScreenState(this.notifications);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: Text('Notifications'),
          centerTitle: true,
        ),
        resizeToAvoidBottomPadding: true,
        body: notifications.length > 0
            ? Center(
                child: new Container(
                    width: 800,
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(child: buildListViewRestaurants())
                        ])))
            : Center(child: buildContainerEmptyListView()));
  }

  ListView buildListViewRestaurants() {
    return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return buildCard(index);
        },
        itemCount: notifications.length);
  }

  Container buildContainerEmptyListView() {
    return Container(
        child:
            Text('No new notifications ☹️', style: TextStyle(fontSize: 20.0)));
  }

  Widget buildCard(int index) {
    if (notifications[index].localPicture != null) {
      return SingleChildScrollView(
          child: Container(
        child: Card(
          child: ListTile(
            leading: Image.network(notifications[index].localPicture,
                width: 90, fit: BoxFit.fitWidth),
            onTap: () {
              setState(() {
                if (!notifications[index].read) {
                  _updateReadStatus(notifications[index].id);
                }
              });
            },
            title: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Row(
                    children: [
                      _getNotificationItem(index),
                      SizedBox(
                        width: 5,
                      ),
                      _getNotificationTitle(index)
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 1.0, bottom: 1.0),
                  child: Row(children: [
                    Expanded(
                      child: Text(notifications[index].message,
                          style: TextStyle(fontSize: 18, color: Colors.black)),
                    ),
                  ]),
                ),
                buildRowAcceptDecline(index),
              ],
            ),
          ),
        ),
      ));
    } else {
      return SingleChildScrollView(
          child: Container(
        child: Card(
          child: ListTile(
            title: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: new Row(
                    children: [
                      _getNotificationItem(index),
                      SizedBox(
                        width: 5,
                      ),
                      _getNotificationTitle(index)
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 1.0, bottom: 1.0),
                  child: Row(children: [
                    Expanded(
                      child: Text(notifications[index].message,
                          style: TextStyle(fontSize: 18, color: Colors.black)),
                    ),
                  ]),
                ),
                buildRowAcceptDecline(index),
              ],
            ),
          ),
        ),
      ));
    }
  }

  Widget _getNotificationItem(int index) {
    //pending
    if (notifications[index].status == 0) {
      return Icon(Icons.notifications, color: Colors.redAccent);
    }
    //accepted
    if (notifications[index].status == 1) {
      return Icon(Icons.check, color: Colors.green);
    }
    //declined
    if (notifications[index].status == 2) {
      return Icon(Icons.close, color: Colors.redAccent);
    }
    return Icon(Icons.help, color: Colors.redAccent);
  }

  Row buildRowAcceptDecline(int index) {
    List<Widget> buttons = [];
    if (notifications[index].type == 0) {
      buttons = [
        SizedBox(
          width: 270,
        ),
        IconButton(
          icon: Icon(
            Icons.check_box,
            color: Colors.green,
            size: 30,
          ),
          onPressed: () {
            setState(() {
              _acceptReservation(index);
            });
          },
        ),
        IconButton(
          icon: Icon(
            Icons.cancel,
            color: Colors.redAccent,
            size: 30,
          ),
          onPressed: () {
            setState(() {
              _cancelReservation(index);
            });
          },
        ),
      ];
    }
    return Row(
      children: buttons,
    );
  }

  Widget _getNotificationTitle(int index) {
    bool notificationRead = notifications[index].read;
    if (notifications[index].type == 0) {
      return Text(
        'New Reservation',
        style: TextStyle(
            fontSize: 22,
            fontWeight: notificationRead ? FontWeight.normal : FontWeight.bold),
      );
    } else {
      //accepted
      if (notifications[index].status == 1) {
        return Text(
          'Reservation accepted',
          style: TextStyle(
              fontSize: 22,
              fontWeight:
                  notificationRead ? FontWeight.normal : FontWeight.bold),
        );
      }
      //declined
      if (notifications[index].status == 2) {
        return Text(
          'Reservation declined',
          style: TextStyle(
              fontSize: 22,
              fontWeight:
                  notificationRead ? FontWeight.normal : FontWeight.bold),
        );
      }
    }
  }

  void _cancelReservation(int index) {
    _updateStatusNotification(false, notifications[index].id);
    _updateReservation(false, notifications[index].reservationId);
    notifications.removeAt(index);
    _customWidgets.getPopup(
        'Reservation canceled',
        'The reservation was successfully canceled! The user will be soon notified!',
        context,
        [_okButtonResponseDialog()]);
  }

  FlatButton _okButtonResponseDialog() {
    return new FlatButton(
        child: new Text("OK"),
        onPressed: () {
          Navigator.of(context).pop();
        });
  }

  void _acceptReservation(int index) {
    _updateStatusNotification(true, notifications[index].id);
    _updateReservation(true, notifications[index].reservationId);
    notifications.removeAt(index);
    _customWidgets.getPopup(
        'Reservation created',
        'The reservation was successfully saved! The user will be soon notified!',
        context,
        [_okButtonResponseDialog()]);
  }

  _updateReservation(bool confirmed, String reservationId) {
    Map<String, dynamic> updateData = _generateUpdateData(confirmed);
    _reservationService.updateReservationStatus(updateData, reservationId);
  }

  _updateStatusNotification(bool confirmed, String notificationId) {
    Map<String, dynamic> updateData = _generateUpdateData(confirmed);
    _notificationService.updateNotification(notificationId, updateData);
  }

  Map<String, dynamic> _generateUpdateData(bool confirmed) {
    Map<String, dynamic> updateData = Map<String, dynamic>();
    if (confirmed) {
      updateData.putIfAbsent('status', () => ReservationStatus.ACCEPTED.index);
    } else {
      updateData.putIfAbsent('status', () => ReservationStatus.DECLINED.index);
    }
    return updateData;
  }

  _updateReadStatus(String notificationId) {
    Map<String, dynamic> updateData = Map<String, dynamic>();
    updateData.putIfAbsent('read', () => true);
    _notificationService.updateNotification(notificationId, updateData);
  }
}
