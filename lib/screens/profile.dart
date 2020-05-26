import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reserve_it_app/models/current_location.dart';
import 'package:reserve_it_app/models/local.dart';
import 'package:reserve_it_app/models/user.dart';
import 'package:reserve_it_app/screens/screenUtils/custom_widgets.dart';
import 'package:reserve_it_app/screens/screenUtils/user_choice.dart';
import 'package:reserve_it_app/screens/update_user_data_helper.dart';
import 'package:reserve_it_app/services/authentication_service.dart';

class ProfileScreen extends StatelessWidget {
  User currentUser;
  List<Local> favouriteLocals;

  ProfileScreen(User user, List<Local> favouriteLocals) {
    this.currentUser = user;
    this.favouriteLocals = favouriteLocals;
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
          actions: <Widget>[buildIconButtonProfile(context)],
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
                favouriteLocals: favouriteLocals,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /*
  * @return an IconButton for the user's profile
  * */
  IconButton buildIconButtonProfile(BuildContext context) {
    return IconButton(
      icon: AuthService.urlProfilePhoto != null
          ? new CircleAvatar(
              backgroundImage: NetworkImage(AuthService.urlProfilePhoto),
              radius: 15.0,
              backgroundColor: Colors.white,
            )
          : Icon(Icons.account_circle),
      onPressed: () async {
        await AuthService().getUser().then((value) => currentUser = value);
        UpdateUserDialogHelper.update(context, currentUser);
      },
    );
  }
}

class Choice extends StatelessWidget {
  final UserChoice userChoice;
  final User currentUser;
  final List<Local> favouriteLocals;
  bool _locationEnabled = false;
  var _userLocation;

  Choice({Key key, this.userChoice, this.currentUser, this.favouriteLocals}) {
//    super(key: key);
//    _authService.getUser().then((value) => _currentUser = value);
  }

  @override
  Widget build(BuildContext context) {
    setUserLocation(context);
    final TextStyle textStyle = Theme.of(context).textTheme.headline4;
    if (userChoice.title == 'Favourite locals') {
      return _buildTabFavourites(context);
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

  Widget _buildTabFavourites(BuildContext context) {
    return Scaffold(
      body: Center(
          child: new Container(
              width: 800,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(child: buildListViewRestaurants())
                  ]))),
    );
  }

  ListView buildListViewRestaurants() {
    return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return CustomWidgets().buildLocalCard(
              context, favouriteLocals[index], _locationEnabled);
        },
        itemCount: favouriteLocals.length);
  }

  void setUserLocation(BuildContext context) {
    _userLocation = Provider.of<CurrentUserLocation>(context);
    if (_userLocation != null) {
      _locationEnabled = true;
    }
  }

  Widget _buildTabFutureReservations() {}

  Widget _buildTabPastReservations() {}
}
