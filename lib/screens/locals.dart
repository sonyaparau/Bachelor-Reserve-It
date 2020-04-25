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
  List<Local> foundLocals;

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
        body: _foundLocals.length > 0
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

  Container buildContainerEmptyListView() {
    return Container(
        child: Text('No table has been found ☹️',
            style: TextStyle(fontSize: 20.0)));
  }

  void setUserLocation(BuildContext context) {
    _userLocation = Provider.of<CurrentUserLocation>(context);
    if (_userLocation != null) {
      _locationEnabled = true;
    }
  }

  ListView buildListViewRestaurants() {
    return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return _customWidgets.buildLocalCard(
              context, _foundLocals[index], _locationEnabled);
        },
        itemCount: _foundLocals.length);
  }

  IconButton buildIconButtonMap(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.map),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => Map(locals: _foundLocals)));
        });
  }

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
