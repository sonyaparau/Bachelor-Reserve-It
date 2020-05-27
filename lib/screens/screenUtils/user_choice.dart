import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/*
* Choices for the user profile which
* contains more tabs.
* */
class UserChoice {
  final String title;
  final IconData icon;

  const UserChoice({this.title, this.icon});

  static List<UserChoice> userChoice = <UserChoice> [
    UserChoice(title: 'Favourite locals', icon: Icons.favorite),
    UserChoice(title: 'Future reservations', icon: Icons.date_range),
    UserChoice(title: 'Past reservations', icon: Icons.history),
  ];
}
