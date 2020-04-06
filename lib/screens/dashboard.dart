import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reserve_it_app/services/auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final formKey = new GlobalKey<FormState>();

  DateTime date;
  TimeOfDay time;
  List<String> preferences = [];
  final prefereceController = TextEditingController();
  final numberController = TextEditingController();

  bool _isCheckedPreference = false;
  bool _validateDate = false;
  bool _validateTime = false;
  bool _validateNb = false;

  RegExp _nbPeopleValidator = new RegExp(
    r"[1-9][0-9]*",
    caseSensitive: false,
    multiLine: false,
  );

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    prefereceController.dispose();
    numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[Image.asset('assets/app_logo.png', fit: BoxFit.contain,
            height: 32, color: Colors.white,),  Container(
              padding: const EdgeInsets.all(8.0), child: Text('ReserveIt'))],
        ),
        backgroundColor: Colors.deepPurple,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              logoutDialog();
            },
          )
        ],
      ),
      backgroundColor: Colors.white,
      resizeToAvoidBottomPadding: true,
      body: new Center(
        child: new Container(
            width: !kIsWeb ? 350 : 370,
            padding: new EdgeInsets.all(6.0),
            child: SingleChildScrollView(
                child: new Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text('Find your table for \n     any occasion',
                            style: TextStyle(fontSize: 30.0)),
                        SizedBox(height: 50),
                        Wrap(children: <Widget>[
                          Row(children: <Widget>[
                            Icon(Icons.calendar_today, size: 35.0),
                            SizedBox(width: 5.0),
                            Text("Date", style: TextStyle(fontSize: 20.0)),
                            SizedBox(width: 12.0),
                            Container(
                                width: 200,
                                child: TextField(
                                  readOnly: true,
                                  decoration: new InputDecoration(
                                      hintText: date == null
                                          ? 'No date chosen'
                                          : date.toLocal().day.toString() +
                                              "." +
                                              date.toLocal().month.toString() +
                                              "." +
                                              date.toLocal().year.toString(),
                                      errorText: _validateDate
                                          ? 'Date is required!'
                                          : null),
                                  onTap: () {
                                    showDatePicker(
                                            context: context,
                                            initialDate: date == null
                                                ? DateTime.now()
                                                : date,
                                            firstDate: DateTime.now(),
                                            lastDate: DateTime(2025))
                                        .then((value) {
                                      setState(() {
                                        date = value;
                                      });
                                    });
                                  },
                                ))
                          ])
                        ]),
                        SizedBox(height: 10),
                        Wrap(children: <Widget>[
                          Row(children: <Widget>[
                            Icon(
                              Icons.access_time,
                              size: 35.0,
                            ),
                            SizedBox(width: 5.0),
                            Text("Time", style: TextStyle(fontSize: 20.0)),
                            SizedBox(width: 10.0),
                            Container(
                                width: 200,
                                child: TextField(
                                  readOnly: true,
                                  decoration: new InputDecoration(
                                      hintText: time == null
                                          ? 'No hour chosen'
                                          : time.hour.toString() +
                                              ':' +
                                              time.minute.toString(),
                                      errorText: _validateTime
                                          ? 'Time is required!'
                                          : null),
                                  onTap: () {
                                    showTimePicker(
                                      context: context,
                                      initialTime:
                                          time == null ? TimeOfDay.now() : time,
                                    ).then((value) {
                                      setState(() {
                                        time = value;
                                      });
                                    });
                                  },
                                ))
                          ])
                        ]),
                        SizedBox(height: 10),
                        Wrap(children: <Widget>[
                          Row(children: <Widget>[
                            Icon(
                              Icons.people_outline,
                              size: 35.0,
                            ),
                            SizedBox(width: 5.0),
                            Text("Number people",
                                style: TextStyle(fontSize: 20.0)),
                            SizedBox(width: 12.0),
                            Container(
                                width: 105,
                                child: TextField(
                                    controller: numberController,
                                    readOnly: false,
                                    keyboardType: TextInputType.number,
                                    decoration: new InputDecoration(
                                        errorText: _validateNb
                                            ? 'Number is required!'
                                            : null),
                                    style: TextStyle(color: Colors.grey)))
                          ])
                        ]),
                        SizedBox(height: 10),
                        Wrap(children: <Widget>[
                          Row(children: <Widget>[
                            Icon(
                              Icons.scatter_plot,
                              size: 35.0,
                            ),
                            SizedBox(width: 5.0),
                            Text("What do you prefer?",
                                style: TextStyle(fontSize: 20.0))
                          ])
                        ]),
                        SizedBox(
                          height: 10,
                        ),
                        Wrap(children: <Widget>[
                          Row(children: <Widget>[
                            Container(
                                width: 270,
                                child: TextFormField(
                                    controller: prefereceController,
                                    style: TextStyle(color: Colors.grey),
                                    decoration: new InputDecoration(
                                        hintText: !_isCheckedPreference
                                            ? 'Eg. Pizza, Beer, Desserts...'
                                            : ''))),
                            SizedBox(
                              width: 5.0,
                            ),
                            IconButton(
                              icon: Icon(Icons.check),
                              onPressed: () {
                                if (prefereceController.text
                                        .toString()
                                        .isNotEmpty &&
                                    prefereceController.text !=
                                        'Eg. Pizza, Beer, Desserts...') {
                                  setState(() {
                                    preferences.add(
                                        prefereceController.text.toString());
                                  });
                                  _isCheckedPreference = false;
                                  prefereceController.text = '';
                                }
                              },
                            ),
                          ])
                        ]),
                        SizedBox(height: 10.0),
                        generateDynamicPreferences(),
                        SizedBox(height: 35.0),
                        new OutlineButton(
                            splashColor: Colors.grey,
                            onPressed: () {
                              setState(() {
                                date == null
                                    ? _validateDate = true
                                    : _validateDate = false;
                                time == null
                                    ? _validateTime = true
                                    : _validateTime = false;
                                _nbPeopleValidator.hasMatch(
                                        numberController.value.text.toString())
                                    ? _validateNb = false
                                    : _validateNb = true;
                              });
                              if (validateInput()) {
                                //TODO search for locals
                              }
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40)),
                            highlightElevation: 0,
                            borderSide: BorderSide(color: Colors.grey),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      'Let\'s go',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.grey),
                                    ),
                                  )
                                ],
                              ),
                            ))
                      ],
                    )))),
      ),
    );
  }

  /*
  * Popup Dialog showed when a user presses
  * the button 'Logout'. The user has the option
  * to confirm the logout or to cancel it.
  * */
  void logoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Logout"),
          content: new Text(
              "Are you sure you want to log out from the application?"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop();
                AuthService().signOut();
              },
            ),
            new FlatButton(
              child: new Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  /*
   * Generates a list of dynamic preferences
   * introduced by the user. The user can also
   * delete any chip and add as many chips as he wants.
   * */
  Wrap generateDynamicPreferences() {
    return Wrap(
      spacing: 5.0,
      children: List<Widget>.generate(preferences.length, (int index) {
        return Chip(
          label:
              Text(preferences[index], style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.deepPurple,
          padding: EdgeInsets.all(3.0),
          deleteIcon: Icon(Icons.clear, color: Colors.white, size: 15.0),
          onDeleted: (() {
            setState(() {
              preferences.removeAt(index);
            });
          }),
        );
      }),
    );
  }

  /*
  * Validates the input of the form.
  * Time and hour of the reservation are
  * mandatory. Number of people must be
  * greater than 0 and the preferences
  * are optional.
  * */
  bool validateInput() {
    final form = formKey.currentState;

    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }
}
