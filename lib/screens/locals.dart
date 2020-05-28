import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:reserve_it_app/models/local.dart';
import 'package:reserve_it_app/models/current_location.dart';
import 'package:reserve_it_app/screens/map.dart';
import 'package:reserve_it_app/screens/search.dart';
import 'package:reserve_it_app/screens/screenUtils/custom_widgets.dart';

/*
* Contains the ListView with all the
* found restaurants.
* */
class LocalsScreen extends StatefulWidget {
  final List<Local> foundLocals;

  LocalsScreen({Key key, @required this.foundLocals}) : super(key: key);

  @override
  _LocalsScreenState createState() => _LocalsScreenState(foundLocals);
}

class _LocalsScreenState extends State<LocalsScreen> {
  List<Local> _foundLocals;
  bool _locationEnabled = false;
  var _userLocation;

  CustomWidgets _customWidgets = CustomWidgets();

  _LocalsScreenState(this._foundLocals);

  @override
  Widget build(BuildContext context) {
    setUserLocation(context);
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            buildIconButtonSearch(context),
            buildIconButtonMap(context)
          ],
        ),
        resizeToAvoidBottomPadding: true,
        body: _buildListView());
  }

  /*
  * Build a list view with the found locals. If there are no
  * locals, a text with the message will be displayed in the
  * center of the screen.
  * */
  Center _buildListView() {
    return _foundLocals.length > 0
        ? Center(
            child: new Container(
                width: 800,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(child: buildListViewLocals())
                    ])))
        : Center(child: buildContainerEmptyListView());
  }

  /*
  * Builds a container with a text message displayed
  * if there are no found locals.
  * */
  Container buildContainerEmptyListView() {
    return Container(
        child: Text('No local has been found ☹️',
            style: TextStyle(fontSize: 20.0)));
  }

  /*
  * Sets the user location if the user shared
  * its location.
  * */
  void setUserLocation(BuildContext context) {
    _userLocation = Provider.of<CurrentUserLocation>(context);
    if (_userLocation != null) {
      _locationEnabled = true;
    }
  }

  /*
  * Builds a ListView with the found locals.
  * Each local will be displayed on a card.
  * */
  ListView buildListViewLocals() {
    return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return _customWidgets.buildLocalCard(
              context, _foundLocals[index], _locationEnabled);
        },
        itemCount: _foundLocals.length);
  }

  /*
  * Builds an IconButton for opening the 
  * Google Maps to view the found locals 
  * on the maps.
  * */
  IconButton buildIconButtonMap(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.map),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => Map(locals: _foundLocals)));
        });
  }

  /*
  * Builds an IconButton for opening 
  * searching locals after its name.
  * */
  IconButton buildIconButtonSearch(BuildContext context) {
    List<String> searchLocals = [];
    _foundLocals.forEach((local) {
      searchLocals.add(local.name);
    });
    return IconButton(
        icon: Icon(Icons.search),
        onPressed: () {
          showSearch(
              context: context,
              delegate:
                  LocalSearch(_locationEnabled, searchLocals, _foundLocals));
        });
  }
}
