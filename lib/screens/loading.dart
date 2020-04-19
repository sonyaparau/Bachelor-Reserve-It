import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
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
                SizedBox(height: 250),
                SpinKitFadingCircle(
                  color: Colors.deepPurple,
                  size: 100.0,
                ),
                SizedBox(height: 20),
                Text('  Loading...',
                    style: TextStyle(fontSize: 30.0, color: Colors.grey))
              ],
            ),
          ),
        ));
  }
}
