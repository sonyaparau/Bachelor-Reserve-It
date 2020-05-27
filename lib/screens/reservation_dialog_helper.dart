import 'package:flutter/material.dart';
import 'package:reserve_it_app/models/local.dart';
import 'package:reserve_it_app/models/user.dart';
import 'package:reserve_it_app/screens/reservation_dialog.dart';

/*
* Returns a dialog which contains a form
* with the data needed for making a reservation.
* */
class ReservationDialogHelper {
  static reserve(context, Local local, User user) {
    return showDialog(
        context: context,
        builder: (context) =>
            ReservationDialog(reservedLocal: local, user: user));
  }
}
