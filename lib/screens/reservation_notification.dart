import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:reserve_it_app/models/reservation_message.dart';

class ReservationNotificationScreen extends StatefulWidget {
  @override
  _ReservationNotificationScreenState createState() => _ReservationNotificationScreenState();
}

class _ReservationNotificationScreenState extends State<ReservationNotificationScreen> {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  Widget build(BuildContext context) {
//    initialize();
    return Container(
      child: Text('New notification')
    );
  }


  Future initialize() async {
    if(Platform.isIOS) {
      _firebaseMessaging.requestNotificationPermissions(IosNotificationSettings());
    }

    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print('onMessage $message');
          _serializeAndNavigate(message);
        },
        onResume: (Map<String, dynamic> message) async {
          print('onResume $message');
          _serializeAndNavigate(message);
        },
        onLaunch: (Map<String, dynamic> message) async {
          print('onLaunch $message');
          _serializeAndNavigate(message);
        }
    );
  }

  ReservationNotificationScreen _serializeAndNavigate(Map<String, dynamic> message) {
    final notification = message['notification'];
    final data = message['data'];
    final String title = notification['title'];
    final String body = notification['body'];
    print('Message received!');
    if(title == 'New reservation') {
      final String text = data['message'];
      final String userId = data['userId'];
      final String reservationId = data['reservationId'];
      print('received!');
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ReservationNotificationScreen()
        ),
      );
    }
}
  }
