import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';
import 'package:rating_bar/rating_bar.dart';
import 'package:reserve_it_app/models/current_location.dart';
import 'package:reserve_it_app/models/local.dart';
import 'package:reserve_it_app/screens/local_details.dart';
import 'package:reserve_it_app/screens/reservation_dialog_helper.dart';
import 'package:reserve_it_app/services/authentication_service.dart';

/*
* Class with useful methods for creating
* custom Flutter Widgets used in multiple
* screens of the application.
* */
class CustomWidgets {
  double _km = -1;
  AuthService _authService = AuthService();

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
              getWitdthSizedBox(2.0),
              new Text(title)
            ],
          ),
          content: new Text(text),
          actions: buttons,
        );
      },
    );
  }

  /*
   * Returns a card with a restaurant containing
   * its name, the picture, type and the distance
   * between the user's current location and the
   * restaurant.
   * */
  Widget buildLocalCard(
      BuildContext context, Local local, bool locationEnabled) {
    final Distance distance = new Distance();
    if (locationEnabled) {
      var currentLocation = Provider.of<CurrentUserLocation>(context);
      _km = distance.as(
          LengthUnit.Meter,
          new LatLng(local.geoPoint.latitude, local.geoPoint.longitude),
          new LatLng(currentLocation.latitude, currentLocation.longitude));
    }

    return SingleChildScrollView(
        child: Container(
      child: Card(
        child: ListTile(
            leading:
                Image.network(local.mainPhoto, width: 90, fit: BoxFit.fitWidth),
            title: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Row(
                    children: [
                      Text(
                        local.name,
                        style: TextStyle(fontSize: 22),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 1.0, bottom: 1.0),
                  child: Row(children: [
                    getRatingBar(local.rating, 16.0),
                    Text(' • ' + local.type,
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 18,
                            color: Colors.black54)),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 1.0, bottom: 1.0),
                  child: Row(children: [
                    getWidgetsForLocation(locationEnabled, _km)[0],
                    getWidgetsForLocation(locationEnabled, _km)[1],
                    Spacer(),
                    RaisedButton(
                      color: Colors.deepPurple,
                      textColor: Colors.white,
                      child: Text(
                        'Reserve now',
                        style: TextStyle(fontSize: 12),
                      ),
                      onPressed: () {
                        if (local != null) {
                          _authService.getUser().then((user) =>
                              ReservationDialogHelper.reserve(
                                  context, local, user));
                        }
                      },
                    )
                  ]),
                )
              ],
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      LocalDetails(selectedLocal: local, distance: _km)));
            }),
      ),
    ));
  }

  /*
  * Returns a list of widgets containing the icon with
  * the enable/ disabled location and the distance between
  * the user's location and a restaurant. If the current
  * location of the user is not allowed, then an 'Unknown'
  * distance will be displayed.
  * */
  List<Widget> getWidgetsForLocation(bool locationEnabled, double distance) {
    if (locationEnabled) {
      distance /= 1000;
      return [
        Icon(Icons.location_on, size: 20, color: Colors.red),
        Text(distance.toStringAsFixed(1) + ' km',
            style: TextStyle(color: Colors.grey, fontSize: 15))
      ];
    } else {
      return [
        Icon(Icons.location_off, size: 20, color: Colors.red),
        Text(
          'unknown',
          style: TextStyle(color: Colors.grey, fontSize: 15),
        )
      ];
    }
  }

  /*
  * Returns a rating bar that cannot
  * be changed with a number of filled
  * stars given as parameter.
  * */
  Widget getRatingBar(double rating, double size) {
    return RatingBar.readOnly(
      initialRating: rating,
      isHalfAllowed: true,
      halfFilledIcon: Icons.star_half,
      filledIcon: Icons.star,
      emptyIcon: Icons.star_border,
      emptyColor: Colors.amber,
      filledColor: Colors.amber,
      halfFilledColor: Colors.amber,
      size: size,
    );
  }
}
