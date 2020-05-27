import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reserve_it_app/models/current_location.dart';
import 'package:reserve_it_app/models/local.dart';
import 'package:reserve_it_app/models/reservation.dart';
import 'package:reserve_it_app/models/user.dart';
import 'package:reserve_it_app/screens/screenUtils/custom_widgets.dart';
import 'package:reserve_it_app/screens/screenUtils/user_choice.dart';
import 'package:reserve_it_app/screens/update_user_data_helper.dart';
import 'package:reserve_it_app/services/authentication_service.dart';

class ProfileScreen extends StatelessWidget {
  User currentUser;
  List<Local> favouriteLocals;
  List<Reservation> pastReservations;
  List<Reservation> futureReservations;

  ProfileScreen(
      User user,
      List<Local> favouriteLocals,
      List<Reservation> pastReservations,
      List<Reservation> futureReservations) {
    this.currentUser = user;
    this.favouriteLocals = favouriteLocals;
    this.pastReservations = pastReservations;
    this.futureReservations = futureReservations;
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
                  pastReservations: pastReservations,
                  futureReservations: futureReservations),
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
  final List<Reservation> pastReservations;
  final List<Reservation> futureReservations;
  bool _locationEnabled = false;
  var _userLocation;

  Choice(
      {Key key,
      this.userChoice,
      this.currentUser,
      this.favouriteLocals,
      this.pastReservations,
      this.futureReservations});

  @override
  Widget build(BuildContext context) {
    setUserLocation(context);
    final TextStyle textStyle = Theme.of(context).textTheme.headline4;
    if (userChoice.title == 'Favourite locals') {
      return _buildTabFavourites(context);
    }
    if (userChoice.title == 'Future reservations') {
      return _buildTabFutureReservations();
    }
    if (userChoice.title == 'Past reservations') {
      return _buildTabPastReservations();
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

  ListView buildListReservations(List<Reservation> reservations) {
    return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return buildReservationCard(reservations[index]);
        },
        itemCount: reservations.length);
  }

  Widget buildReservationCard(Reservation reservation) {
    return SingleChildScrollView(
        child: Container(
      child: Card(
        child: ListTile(
          leading: Image.network(reservation.local.mainPhoto,
              width: 90, fit: BoxFit.fitWidth),
          title: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Row(
                  children: [
                    Text(
                      'Reservation',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 1.0, bottom: 1.0),
                child: Row(children: [
                  Text('Place: ', style: TextStyle(fontSize: 18)),
                  Text(reservation.local.name,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 1.0, bottom: 1.0),
                child: Row(children: [
                  Text('Date: ', style: TextStyle(fontSize: 18)),
                  Text(reservation.date,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 1.0, bottom: 1.0),
                child: Row(children: [
                  Text('Time: ', style: TextStyle(fontSize: 18)),
                  Text(reservation.time,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 1.0, bottom: 1.0),
                child: Row(children: [
                  Text('Number of people: ', style: TextStyle(fontSize: 18)),
                  Text(reservation.numberPeople.toString(),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                ]),
              ),
            ],
          ),
          subtitle: Column(children: []),
        ),
      ),
    ));
  }

  void setUserLocation(BuildContext context) {
    _userLocation = Provider.of<CurrentUserLocation>(context);
    if (_userLocation != null) {
      _locationEnabled = true;
    }
  }

  Widget _buildTabFutureReservations() {
    return Scaffold(
      body: Center(
          child: new Container(
              width: 800,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(child: buildListReservations(futureReservations))
                  ]))),
    );
  }

  Widget _buildTabPastReservations() {
    return Scaffold(
      body: Center(
          child: new Container(
              width: 800,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(child: buildListReservations(pastReservations))
                  ]))),
    );
  }
}
