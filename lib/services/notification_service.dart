import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:reserve_it_app/models/reservation_message.dart';
import 'package:reserve_it_app/screens/reservation_notification.dart';
import 'package:flutter/material.dart';

class NotificationService {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  Future<String> getDeviceToken() async{
    String deviceToken;
    await _firebaseMessaging.getToken().then((token) => deviceToken = token);
    return deviceToken;
  }
//
//  Future<String> getDeviceToken() async{
//    String deviceToken;
//    await _firebaseMessaging.getToken().then((token) => deviceToken = token);
//    return deviceToken;
//  }
//
//  Future initialize(BuildContext context) async {
//    if(Platform.isIOS) {
//      _firebaseMessaging.requestNotificationPermissions(IosNotificationSettings());
//    }
//
//    _firebaseMessaging.configure(
//      onMessage: (Map<String, dynamic> message) async {
//        print('onMessage $message');
//        _serializeAndNavigate(message, context);
//      },
//      onResume: (Map<String, dynamic> message) async {
//        print('onResume $message');
//        _serializeAndNavigate(message, context);
//      },
//      onLaunch: (Map<String, dynamic> message) async {
//        print('onLaunch $message');
//        _serializeAndNavigate(message, context);
//      }
//    );
//  }
//
//   ReservationNotificationScreen _serializeAndNavigate(Map<String, dynamic> message, BuildContext context) {
//     final notification = message['notification'];
//     final data = message['data'];
//     final String title = notification['title'];
//     final String body = notification['body'];
//     print('Message received!');
//    if(title == 'New reservation') {
//      final String text = data['message'];
//      final String userId = data['userId'];
//      final String reservationId = data['reservationId'];
//      print('received!');
//      Navigator.of(context).push(
//          MaterialPageRoute(
//              builder: (context) => ReservationNotificationScreen()
//          )
//      );
//      ReservationMessage reservationMessage = new ReservationMessage(title, body, text, reservationId, userId);
//      return ReservationNotificationScreen();
//    }

//  }
}