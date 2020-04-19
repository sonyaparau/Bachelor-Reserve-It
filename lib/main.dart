import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reserve_it_app/models/current_location.dart';
import 'package:reserve_it_app/services/authentication_service.dart';
import 'package:reserve_it_app/services/location_service.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<CurrentUserLocation>(
        create: (context) {
          return LocationService().locationStream;
        },
        child: MaterialApp(
          title: 'ReserveIt',
          theme: new ThemeData(primarySwatch: Colors.deepPurple),
          debugShowCheckedModeBanner: false,
          home: AuthService().handleAuthentication(),
        ));
//    return MaterialApp(
//      title: 'ReserveIt',
//      theme: new ThemeData(primarySwatch: Colors.deepPurple),
//      debugShowCheckedModeBanner: false,
//      home: AuthService().handleAuthentication(),
//    );
  }
}
