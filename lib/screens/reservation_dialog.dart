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

/*
* Dialog for making a reservation.
* */
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
  Local _reservedLocal;
  User _loggedUser;

  //Data needed for the reservation
  String _firstName;
  String _lastName;
  String _phoneNumber;
  String _numberPeople;
  DateTime _date;
  TimeOfDay _time;

  _ReservationDialogState(this._reservedLocal, this._loggedUser);

  /*
  * Build the dialog.
  * */
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

  /*
  * @return the form with the information needed
  * for making a reservation.
  * */
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
                          child: _buildButtonCloseDialog(context),
                        ),
                        _buildImageLogo(),
                        _buildTextTitle(),
                        _customWidgets.getHeightSizedBox(5.0),
                        _buildRowSelectedLocal(),
                        SizedBox(height: 15.0),
                        _buildWidgetFirstName(),
                        _buildWidgetLastName(),
                        _buildWidgetPhone(),
                        _buildWidgetNumberPeople(),
                        _buildWidgetDate(context),
                        _buildWidgetTime(context),
                        SizedBox(height: 15.0),
                        _buildWidgetReserveButton(context),
                      ].where((element) => element != null).toList(),
                    ),
                  )
                ])));
  }

  /*
  * Button for sending the request to the local
  * with the reservation. After sending it, a new
  * popup will be displayed showing a message with
  * a success message.
  * */
  Padding _buildWidgetReserveButton(BuildContext context) {
    return Padding(
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
    );
  }

  /*
  * @return a row of the dialog containing
  * a time picker for the reservation. The datepicker is initialized
  * with the current time.
  * */
  Align _buildWidgetTime(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
          width: 180,
          child: TextField(
            readOnly: true,
            decoration: new InputDecoration(hintText: _displayTime()),
            onTap: () {
              showTimePicker(context: context, initialTime: TimeOfDay.now())
                  .then((value) {
                setState(() {
                  _time = value;
                });
              });
            },
          )),
    );
  }

  /*
  * @return a row of the dialog containing
  * a date picker for the reservation. No past
  * date can e selected. The datepicker is initialized
  * with the current date.
  * */
  Align _buildWidgetDate(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
          width: 180,
          child: TextField(
            readOnly: true,
            decoration: new InputDecoration(hintText: _displayDate()),
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
    );
  }

  /*
  * @return a row of the dialog containing
  * a text form field for completing the 
  * number o people for the reservation. This
  * can contain only numbers greater than 0.
  * */
  Align _buildWidgetNumberPeople() {
    return Align(
      alignment: Alignment.center,
      child: Container(
          width: 180,
          child: new TextFormField(
            keyboardType: TextInputType.number,
            decoration: new InputDecoration(
                labelText: 'Number of people',
                labelStyle: TextStyle(fontSize: 15)),
            validator: (value) {
              if (value.isEmpty) return 'Number of people is required!';
              if (!InputValidators.validateNumberPersons(value))
                return 'Number must be greater than 0!';
              return null;
            },
            onSaved: (value) => _numberPeople = value,
          )),
    );
  }

  /*
  * @return a row of the dialog containing
  * a text form field for completing the phone
  * number, if this is provided in the
  * database for this user. Otherwise, this row
  * won't be displayed.
  * */
  Align _buildWidgetPhone() {
    return _loggedUser.phone == null
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
                    if (value.isEmpty) return 'Phone number is required!';
                    if (value.length != 10 || InputValidators.phoneValidator.allMatches(value).length != 1)
                      return 'Invalid number format!';
                    return null;
                  },
                  onSaved: (value) => _phoneNumber = value,
                )),
          )
        : null;
  }

  /*
  * @return a row of the dialog containing
  * a text form field for completing the last
  * name, if no last name is provided in the
  * database for this user. Otherwise, this row
  * won't be displayed.
  * */
  Align _buildWidgetLastName() {
    return _loggedUser.lastName == null
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
                    if (value.isEmpty) return 'Last name is required!';
                    if (!InputValidators.validateName(value))
                      return 'Invalid name format!';
                    return null;
                  },
                  onSaved: (value) => _lastName = value,
                )),
          )
        : null;
  }

  /*
  * @return a row of the dialog containing
  * a text form field for completing the first
  * name, if no first name is provided in the
  * database for this user. Otherwise, this row
  * won't be displayed.
  * */
  Align _buildWidgetFirstName() {
    return _loggedUser.firstName == null
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
                    if (value.isEmpty) return 'First name is required!';
                    if (!InputValidators.validateName(value))
                      return 'Invalid name format!';
                    return null;
                  },
                  onSaved: (value) => _firstName = value,
                )),
          )
        : null;
  }

  /*
  * @return a row of the dialog containing
  * the name of the selected local and a 
  * picture
  * */
  Row _buildRowSelectedLocal() {
    return Row(
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
    );
  }

  /*
  * @return the title of the dialog
  * */
  Text _buildTextTitle() {
    return Text(
      'Make a reservation',
      style: TextStyle(fontSize: 25),
      textAlign: TextAlign.center,
    );
  }

  /*
  * @return a button for closing the dialog
  * if the user wants to cancel sending a
  * reservation
  * */
  IconButton _buildButtonCloseDialog(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.close,
        color: Colors.black,
        size: 25,
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  /*
  * @returns the logo of the application that
  * will be displayed before the form
  * */
  Image _buildImageLogo() {
    return Image(
      image: AssetImage("assets/app_logo.png"),
      height: 100.0,
      width: 100.0,
    );
  }

  /*
  * @returns a string containing the
  * formatted date of the reservation that
  * will be saved in the database.
  * */
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

  /*
  * @returns a string containing the
  * formatted time of the reservation that
  * will be saved in the database.
  * */
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

  /*
  * Validates the inputs of the form
  * @return true if it is validated
  * and false otherwise
  * */
  bool validateInput() {
    final form = formKey.currentState;

    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  /*
  * Creates a new reservation based on the information
  * provided by the user in the form and adds it in the
  * database.
  * */
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
    DateTime dateTime =
        DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
    ReservationService().addReservation(reservation, dateTime);
  }

  /*
  * If the user provides new information about
  * him that is not yet stored in the database, then
  * the information will be saved, so that by the next
  * reservation the user must not enter the same
  * information again (first name, last name, phone
  * number)
  * */
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
