import 'package:flutter/material.dart';
import 'package:reserve_it_app/models/user.dart';

class UpdateUserDialog extends StatefulWidget {
  final User user;

  UpdateUserDialog({Key key, @required this.user}) : super(key: key);

  @override
  _UpdateUserDialogState createState() => _UpdateUserDialogState(this.user);
}

class _UpdateUserDialogState extends State<UpdateUserDialog> {
  final formKey = new GlobalKey<FormState>();
  User _user;

  _UpdateUserDialogState(this._user);

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: _buildChild(context));
  }

  _buildChild(BuildContext context) {
    return SingleChildScrollView(
        child: new Form(
            key: formKey,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      width: 400,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: Column(children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 280),
                          child: IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.black,
                              size: 25,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                        Image(
                          image: AssetImage("assets/app_logo.png"),
                          height: 100.0,
                          width: 100.0,
                        ),
                        Text(
                          'Make a reservation',
                          style: TextStyle(fontSize: 25),
                          textAlign: TextAlign.center,
                        ),
                      ]))
                ])));
  }
}
