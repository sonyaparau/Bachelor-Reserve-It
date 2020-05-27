import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reserve_it_app/enums/notification_type.dart';
import 'package:reserve_it_app/enums/reservation_status.dart';
import 'package:reserve_it_app/models/local.dart';
import 'package:reserve_it_app/models/notification.dart' as model;
import 'package:reserve_it_app/models/reservation.dart';
import 'package:reserve_it_app/models/user.dart';
import 'package:reserve_it_app/screens/locals.dart';
import 'package:reserve_it_app/screens/notification_view.dart';
import 'package:reserve_it_app/screens/profile.dart';
import 'package:reserve_it_app/services/authentication_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:reserve_it_app/services/local_service.dart';
import 'package:reserve_it_app/screens/screenUtils/custom_widgets.dart';
import 'package:reserve_it_app/services/notification_service.dart';
import 'package:reserve_it_app/services/device_service.dart';
import 'package:reserve_it_app/services/reservation_service.dart';

/*
* Dashboard Screen where the user can see his
* profile picture, his notifications or can log out
* from the application. He can also search for
* a specific restaurant or add his preferences to
* find some restaurants based on his preferences.
* */
class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final formKey = new GlobalKey<FormState>();
  final preferenceController = new TextEditingController();
  final CustomWidgets _utils = new CustomWidgets();
  final AuthService _authService = new AuthService();
  final LocalService _localService = new LocalService();
  final NotificationService _notificationService = new NotificationService();
  final ReservationService _reservationService = new ReservationService();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  int unreadNotifications = 0;
  User loggedUser;

  List<String> _preferences = [];
  List<dynamic> _foundLocals;

  bool _isCheckedPreference = false;

  //pre-filled location from the dropdown
  String _selectedLocation = 'Cluj-Napoca';

  //all available locations for the dropdown
  List<String> _locations = ['Cluj-Napoca', 'Sibiu', 'Oradea'];

  @override
  void dispose() {
    preferenceController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    DeviceService().getDeviceToken();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
//    initialize();
    _counterNotifications();
    return Scaffold(
      appBar: buildAppBar(),
      backgroundColor: Colors.white,
      resizeToAvoidBottomPadding: true,
      body: new Center(
        child: new Container(
          width: !kIsWeb ? 350 : 370,
          padding: new EdgeInsets.all(25.0),
          child: SingleChildScrollView(
            child: buildFormSearch(context),
          ),
        ),
      ),
    );
  }

  /*
  * @return Appbar of the dashboard containing
  * the logo, the name of the application, an
  * icon button for the profile, an icon button
  * for notifications and one for the logout.
  * */
  AppBar buildAppBar() {
    return AppBar(
      title: Row(
        children: <Widget>[
          Image.asset(
            'assets/app_logo.png',
            fit: BoxFit.contain,
            height: 32,
            color: Colors.blueGrey,
          ),
          Container(
              padding: const EdgeInsets.all(8.0), child: Text('ReserveIt'))
        ],
      ),
      backgroundColor: Colors.deepPurple,
      actions: <Widget>[
        buildIconButtonProfile(),
        buildStackIconNotification(),
        buildIconButtonLogout()
      ],
    );
  }

  /*
  * @return the form for searching a restaurant
  * */
  Form buildFormSearch(BuildContext context) {
    return new Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Discover and book \n       new places',
              style: TextStyle(fontSize: 30.0)),
          _utils.getHeightSizedBox(50.0),
          _utils.getWidthSizedBox(5.0),
          buildRowLocation(),
          _utils.getHeightSizedBox(12.0),
          buildRowPreferences(),
          _utils.getHeightSizedBox(10.0),
          buildRowPreferencesInput(),
          _utils.getHeightSizedBox(10.0),
          generateDynamicPreferences(),
          _utils.getHeightSizedBox(35.0),
          buildOutlineButtonSearch(context),
        ],
      ),
    );
  }

  /*
  * @return the row where the user can type in
  * all his preferences/ name of the restaurant
  * */
  Row buildRowPreferencesInput() {
    return Row(children: <Widget>[
      _utils.getWidthSizedBox(35.0),
      Container(
          width: 225,
          child: TextFormField(
              controller: preferenceController,
              style: TextStyle(color: Colors.grey),
              decoration: new InputDecoration(
                  hintText: !_isCheckedPreference
                      ? 'Eg. Restaurant, Pizza, Beer...'
                      : ''),
              onFieldSubmitted: (value) {
                if (preferenceController.text.toString().isNotEmpty &&
                    preferenceController.text !=
                        'Eg. Restaurant, Pizza, Beer...') {
                  setState(() {
                    _preferences.add(preferenceController.text.toString());
                  });
                  _isCheckedPreference = false;
                  preferenceController.text = '';
                }
              })),
      _utils.getWidthSizedBox(5.0)
    ]);
  }

  /*
  * @return the row with the question of the
  * user's preferences
  * */
  Row buildRowPreferences() {
    return Row(children: <Widget>[
      Icon(
        Icons.scatter_plot,
        size: 30.0,
        color: Colors.deepPurple,
      ),
      _utils.getWidthSizedBox(5.0),
      Text("What do you prefer?", style: TextStyle(fontSize: 20.0))
    ]);
  }

  /*
  * @return the row with the location selection
  * The city Cluj-Napoca is preselected when this
  * screen is opened
  * */
  Row buildRowLocation() {
    return Row(children: <Widget>[
      Icon(
        Icons.location_on,
        size: 30.0,
        color: Colors.deepPurple,
      ),
      _utils.getWidthSizedBox(5.0),
      Text('Location', style: TextStyle(fontSize: 20.0)),
      _utils.getWidthSizedBox(15.0),
      buildDropdownButtonLocation()
    ]);
  }

  /*
  * @return the button for the search
  * */
  OutlineButton buildOutlineButtonSearch(BuildContext context) {
    return OutlineButton(
      onPressed: () {
        setState(() {
          _preferences.isEmpty
              ? searchAfterLocation(context)
              : searchAfterLocationAndPreferences(context);
        });
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Let\'s go',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /*
  * @return the dropdown with all possible locations
  * */
  DropdownButton<String> buildDropdownButtonLocation() {
    return DropdownButton<String>(
        items: _locations.map((String val) {
          return new DropdownMenuItem<String>(
            value: val,
            child: Text(
              val,
              style: TextStyle(fontSize: 20.0),
            ),
          );
        }).toList(),
        hint: Text(_selectedLocation),
        onChanged: (newVal) {
          _selectedLocation = newVal;
          this.setState(() {});
        });
  }

  /*
  * Searches for locations based on the user's preferences.
  * */
  void searchAfterLocationAndPreferences(BuildContext context) {
    LocalService()
        .getFilteredLocals(_preferences, _selectedLocation)
        .then((value) {
      _foundLocals = value;
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => LocalsScreen(foundLocals: _foundLocals)));
    });
  }

  /*
  * When the user has no preferences, then all the search is based only
  * on the location selected in the dropdown.
  * */
  void searchAfterLocation(BuildContext context) {
    if (_selectedLocation.isNotEmpty) {
      LocalService().getLocalsAfterLocation(_selectedLocation).then((value) {
        _foundLocals = value;
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => LocalsScreen(foundLocals: _foundLocals)));
      });
    } else {
      LocalService().getLocals().then((value) {
        _foundLocals = value;
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => LocalsScreen(foundLocals: _foundLocals)));
      });
    }
  }

  /*
  * @return an IconButton for the logout
  * dialog
  * */
  IconButton buildIconButtonLogout() {
    return IconButton(
      icon: Icon(Icons.exit_to_app),
      onPressed: () {
        logoutDialog();
      },
    );
  }

  Stack buildStackIconNotification() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          child: new IconButton(
            icon: new Icon(
              Icons.notifications,
              size: 35,
            ),
            onPressed: () {
              _checkReservations();
            },
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Container(
            width: 20,
            height: 20,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: Colors.red),
            child: Center(
              child: Text(
                unreadNotifications.toString(),
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /*
  * @return an IconButton for the user's profile
  * */
  IconButton buildIconButtonProfile() {
    return IconButton(
      icon: AuthService.urlProfilePhoto != null
          ? new CircleAvatar(
              backgroundImage: NetworkImage(AuthService.urlProfilePhoto),
              radius: 15.0,
              backgroundColor: Colors.white,
            )
          : Icon(Icons.account_circle),
      onPressed: () async {
        List<Local> favouriteLocals = [];
        List<Reservation> pastReservations = [];
        List<Reservation> futureReservations = [];
        await _getFavouriteLocals().then((locals) => favouriteLocals = locals);
        await _reservationService
            .getReservationsHistory(loggedUser.uid)
            .then((reservation) => pastReservations = reservation);
        await _reservationService
            .getFutureReservations(loggedUser.uid)
            .then((reservation) => futureReservations = reservation);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ProfileScreen(loggedUser, favouriteLocals, pastReservations, futureReservations)));
      },
    );
  }

  Future<List<Local>> _getFavouriteLocals() async {
    List<String> localIds = loggedUser.favouriteLocals;
    LocalService localService = LocalService();
    List<Local> locals = [];
    for (String localId in localIds) {
      if (localId != null) {
        await localService
            .findLocalAfterId(localId)
            .then((local) => locals.add(local));
      }
    }
    return locals;
  }

  /*
  * Popup Dialog showed when a user presses
  * the button 'Logout'. The user has the option
  * to confirm the logout or to cancel it.
  * */
  void logoutDialog() {
    _utils.getPopup(
        'Logout',
        'Are you sure you want to log out from the application?',
        context,
        [getOkButton("Yes"), getCancelButton("No")]);
  }

  /*
   * Generates a list of dynamic preferences
   * introduced by the user. The user can also
   * delete any chip and add as many chips as he wants.
   * */
  Wrap generateDynamicPreferences() {
    return Wrap(
      spacing: 5.0,
      children: List<Widget>.generate(_preferences.length, (int index) {
        return Chip(
          label:
              Text(_preferences[index], style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.deepPurple,
          padding: EdgeInsets.all(3.0),
          deleteIcon: Icon(Icons.clear, color: Colors.white, size: 15.0),
          onDeleted: (() {
            setState(
              () {
                _preferences.removeAt(index);
              },
            );
          }),
        );
      }),
    );
  }

  /*
  * Returns an Ok button for the logout.
  * */
  Widget getOkButton(String text) {
    return new FlatButton(
      child: new Text(text),
      onPressed: () {
        Navigator.of(context).pop();
        _authService.signOut();
      },
    );
  }

  /*
  * Returns a cancel button for the logout.
  * */
  Widget getCancelButton(String text) {
    return new FlatButton(
      child: new Text(text),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  Future initialize() async {
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      print('onMessage $message');
      _serializeAndNavigate(message);
    }, onResume: (Map<String, dynamic> message) async {
      print('onResume $message');
      _serializeAndNavigate(message);
    }, onLaunch: (Map<String, dynamic> message) async {
      print('onLaunch $message');
      _serializeAndNavigate(message);
    });
  }

  _serializeAndNavigate(Map<String, dynamic> message) {
    _counterNotifications();
    final notification = message['notification'];
    final data = message['data'];
    final String title = notification['title'];
    if (title == 'New reservation') {
      String message = _createMessageNewReservation(data);
      model.Notification notificationReservation = model.Notification();
      notificationReservation.message = message;
      notificationReservation.reservationId = data['reservationId'];
      notificationReservation.restaurantId = data['restaurantId'];
      notificationReservation.type = NotificationType.REQUEST.index;
      notificationReservation.status = ReservationStatus.PENDING.index;
      _notificationService
          .addNewNotificationReservation(notificationReservation);
    }
    if (title == 'Reservation accepted') {
      String message = _createMessageResponseReservation(data);
      model.Notification notificationReservation = model.Notification();
      notificationReservation.message = message;
      notificationReservation.reservationId = data['reservationId'];
      notificationReservation.restaurantId = data['restaurantId'];
      notificationReservation.userId = data['personId'];
      notificationReservation.localName = data['localName'];
      notificationReservation.localPicture = data['localPicture'];
      notificationReservation.type = NotificationType.RESPONSE.index;
      notificationReservation.status = ReservationStatus.ACCEPTED.index;
      _notificationService
          .addNewNotificationReservation(notificationReservation);
    }
    if (title == 'Reservation declined') {
      String message = _createMessageResponseReservation(data);
      model.Notification notificationReservation = model.Notification();
      notificationReservation.message = message;
      notificationReservation.reservationId = data['reservationId'];
      notificationReservation.restaurantId = data['restaurantId'];
      notificationReservation.userId = data['personId'];
      notificationReservation.localName = data['localName'];
      notificationReservation.localPicture = data['localPicture'];
      notificationReservation.type = NotificationType.RESPONSE.index;
      notificationReservation.status = ReservationStatus.DECLINED.index;
      _notificationService
          .addNewNotificationReservation(notificationReservation);
    }
  }

  String _createMessageNewReservation(data) {
    String message = '';
    message +=
        'A new reservation has been made \nwith the following information: \n';
    message += "\n";
    message += 'Name: ';
    message += data['fName'];
    message += ' ';
    message += data['lName'];
    message += "\n";
    message += 'Mobile number: ';
    message += data['number'];
    message += "\n";
    message += 'Date: ';
    message += data['reservationDate'];
    message += "\n";
    message += 'Time: ';
    message += data['reservationTime'];
    message += "\n";
    message += 'Number of people: ';
    message += data['nbPeople'];
    return message;
  }

  String _createMessageResponseReservation(data) {
    String message = data['message'];
    message += "\n";
    message += "\n";
    message += 'Local: ';
    message += data['localName'];
    message += "\n";
    message += 'Date: ';
    message += data['date'];
    message += "\n";
    message += 'Time: ';
    message += data['time'];
    return message;
  }

  _checkReservations() async {
    Local local;
    List<model.Notification> notifications = [];
    await _authService.getUser().then((user) => loggedUser = user);
    if (loggedUser.phone != null) {
      await _localService
          .searchLocalByPhoneNumber(loggedUser.phone)
          .then((restaurant) => local = restaurant);
      //restaurant owner
      if (local != null) {
        await _notificationService
            .findUnrespondedNotificationsForLocal(local.id)
            .then((notificationList) => notifications = notificationList);
      }
      //client notification
      else {
        if (loggedUser.uid != null) {
          await _notificationService
              .findNotificationsForUser(loggedUser.uid)
              .then((notificationList) => notifications = notificationList);
        }
      }
    }
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            NotificationsScreen(notifications: notifications)));
  }

  //TODO REFACTOR
  _counterNotifications() async {
    Local local;
    List<model.Notification> notifications = [];
    int counter = 0;
    await _authService.getUser().then((user) => loggedUser = user);
    if (loggedUser.phone != null) {
      await _localService
          .searchLocalByPhoneNumber(loggedUser.phone)
          .then((restaurant) => local = restaurant);
      //restaurant owner
      if (local != null) {
        await _notificationService
            .findUnrespondedNotificationsForLocal(local.id)
            .then((notificationList) => notifications = notificationList);
      }
      //client notification
      else {
        if (loggedUser.uid != null) {
          await _notificationService
              .findNotificationsForUser(loggedUser.uid)
              .then((notificationList) => notifications = notificationList);
        }
      }
    }
    notifications.forEach((notification) {
      //local administrator
      if (notification.type == 0 && notification.status == 0) {
        counter++;
      }
      //user
      if (notification.type == 1 && !notification.read) {
        counter++;
      }
    });
    setState(() {
      return unreadNotifications = counter;
    });
  }
}
