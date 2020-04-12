import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

/*
* Class with useful methods for creating
* costom Flutter Widgets for the screens
* of the application.
* */
class CustomWidgets {
  /*
  * Returns a sized box for the height
  * between two objects.
  * */
  Widget getHeightSizedBox(height) {
    return SizedBox(height: height);
  }

  /*
  * Returns a sized box for the width
  * between two objects.
  * */
  Widget getWitdthSizedBox(width) {
    return SizedBox(width: width);
  }

  /*
  * Returns a custom Popup based on a given
  * title, text and list of containing buttons.
  * */
  getPopup(String title, String text, context, List<Widget> buttons) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: <Widget>[
              Image.asset('assets/app_logo.png',
                  fit: BoxFit.contain, height: 32),
              SizedBox(width: 2.0),
              new Text(title)
            ],
          ),
          content: new Text(text),
          actions: buttons,
        );
      },
    );
  }
}
