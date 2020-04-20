import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:reserve_it_app/utils/custom_widgets.dart';

/*
* Loading screen for actions that
* take a while.
* */
class Loading extends StatelessWidget {
  CustomWidgets _customWidgets = CustomWidgets();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
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
        )),
        body: Container(
          color: Colors.white,
          child: Center(
            child: new Column(
              children: [
                _customWidgets.getHeightSizedBox(250.0),
                SpinKitFadingCircle(
                  color: Colors.deepPurple,
                  size: 100.0,
                ),
                _customWidgets.getHeightSizedBox(20.0),
                Text('  Loading...',
                    style: TextStyle(fontSize: 30.0, color: Colors.grey))
              ],
            ),
          ),
        ));
  }
}
