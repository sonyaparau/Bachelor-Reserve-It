import 'package:flutter/material.dart';

class Criteria {
  DateTime date;
  TimeOfDay time;
  int numberPeople;
  List<String> preferences;

  Criteria(this.date, this.time, this.numberPeople, this.preferences);
}