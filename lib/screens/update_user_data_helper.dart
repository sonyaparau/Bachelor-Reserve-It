import 'package:flutter/material.dart';
import 'package:reserve_it_app/models/user.dart';
import 'package:reserve_it_app/screens/update_user_data_dialog.dart';

class UpdateUserDialogHelper {
  static update(context, User user) {
    return showDialog(
        context: context,
        builder: (context) =>
            UpdateUserDialog(user: user));
  }
}