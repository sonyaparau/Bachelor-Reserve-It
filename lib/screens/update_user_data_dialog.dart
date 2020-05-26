import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reserve_it_app/models/user.dart';
import 'package:reserve_it_app/screens/screenUtils/custom_widgets.dart';
import 'package:reserve_it_app/screens/screenUtils/input_validators.dart';
import 'package:reserve_it_app/services/authentication_service.dart';
import 'package:reserve_it_app/services/user_service.dart';

class UpdateUserDialog extends StatefulWidget {
  final User user;

  UpdateUserDialog({Key key, @required this.user}) : super(key: key);

  @override
  _UpdateUserDialogState createState() => _UpdateUserDialogState(this.user);
}

class _UpdateUserDialogState extends State<UpdateUserDialog> {
  final formKey = new GlobalKey<FormState>();
  User _user;
  String _firstName;
  String _lastName;
  String _email;
  String _phone;
  CustomWidgets _customWidgets = CustomWidgets();

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
                        AuthService.urlProfilePhoto != null
                            ? CircleAvatar(
                          backgroundImage: NetworkImage(AuthService.urlProfilePhoto),
                          radius: 40.0,
                          backgroundColor: Colors.white,
                        )
                            : Icon(Icons.account_circle, size: 120, color: Colors.grey),
                        SizedBox(height: 10,),
                        Text(
                          'Profile information',
                          style: TextStyle(fontSize: 25),
                          textAlign: TextAlign.center,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                              width: 180,
                              child: new TextFormField(
                                initialValue: _user.firstName != null ? _user.firstName : '',
                                keyboardType: TextInputType.text,
                                decoration: new InputDecoration(
                                    labelText: 'First name',
                                    labelStyle: TextStyle(fontSize: 15)),
                                validator: (value) {
                                  if (value.isEmpty)
                                    return 'First name is required!';
                                  if (!InputValidators.validateName(
                                      value))
                                    return 'Invalid name format!';
                                  return null;
                                },
                                onSaved: (value) => _firstName = value,
                              )),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                              width: 180,
                              child: new TextFormField(
                                initialValue: _user.lastName != null ? _user.lastName : '',
                                keyboardType: TextInputType.text,
                                decoration: new InputDecoration(
                                    labelText: 'Last name',
                                    labelStyle: TextStyle(fontSize: 15)),
                                validator: (value) {
                                  if (value.isEmpty)
                                    return 'Last name is required!';
                                  if (!InputValidators.validateName(
                                      value))
                                    return 'Invalid name format!';
                                  return null;
                                },
                                onSaved: (value) => _lastName = value,
                              )),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                              width: 180,
                              child: new TextFormField(
                                initialValue: _user.email != null ? _user.email : '',
                                keyboardType: TextInputType.text,
                                decoration: new InputDecoration(
                                    labelText: 'Email',
                                    labelStyle: TextStyle(fontSize: 15)),
                                validator: (value) {
                                  if (value.isEmpty)
                                    return 'Email is required!';
                                 //TODO validate email
                                  return null;
                                },
                                onSaved: (value) => _email = value,
                              )),
                        ),
                        _user.phone == null ? Align(
                          alignment: Alignment.center,
                          child: Container(
                              width: 180,
                              child: new TextFormField(
                                initialValue: _user.phone != null ? _user.phone : '',
                                keyboardType: TextInputType.number,
                                decoration: new InputDecoration(
                                    labelText: 'Phone number',
                                    labelStyle: TextStyle(fontSize: 15)),
                                validator: (value) {
                                  if (value.isEmpty)
                                    return 'Phone number is required!';
//                                  if (!InputValidators.validateName(
//                                      value))
//                                    return 'Invalid name format!';
                                  return null;
                                },
                                onSaved: (value) => _phone = value,
                              )),
                        ) : null,
                        SizedBox(
                          height: 15,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 200.0),
                          child: FlatButton(
                            color: Colors.deepPurple,
                            child: Text(
                              'Update profile',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              if (validateInput()) {
                                _updateProfile();
                                Navigator.of(context).pop();
                                _customWidgets.getPopup(
                                    'Profile updated',
                                    'The profile has been successfully updated!',
                                    context,
                                    []);
                              }
                            },
                          ),
                        ),
                      ].where((element) => element != null).toList()))
                ].where((element) => element != null).toList())));
  }

  bool validateInput() {
    final form = formKey.currentState;

    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  _updateProfile() async {
    Map<String, dynamic> updateData = Map<String, dynamic>();
    if (_firstName.isNotEmpty) {
      updateData.putIfAbsent('firstName', () => _firstName);
    }
    if (_lastName.isNotEmpty) {
      updateData.putIfAbsent('lastName', () => _lastName);
    }
    if (_phone != null && _phone.isNotEmpty) {
      updateData.putIfAbsent('phoneNumber', () => _phone);
    }
    if (_email.isNotEmpty) {
      updateData.putIfAbsent('email', () => _email);
    }
    UserService().updateUser(updateData, _user.uid);
  }
}
