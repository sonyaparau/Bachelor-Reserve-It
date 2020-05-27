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

/*
* Profile Screen containing tabs with
* favourite locations, future- and past
* reservations.
* */
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

  /*
  * Creates a Tab Controller for the tabs
  * of the screen.
  * */
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: UserChoice.userChoice.length,
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: _buildTabBarView(),
      ),
    );
  }

  /*
  * @return the AppBar of the profile screen.
  * */
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.deepPurple,
      title: Text('Personal information'),
      centerTitle: true,
      actions: <Widget>[buildIconButtonProfile(context)],
      bottom: _buildTabBar(),
    );
  }

  /*
  * @return a TabBar with the title and the corresponding
  * icon.
  * */
  TabBar _buildTabBar() {
    return TabBar(
      isScrollable: true,
      tabs: UserChoice.userChoice.map<Widget>((UserChoice choice) {
        return Tab(text: choice.title, icon: Icon(choice.icon));
      }).toList(),
    );
  }

  /*
  * @return the view of a given tab containing
  * the reservations and the favourite locals
  * of the logged user.
  * */
  TabBarView _buildTabBarView() {
    return TabBarView(
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

  /*
  * @return the screen for the corresponding
  * Tab depending on the choice of the user.
  * */
  @override
  Widget build(BuildContext context) {
    setUserLocation(context);
    final TextStyle textStyle = Theme.of(context).textTheme.headline4;
    if (userChoice.title == 'Favourite locals') {
      return _buildScreenFavourites(context, textStyle);
    }
    if (userChoice.title == 'Future reservations') {
      return _buildScreenFutureReservations(textStyle);
    }
    if (userChoice.title == 'Past reservations') {
      return _buildScreenPastReservations(textStyle);
    }
  }

  /*
  * @return the screen with the past reservations, if the
  * list is not empty. Otherwise, an empty card with the
  * corresponding text and icon is being displayed.
  * */
  Widget _buildScreenPastReservations(TextStyle textStyle) {
    if (futureReservations.isNotEmpty) {
      return _buildTabReservation(pastReservations);
    } else {
      String title = 'No past reservations';
      return _buildCardNoData(textStyle, userChoice.icon, title);
    }
  }

  /*
  * @return the screen with the future reservations, if the
  * list is not empty. Otherwise, an empty card with the
  * corresponding text and icon is being displayed.
  * */
  Widget _buildScreenFutureReservations(TextStyle textStyle) {
    if (futureReservations.isNotEmpty) {
      return _buildTabReservation(futureReservations);
    } else {
      String title = 'No future reservations';
      return _buildCardNoData(textStyle, userChoice.icon, title);
    }
  }

  /*
  * @return the screen with the favourite locals, if the
  * list is not empty. Otherwise, an empty card with the
  * corresponding text and icon is being displayed.
  * */
  Widget _buildScreenFavourites(BuildContext context, TextStyle textStyle) {
    if (favouriteLocals.isNotEmpty) {
      return _buildTabFavourites(context);
    } else {
      String title = 'No favourite locals';
      return _buildCardNoData(textStyle, userChoice.icon, title);
    }
  }

  /*
  * @return a card with an icon and a corresponding text that is
  * displayed on a tab which has no data.
  * */
  Card _buildCardNoData(TextStyle textStyle, IconData icon, String title) {
    return Card(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 100.0, color: textStyle.color),
            Text(
              title,
              style: textStyle,
            )
          ],
        ),
      ),
    );
  }

  /*
  * @return tab containing cards with the favourite
  * locals.
  * */
  Widget _buildTabFavourites(BuildContext context) {
    return Scaffold(
      body: Center(
          child: new Container(
              width: 800,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(child: buildListViewLocals())
                  ]))),
    );
  }

  /*
  * @return a ListView with cards containing
  * the favourite locals.
  * */
  ListView buildListViewLocals() {
    return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return CustomWidgets().buildLocalCard(
              context, favouriteLocals[index], _locationEnabled);
        },
        itemCount: favouriteLocals.length);
  }

  /*
  * @return a ListView with cards containing
  * the past/future reservations.
  * */
  ListView buildListReservations(List<Reservation> reservations) {
    return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return buildReservationCard(reservations[index]);
        },
        itemCount: reservations.length);
  }

  /*
  * @return a card with a reservation containing
  * a photo with the local, the name of the local,
  * the date and time of the reservation and the number
  * of people.
  * */
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
                child: _buildRowCardTitle(),
              ),
              _buildPaddingReservationInformation(
                  'Place: ', reservation.local.name),
              _buildPaddingReservationInformation(
                  'Date: ', reservation.date.toString()),
              _buildPaddingReservationInformation(
                  'Time: ', reservation.time.toString()),
              _buildPaddingReservationInformation(
                  'Number of people: ', reservation.numberPeople.toString()),
            ],
          ),
        ),
      ),
    ));
  }

  /*
  * @return a row containing the title of
  * a reservation for a card
  * */
  Row _buildRowCardTitle() {
    return Row(
      children: [
        Text(
          'Reservation',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple),
        )
      ],
    );
  }

  /*
  * @return a a padding containing information about
  * the reservation.
  * */
  Padding _buildPaddingReservationInformation(String text, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 1.0, bottom: 1.0),
      child: Row(children: [
        Text(text, style: TextStyle(fontSize: 18)),
        Text(value,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic)),
      ]),
    );
  }

  /*
  * Sets the current location of the user, if
  * the user has provided it. Otherwise, the
  * location is not enabled.
  * */
  void setUserLocation(BuildContext context) {
    _userLocation = Provider.of<CurrentUserLocation>(context);
    if (_userLocation != null) {
      _locationEnabled = true;
    }
  }

  /*
  * @return a screen with the reservations (future or past)
  * */
  Widget _buildTabReservation(List<Reservation> reservations) {
    return Scaffold(
      body: Center(
          child: new Container(
              width: 800,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(child: buildListReservations(reservations))
                  ]))),
    );
  }
}
