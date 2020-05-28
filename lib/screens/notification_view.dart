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
  //list with the unread notifications of the user
  List<model.Notification> notifications;
  CustomWidgets _customWidgets = CustomWidgets();
  final ReservationService _reservationService = ReservationService();
  final NotificationService _notificationService = NotificationService();

  _NotificationsScreenState(this.notifications);

  /*
  * Builds a Scaffold containing all the unread notifications
  * of the logged user and an AppBar
  * */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _buildAppBar(),
        resizeToAvoidBottomPadding: true,
        body: notifications.length > 0
            ? Center(
                child: new Container(
                    width: 800,
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(child: buildListViewNotifications())
                        ])))
            : Center(child: buildContainerEmptyListView()));
  }

  /*
  * @return the AppBar of the notifications
  * screen
  * */
  AppBar _buildAppBar() {
    return AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text('Notifications'),
        centerTitle: true,
      );
  }

  /*
  * @return the list view containing all
  * the unread notifications of a user
  * */
  ListView buildListViewNotifications() {
    return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return buildCard(index);
        },
        itemCount: notifications.length);
  }

  /*
  * @return container if there are 
  * no new notifications
  * */
  Container buildContainerEmptyListView() {
    return Container(
        child: Text('No new notifications ☹️',
            style: TextStyle(
              fontSize: 20.0,
            )));
  }

  /*
  * @return card based on the type of the user:
  * client or local
  * */
  Widget buildCard(int index) {
    if (notifications[index].localPicture != null) {
      return _buildScrollViewNotificationsLocal(index);
    } else {
      return _buildScrollViewNotificationsUser(index);
    }
  }

  /*
  * @return a ScrollView containing the notifications
  * for the local.
  * */
  SingleChildScrollView _buildScrollViewNotificationsLocal(int index) {
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
                    _customWidgets.getWidthSizedBox(5.0),
                    _getNotificationTitle(index)
                  ],
                ),
              ),
              _buildPaddingNotificationMessage(index),
              buildRowAcceptDecline(index),
            ],
          ),
        ),
      ),
    ));
  }

  /*
  * @return a ScrollView containing the notifications
  * for the user.
  * */
  SingleChildScrollView _buildScrollViewNotificationsUser(int index) {
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
                    _customWidgets.getWidthSizedBox(5.0),
                    _getNotificationTitle(index)
                  ],
                ),
              ),
              _buildPaddingNotificationMessage(index),
              buildRowAcceptDecline(index),
            ],
          ),
        ),
      ),
    ));
  }

  /*
  * @return a padding containing the row with
  * the message of the notification.
  * */
  Padding _buildPaddingNotificationMessage(int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 1.0, bottom: 1.0),
      child: Row(children: [
        Expanded(
          child: Text(notifications[index].message,
              style: TextStyle(fontSize: 18, color: Colors.black)),
        ),
      ]),
    );
  }

  /*
  * @return a corresponding icon based on the
  * status of the notification:
  *   0- pending reservation
  *   1- accepted reservation
  *   2- declined reservation
  * */
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

  /*
  * @return a row containing the buttons for
  * accepting/declining a reservation used
  * by a local.
  * */
  Row buildRowAcceptDecline(int index) {
    List<Widget> buttons = [];
    if (notifications[index].type == 0) {
      buttons = [
        _customWidgets.getWidthSizedBox(270.0),
        _buildIconButtonAccept(index),
        _buildIconButtonDecline(index),
      ];
    }
    return Row(
      children: buttons,
    );
  }

  /*
  * @return a button that the local can use
  * to decline a reservation.
  * */
  IconButton _buildIconButtonDecline(int index) {
    return IconButton(
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
    );
  }

  /*
  * @return a button that the local can use
  * to accept a reservation.
  * */
  IconButton _buildIconButtonAccept(int index) {
    return IconButton(
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
    );
  }

  /*
  * Sets a title to the notification based
  * on the type:
  *   0- new reservation
  *   1- reservation accepted
  *   2- reservation declined
  * */
  _getNotificationTitle(int index) {
    bool notificationRead = notifications[index].read;
    if (notifications[index].type == 0) {
      return _buildTitleNotification('New Reservation', notificationRead);
    } else {
      //accepted
      if (notifications[index].status == 1) {
        return _buildTitleNotification(
            'Reservation accepted', notificationRead);
      }
      //declined
      if (notifications[index].status == 2) {
        return _buildTitleNotification(
            'Reservation declined', notificationRead);
      }
    }
  }

  /*
  * @return a title with the title of the notification
  * */
  Text _buildTitleNotification(String text, bool notificationRead) {
    return Text(
      text,
      style: TextStyle(
          fontSize: 22,
          fontWeight: notificationRead ? FontWeight.normal : FontWeight.bold),
    );
  }

  /*
  * Updates the reservation status to declined and
  * shows a popup for the local to know that a notification
  * of the declined request was sent to the client.
  * */
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

  /*
  * @return a button with OK for the dialog.
  * When this is pressed, the dialog will be
  * closed.
  * */
  FlatButton _okButtonResponseDialog() {
    return new FlatButton(
        child: new Text("OK"),
        onPressed: () {
          Navigator.of(context).pop();
        });
  }

  /*
  * Updates the reservation status to accepted and
  * shows a popup for the local to know that a notification
  * of the accepted request was sent to the client.
  * */
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

  /*
  * Updates a reservation
  * */
  _updateReservation(bool confirmed, String reservationId) {
    Map<String, dynamic> updateData = _generateUpdateData(confirmed);
    _reservationService.updateReservation(updateData, reservationId);
  }

  /*
  * Updates the status of a notification in the database:
  * accepted or declined.
  * */
  _updateStatusNotification(bool confirmed, String notificationId) {
    Map<String, dynamic> updateData = _generateUpdateData(confirmed);
    _notificationService.updateNotification(notificationId, updateData);
  }

  /*
  * Updates the status of a reservation depending on the
  * response from the local: accepted or declined. The
  * change is saved in the database.
  * */
  Map<String, dynamic> _generateUpdateData(bool confirmed) {
    Map<String, dynamic> updateData = Map<String, dynamic>();
    if (confirmed) {
      updateData.putIfAbsent('status', () => ReservationStatus.ACCEPTED.index);
    } else {
      updateData.putIfAbsent('status', () => ReservationStatus.DECLINED.index);
    }
    return updateData;
  }

  /*
  * Updates the status of a notification to read = true
  * if the user click on it. The update is made in the
  * database.
  * */
  _updateReadStatus(String notificationId) {
    Map<String, dynamic> updateData = Map<String, dynamic>();
    updateData.putIfAbsent('read', () => true);
    _notificationService.updateNotification(notificationId, updateData);
  }
}
