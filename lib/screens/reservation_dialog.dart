import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reserve_it_app/enums/reservation_status.dart';
import 'package:reserve_it_app/models/local.dart';
import 'package:reserve_it_app/models/reservation.dart';
import 'package:reserve_it_app/models/user.dart';
import 'package:reserve_it_app/screens/screenUtils/custom_widgets.dart';
import 'package:reserve_it_app/screens/screenUtils/input_validators.dart';
import 'package:reserve_it_app/services/authentication_service.dart';
import 'package:reserve_it_app/services/device_service.dart';
import 'package:reserve_it_app/services/reservation_service.dart';
import 'package:reserve_it_app/services/user_service.dart';

class ReservationDialog extends StatefulWidget {
  final Local reservedLocal;
  final User user;

  ReservationDialog(
      {Key key, @required this.reservedLocal, @required this.user})
      : super(key: key);

  @override
  _ReservationDialogState createState() =>
      _ReservationDialogState(this.reservedLocal, this.user);
}

class _ReservationDialogState extends State<ReservationDialog> {
  final formKey = new GlobalKey<FormState>();
  CustomWidgets _customWidgets = CustomWidgets();
  final DeviceService _deviceService = DeviceService();
  Local _reservedLocal;
  User _loggedUser;

  String _firstName;
  String _lastName;
  String _phoneNumber;
  String _numberPeople;
  DateTime _date;
  TimeOfDay _time;

