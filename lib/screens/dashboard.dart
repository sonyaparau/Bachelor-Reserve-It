import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reserve_it_app/services/auth.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('Reserve It'), backgroundColor: Colors.deepPurple, actions: <Widget>[
            IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () {
              },
            ),
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                AuthService().signOut();
              },
            )
          ],),
      backgroundColor: Colors.white,
    );
  }
}
