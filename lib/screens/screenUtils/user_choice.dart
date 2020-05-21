import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class UserChoice {
  final String title;
  final IconData icon;

  const UserChoice({this.title, this.icon});

  static List<UserChoice> userChoice = <UserChoice> [
    UserChoice(title: '   Your profile  ', icon: Icons.account_box),
    UserChoice(title: 'Favourite locals', icon: Icons.favorite),
    UserChoice(title: 'Future reservations', icon: Icons.date_range),
  ];
}
