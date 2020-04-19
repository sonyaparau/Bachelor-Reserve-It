import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:reserve_it_app/models/local.dart';
import 'package:reserve_it_app/models/current_location.dart';
import 'package:reserve_it_app/screens/search.dart';
import 'package:reserve_it_app/utils/custom_widgets.dart';

class LocalsScreen extends StatefulWidget {
  List<Local> foundLocals;

  LocalsScreen({Key key, @required this.foundLocals}) : super(key: key);

  @override
  _LocalsScreenState createState() => _LocalsScreenState(foundLocals);
}

class _LocalsScreenState extends State<LocalsScreen> {
  List<Local> foundLocals;
  bool _locationEnabled = false;
  var _userLocation;

  CustomWidgets _customWidgets = CustomWidgets();

  _LocalsScreenState(this.foundLocals);

  @override
  Widget build(BuildContext context) {
    //TODO change implementation here
//    _userLocation = Provider.of<CurrentUserLocation>(context);
    if (_userLocation != null) {
      _locationEnabled = true;
    }
    return Scaffold(
        appBar: new AppBar(
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  List<String> searchLocals = [];
                  foundLocals.forEach((element) {
                    searchLocals.add(element.name);
                  });
                  showSearch(
                      context: context,
                      delegate: LocalSearch(
                          _locationEnabled, searchLocals, foundLocals));
                })
          ],
        ),
        resizeToAvoidBottomPadding: true,
        body: foundLocals.length > 0
            ? new Center(
                child: new Container(
                    width: 420,
                    child: new Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          new Expanded(
                              child: new ListView.builder(
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return _customWidgets.buildLocalCard(
                                        context,
                                        foundLocals[index],
                                        _locationEnabled);
                                  },
                                  itemCount: foundLocals.length))
                        ])))
            : new Center(
                child: new Container(
                    child: Text('No table has been found ☹️',
                        style: TextStyle(fontSize: 20.0)))));
  }
}
