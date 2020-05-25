import 'package:flutter/material.dart';
import 'package:reserve_it_app/models/user.dart';
import 'package:reserve_it_app/screens/screenUtils/user_choice.dart';
import 'package:reserve_it_app/screens/update_user_data_dialog.dart';
import 'package:reserve_it_app/screens/update_user_data_helper.dart';
import 'package:reserve_it_app/services/authentication_service.dart';

class ProfileScreen extends StatelessWidget {
  User currentUser;

  ProfileScreen(User user) {
    this.currentUser = user;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: UserChoice.userChoice.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: Text('Personal information'),
          centerTitle: true,
          bottom: TabBar(
            isScrollable: true,
            tabs: UserChoice.userChoice.map<Widget>((UserChoice choice) {
              return Tab(text: choice.title, icon: Icon(choice.icon));
            }).toList(),
          ),
        ),
        body: TabBarView(
          children: UserChoice.userChoice.map((UserChoice userChoice) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Choice(
                userChoice: userChoice,
                currentUser: currentUser,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class Choice extends StatelessWidget {
  final UserChoice userChoice;
  final User currentUser;

  Choice({Key key, this.userChoice, this.currentUser}) {
//    super(key: key);
//    _authService.getUser().then((value) => _currentUser = value);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.headline4;
    if (userChoice.title == 'Your profile') {
      return _buildTabUser(context);
    }
    return Card(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(userChoice.icon, size: 150.0, color: textStyle.color),
            Text(
              userChoice.title,
              style: textStyle,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTabUser(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 15,
        ),
        AuthService.urlProfilePhoto != null
            ? CircleAvatar(
                backgroundImage: NetworkImage(AuthService.urlProfilePhoto),
                radius: 60.0,
                backgroundColor: Colors.white,
              )
            : Icon(Icons.account_circle, size: 120, color: Colors.grey),
        SizedBox(
          height: 25,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                Icons.edit,
                color: Colors.redAccent,
                size: 30,
              ),
              onPressed: () {
                UpdateUserDialogHelper.update(
                    context, currentUser);
              },
            ),
            _buildTextName(),
          ],
        ),
        SizedBox(
          height: 30,
        ),
        _buildRowEmail(),
        SizedBox(
          height: 15,
        ),
        _buildRowNumber(),
      ],
    );
  }

  Row _buildRowNumber() {
    List<Widget> rowElements = [];
    if (currentUser.phone != null) {
      rowElements = [
        Icon(
          Icons.smartphone,
          color: Colors.redAccent,
          size: 25,
        ),
        SizedBox(
          width: 5,
        ),
        Text(currentUser.phone,
            style: TextStyle(
                fontSize: 20, color: Colors.grey, fontWeight: FontWeight.bold)),
      ];
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: rowElements,
    );
  }

  Row _buildRowEmail() {
    List<Widget> rowElements = [];
    if (currentUser.email != null) {
      rowElements = [
        Icon(
          Icons.alternate_email,
          color: Colors.redAccent,
          size: 25,
        ),
        SizedBox(
          width: 5,
        ),
        Text(currentUser.email,
            style: TextStyle(
                fontSize: 20, color: Colors.grey, fontWeight: FontWeight.bold)),
      ];
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: rowElements,
    );
  }

  Text _buildTextName() {
    String name = '';
    if (currentUser.firstName != null) {
      name += currentUser.firstName + ' ';
    }
    if (currentUser.lastName != null) {
      name += currentUser.lastName;
    }
    if (name.isNotEmpty) {
      return Text(name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25));
    } else {
      return Text('Complete your name',
          style: TextStyle(fontSize: 25));
    }
  }

  Widget _buildTabFavourites() {}

  Widget _buildTabFutureReservations() {}

  Widget _buildTabPastReservations() {}
}
