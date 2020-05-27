import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reserve_it_app/models/user.dart';
import 'package:reserve_it_app/screens/screenUtils/custom_widgets.dart';
import 'package:reserve_it_app/screens/screenUtils/input_validators.dart';
import 'package:reserve_it_app/services/authentication_service.dart';
import 'package:reserve_it_app/services/user_service.dart';

/*
* Dialog displaying the data of a
* user and the option of updating the
* provided profile information. Is displayed,
* only if the user is not anonymous.
* */
class UpdateUserDialog extends StatefulWidget {
  //current logged user
  final User user;

  UpdateUserDialog({Key key, @required this.user}) : super(key: key);

  @override
  _UpdateUserDialogState createState() => _UpdateUserDialogState(this.user);
}

class _UpdateUserDialogState extends State<UpdateUserDialog> {
  final formKey = new GlobalKey<FormState>();
  CustomWidgets _customWidgets = CustomWidgets();

  //current user from the database
  User _user;

  //fields which might contain the updated information
  String _firstName;
  String _lastName;
  String _email;
  String _phone;

  _UpdateUserDialogState(this._user);

  /*
  * @return the Dialog with the user
  * information.
  * */
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

  /*
  * @return the form with the user information
  * */
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
                      decoration: _buildBoxDecorationDialog(),
                      child: Column(
                          children: <Widget>[
                        _buildPaddingCloseOption(context),
                        _buildImageDialog(),
                        _customWidgets.getHeightSizedBox(10.0),
                        _buildTextTitleDialog(),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                              width: 180,
                              child: _buildTextFormFieldFirstName()),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                              width: 180, child: _buildTextFormFieldLastName()),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                              width: 180, child: _buildTextFormFieldEmail()),
                        ),
                        _buildAlignTextFieldPhone(),
                        _customWidgets.getHeightSizedBox(15.0),
                        Padding(
                          padding: const EdgeInsets.only(left: 200.0),
                          child: _buildFlatButtonUpdate(context),
                        ),
                      ].where((element) => element != null).toList()))
                ].where((element) => element != null).toList())));
  }

  /*
  * @return widget containing the phone
  * number of the user
  * */
  Align _buildAlignTextFieldPhone() {
    return _user.phone == null
        ? Align(
            alignment: Alignment.center,
            child: Container(width: 180, child: _buildTextFormFieldPhone()),
          )
        : null;
  }

  /*
  * @return the photo of the user. If no photo
  * is provided, then a default photo is displayed.
  * */
  StatelessWidget _buildImageDialog() {
    return AuthService.urlProfilePhoto != null
        ? CircleAvatar(
            backgroundImage: NetworkImage(AuthService.urlProfilePhoto),
            radius: 40.0,
            backgroundColor: Colors.white,
          )
        : Icon(Icons.account_circle, size: 120, color: Colors.grey);
  }

  /*
  * @return BoxDecoration which ensures the
  * round corners of the dialog
  * */
  BoxDecoration _buildBoxDecorationDialog() {
    return BoxDecoration(
      color: Colors.white,
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.all(Radius.circular(12)),
    );
  }

  /*
  * @return the button for updating the 
  * information from the profile
  * */
  FlatButton _buildFlatButtonUpdate(BuildContext context) {
    return FlatButton(
      color: Colors.deepPurple,
      child: Text(
        'Update profile',
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        if (validateInput()) {
          _updateProfile();
          Navigator.of(context).pop();
          _customWidgets.getPopup('Profile updated',
              'The profile has been successfully updated!', context, []);
        }
      },
    );
  }

  /*
  * @return the textfield containing the phone number
  * of the user
  * */
  TextFormField _buildTextFormFieldPhone() {
    return new TextFormField(
      initialValue: _user.phone != null ? _user.phone : '',
      keyboardType: TextInputType.number,
      decoration: new InputDecoration(
          labelText: 'Phone number', labelStyle: TextStyle(fontSize: 15)),
      validator: (value) {
        if (value.isEmpty) return 'Phone number is required!';
        //todo validate
        return null;
      },
      onSaved: (value) => _phone = value,
    );
  }

  /*
  * @return the textfield containing the email
  * of the user
  * */
  TextFormField _buildTextFormFieldEmail() {
    return new TextFormField(
      initialValue: _user.email != null ? _user.email : '',
      keyboardType: TextInputType.text,
      decoration: new InputDecoration(
          labelText: 'Email', labelStyle: TextStyle(fontSize: 15)),
      validator: (value) {
        if (value.isEmpty) return 'Email is required!';
        //TODO validate email
        return null;
      },
      onSaved: (value) => _email = value,
    );
  }

  /*
  * @return the textfield containing the last name
  * of the user
  * */
  TextFormField _buildTextFormFieldLastName() {
    return new TextFormField(
      initialValue: _user.lastName != null ? _user.lastName : '',
      keyboardType: TextInputType.text,
      decoration: new InputDecoration(
          labelText: 'Last name', labelStyle: TextStyle(fontSize: 15)),
      validator: (value) {
        if (value.isEmpty) return 'Last name is required!';
        if (!InputValidators.validateName(value)) return 'Invalid name format!';
        return null;
      },
      onSaved: (value) => _lastName = value,
    );
  }

  /*
  * @return the textfield containing the first name
  * of the user
  * */
  TextFormField _buildTextFormFieldFirstName() {
    return new TextFormField(
      initialValue: _user.firstName != null ? _user.firstName : '',
      keyboardType: TextInputType.text,
      decoration: new InputDecoration(
          labelText: 'First name', labelStyle: TextStyle(fontSize: 15)),
      validator: (value) {
        if (value.isEmpty) return 'First name is required!';
        if (!InputValidators.validateName(value)) return 'Invalid name format!';
        return null;
      },
      onSaved: (value) => _firstName = value,
    );
  }

  /*
  * @return a text containing the
  * title of the dialog
  * */
  Text _buildTextTitleDialog() {
    return Text(
      'Profile information',
      style: TextStyle(fontSize: 25),
      textAlign: TextAlign.center,
    );
  }

  /*
  * @return a padding containing the button
  * for closing the dialog
  * */
  Padding _buildPaddingCloseOption(BuildContext context) {
    return Padding(
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
    );
  }

  /*
  * Validates the inputs of the form
  * @return true if it is validated
  * and false otherwise
  * */
  bool validateInput() {
    final form = formKey.currentState;

    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  /*
  * Updates the profile of the user
  * if the user makes some changes in the
  * dialog.
  * */
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
    if (updateData.length > 0) {
      UserService().updateUser(updateData, _user.uid);
    }
  }
}
