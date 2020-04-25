import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reserve_it_app/screens/locals.dart';
import 'package:reserve_it_app/services/authentication_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:reserve_it_app/services/local_service.dart';
import 'package:reserve_it_app/screens/screenUtils/custom_widgets.dart';

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
  final prefereceController = new TextEditingController();
  final CustomWidgets _utils = new CustomWidgets();

  List<String> _preferences = [];
  List<dynamic> _foundLocals;

  bool _isCheckedPreference = false;

  //pre-filled location from the dropdown
  String _selectedLocation = 'Cluj-Napoca';

  //all available locations for the dropdown
  List<String> _locations = ['Cluj-Napoca', 'Sibiu', 'Oradea'];

  @override
  void dispose() {
    prefereceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        buildIconButtonNotification(),
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
          Text('Reserve your table',
              style: TextStyle(fontSize: 30.0)),
          _utils.getHeightSizedBox(50.0),
          _utils.getWitdthSizedBox(5.0),
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
      _utils.getWitdthSizedBox(35.0),
      Container(width: 225, child: TextFormField(
          controller: prefereceController,
          style: TextStyle(color: Colors.grey),
          decoration: new InputDecoration(
              hintText:
              !_isCheckedPreference ? 'Eg. Restaurant, Pizza, Beer...' : ''),
          onFieldSubmitted: (value) {
            if (prefereceController.text.toString().isNotEmpty &&
                prefereceController.text != 'Eg. Restaurant, Pizza, Beer...') {
              setState(() {
                _preferences.add(prefereceController.text.toString());
              });
              _isCheckedPreference = false;
              prefereceController.text = '';
            }
          })),
      _utils.getWitdthSizedBox(5.0)
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
      _utils.getWitdthSizedBox(5.0),
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
      _utils.getWitdthSizedBox(5.0),
      Text('Location', style: TextStyle(fontSize: 20.0)),
      _utils.getWitdthSizedBox(15.0),
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
    LocalService().getFilteredLocals(_preferences, _selectedLocation).then((value) {
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
    if(_selectedLocation.isNotEmpty) {
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

  /*
  * @return an IconButton for the notifications
  * */
  IconButton buildIconButtonNotification() {
    return IconButton(
      icon: Icon(Icons.notifications),
      onPressed: () {},
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
      onPressed: () {},
    );
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
        AuthService().signOut();
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
}