  _ReservationDialogState(this._reservedLocal, this._loggedUser) {}

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: _buildChild(context));
  }

  Widget _buildChild(BuildContext context) {
    return SingleChildScrollView(
        child: new Form(
            key: formKey,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 400,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 280),
                          child: IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.black,
                              size: 25,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                        Image(
                          image: AssetImage("assets/app_logo.png"),
                          height: 100.0,
                          width: 100.0,
                        ),
                        Text(
                          'Make a reservation',
                          style: TextStyle(fontSize: 25),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 5.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.scatter_plot,
                              size: 15,
                              color: Colors.deepPurple,
                            ),
                            SizedBox(width: 5.0),
                            Text(
                              _reservedLocal.name,
                              style: TextStyle(fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        SizedBox(height: 15.0),
                        _loggedUser.firstName == null
                            ? Align(
                                alignment: Alignment.center,
                                child: Container(
                                    width: 180,
                                    child: new TextFormField(
                                      keyboardType: TextInputType.text,
                                      decoration: new InputDecoration(
                                          labelText: 'First name',
                                          labelStyle: TextStyle(fontSize: 15)),
                                      validator: (value) {
                                        if (value.isEmpty)
                                          return 'First name is required!';
                                        if (!InputValidators.validateName(
                                            value))
                                          return 'Invalid name format!';
                                        return null;
                                      },
                                      onSaved: (value) => _firstName = value,
                                    )),
                              )
                            : null,
                        _loggedUser.lastName == null
                            ? Align(
                                alignment: Alignment.center,
                                child: Container(
                                    width: 180,
                                    child: new TextFormField(
                                      keyboardType: TextInputType.text,
                                      decoration: new InputDecoration(
                                          labelText: 'Last name',
                                          labelStyle: TextStyle(fontSize: 15)),
                                      validator: (value) {
                                        if (value.isEmpty)
                                          return 'Last name is required!';
                                        if (!InputValidators.validateName(
                                            value))
                                          return 'Invalid name format!';
                                        return null;
                                      },
                                      onSaved: (value) => _lastName = value,
                                    )),
                              )
                            : null,
                        _loggedUser.phone == null
                            ? Align(
                                alignment: Alignment.center,
                                child: Container(
                                    width: 180,
                                    child: new TextFormField(
                                      keyboardType: TextInputType.phone,
                                      decoration: new InputDecoration(
                                          labelText: 'Phone number',
                                          labelStyle: TextStyle(fontSize: 15)),
                                      validator: (value) {
                                        if (value.isEmpty)
                                          return 'Phone number is required!';
                                        if (value.trim().length == 10 &&
                                            !InputValidators.phoneValidator
                                                .hasMatch(value.trim()))
                                          return 'Invalid number format!';
                                        return null;
                                      },
                                      onSaved: (value) => _phoneNumber = value,
                                    )),
                              )
                            : null,
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                              width: 180,
                              child: new TextFormField(
                                keyboardType: TextInputType.number,
                                decoration: new InputDecoration(
                                    labelText: 'Number of people',
                                    labelStyle: TextStyle(fontSize: 15)),
                                validator: (value) {
                                  if (value.isEmpty)
                                    return 'Number of people is required!';
                                  if (!InputValidators.validateNumberPersons(
                                      value))
                                    return 'Number must be greater than 0!';
                                  return null;
                                },
                                onSaved: (value) => _numberPeople = value,
                              )),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                              width: 180,
                              child: TextField(
                                readOnly: true,
                                decoration: new InputDecoration(
                                    hintText: _displayDate()),
                                onTap: () {
                                  showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime(2025))
                                      .then((value) {
                                    setState(() {
                                      _date = value;
                                    });
                                  });
                                },
                              )),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                              width: 180,
                              child: TextField(
                                readOnly: true,
                                decoration: new InputDecoration(
                                    hintText: _displayTime()),
                                onTap: () {
                                  showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now())
                                      .then((value) {
                                    setState(() {
                                      _time = value;
                                    });
                                  });
                                },
                              )),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 200.0),
                          child: FlatButton(
                            color: Colors.deepPurple,
                            child: Text(
                              'Reserve now',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              if (validateInput()) {
                                _makeReservation();
                                Navigator.of(context).pop();
                                _customWidgets.getPopup(
                                    'Reservation sent',
                                    'The request has been sent to the local. You will '
                                        'receive a notification as soon as the local responds '
                                        'to your request. Stay tuned!',
                                    context,
                                    []);
                              }
                            },
                          ),
                        ),
                      ].where((element) => element != null).toList(),
                    ),
                  )
                ])));
  }

  String _displayDate() {
    if (_date == null) {
      _date = DateTime.now();
      return DateTime.now().day.toString() +
          '.' +
          DateTime.now().month.toString() +
          '.' +
          DateTime.now().year.toString();
    } else {
      return _date.day.toString() +
          '.' +
          _date.month.toString() +
          '.' +
          _date.year.toString();
    }
  }

  String _displayTime() {
    if (_time == null) {
      int hour = DateTime.now().hour;
      int minute = DateTime.now().minute;
      _time = TimeOfDay.now();
      String hourStr;
      String minStr;
      if (hour < 10) {
        hourStr = '0' + hour.toString();
      } else {
        hourStr = hour.toString();
      }
      if (minute < 10) {
        minStr = '0' + minute.toString();
      } else {
        minStr = minute.toString();
      }
      return hourStr + ':' + minStr;
    } else {
      int hour = _time.hour;
      int minute = _time.minute;
      String hourStr;
      String minStr;
      if (hour < 10) {
        hourStr = '0' + hour.toString();
      } else {
        hourStr = hour.toString();
      }
      if (minute < 10) {
        minStr = '0' + minute.toString();
      } else {
        minStr = minute.toString();
      }
      return hourStr + ':' + minStr;
    }
  }

  bool validateInput() {
    final form = formKey.currentState;

    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  _makeReservation() async {
    _updateInformationUser();

    String deviceToken = '';
    String userDevice = '';
    await UserService()
        .findTokenUser(_reservedLocal.phoneNumber)
        .then((value) => deviceToken = value);
    await DeviceService().getDeviceToken().then((token) => userDevice = token);
    Reservation reservation = Reservation(
        user: _loggedUser,
        local: _reservedLocal,
        status: ReservationStatus.PENDING,
        date: _displayDate(),
        time: _displayTime(),
        numberPeople: int.parse(_numberPeople),
        deviceToSend: deviceToken,
        userDevice: userDevice);
    ReservationService().addReservation(reservation);
  }

  _updateInformationUser() async {
    Map<String, dynamic> updateData = Map<String, dynamic>();
    if (_loggedUser.firstName == null) {
      updateData.putIfAbsent('firstName', () => _firstName);
      _loggedUser.firstName = _firstName;
    }
    if (_loggedUser.lastName == null) {
      updateData.putIfAbsent('lastName', () => _lastName);
      _loggedUser.lastName = _lastName;
    }
    if (_loggedUser.phone == null) {
      updateData.putIfAbsent('phoneNumber', () => _phoneNumber);
      _loggedUser.phone = _phoneNumber;
    }
    if (updateData.isNotEmpty) {
      bool isAnon;
      await AuthService().isAnonymousUser().then((value) => isAnon = value);
      if (!isAnon) {
        UserService().updateUser(updateData, _loggedUser.uid);
      }
    }
  }
}
