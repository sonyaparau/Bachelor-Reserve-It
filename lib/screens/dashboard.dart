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
      body: Center(
        child: RaisedButton(
          child: Text('Sign Out'),
          onPressed: () {
            AuthService().signOut();
          },
        ),
      ),
    );
  }
}