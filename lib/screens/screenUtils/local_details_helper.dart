import 'package:flutter/material.dart';
import 'package:reserve_it_app/models/local.dart';
import 'package:reserve_it_app/screens/screenUtils/custom_widgets.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

/*
* Helper class for the LocalDetails. Contains
* Rows and Texts that are used to show the
* details of a selected local.
* */
class LocalDetailsHelper {
  CustomWidgets _customWidgets = CustomWidgets();

  /*
  * @return a text with the name of the restaurant
  * */
  Text buildTextLocalName(String name) {
    return Text(
      name,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  /*
  * @return a row with the street where the restaurant
  * is situated and the distance between the restaurant
  * and the user's location;
  * If the user's location is unknown, then the distance
  * is replaced with the city of the restaurant
  * */
  Row buildRowDistance(String street, String city, double distance) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(street,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15.0, color: Colors.grey)),
        _customWidgets.getWitdthSizedBox(5.0),
        Icon(Icons.location_on, color: Colors.redAccent),
        Text(
          _createDistanceText(city, distance),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.0,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /*
  * @return a row with a short description
  * of the restaurant
  * */
  Row buildRowDescription(String description) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.scatter_plot, color: Colors.redAccent),
        _customWidgets.getWitdthSizedBox(2.0),
        Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.0,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }

  /*
  * @return the row with the phone details
  * */
  Row buildRowPhone(String phoneNumber) {
    return Row(
      children: [
        _customWidgets.getWitdthSizedBox(20.0),
        Icon(Icons.phone, color: Colors.red, size: 20.0),
        _customWidgets.getWitdthSizedBox(5.0),
        buildTextDetails('Phone', FontWeight.bold, Colors.black87),
        _customWidgets.getWitdthSizedBox(5.0),
        GestureDetector(
          onTap: () {
            if (!kIsWeb) launchPhoneNumber(phoneNumber);
          },
          child: buildTextDetails(
            phoneNumber.substring(2, phoneNumber.length),
            FontWeight.normal,
            Colors.black87,
          ),
        ),
      ],
    );
  }

  /*
  * @return the row with the website details
  * */
  Row buildRowWebsite(String website) {
    return Row(
      children: [
        _customWidgets.getWitdthSizedBox(20.0),
        Icon(Icons.link, color: Colors.red, size: 20.0),
        _customWidgets.getWitdthSizedBox(5.0),
        buildTextDetails('Website', FontWeight.bold, Colors.black87),
        _customWidgets.getWitdthSizedBox(5.0),
        GestureDetector(
          onTap: () {
            launchUrl(website);
          },
          child: buildTextDetails(website, FontWeight.normal, Colors.blue),
        ),
      ],
    );
  }

  /*
  * @return the row with the email details
  * */
  Row buildRowEmail(String email) {
    return Row(
      children: [
        _customWidgets.getWitdthSizedBox(20.0),
        Icon(Icons.email, color: Colors.red, size: 20.0),
        _customWidgets.getWitdthSizedBox(5.0),
        buildTextDetails('Email', FontWeight.bold, Colors.black87),
        _customWidgets.getWitdthSizedBox(5.0),
        buildTextDetails(email, FontWeight.normal, Colors.black87),
      ],
    );
  }

  /*
  * @return a row with 3 chips containing the
  * top 3 attractions of the restaurant
  * */
  Row buildRowChips(Local local) {
    List<Widget> chips = [];

    for (int i = 0; i < 3; i++) {
      if (local.attractions[i] != null) {
        chips.add(Chip(
          label: Text('#' + local.attractions[i],
              style: TextStyle(color: Colors.white, fontSize: 15.0)),
          backgroundColor: Colors.deepPurple,
          padding: EdgeInsets.all(3.0),
        ));
        chips.add(_customWidgets.getWitdthSizedBox(5.0));
      }
    }
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: chips);
  }

  /*
  * @return a row containing the title of a card, used
  * for the favourites, location and detail cards.
  * */
  Row buildRowCardTitle(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 15.0, color: Colors.deepPurple),
        _customWidgets.getWitdthSizedBox(5.0),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22.0,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // @return a row used for the payment, smoking and pet details
  Row buildRow(IconData icon, String key, String value) {
    return Row(
      children: [
        _customWidgets.getWitdthSizedBox(20.0),
        Icon(icon, color: Colors.red, size: 20.0),
        _customWidgets.getWitdthSizedBox(5.0),
        buildTextDetails(key, FontWeight.bold, Colors.black87),
        _customWidgets.getWitdthSizedBox(5.0),
        buildTextDetails(value, FontWeight.normal, Colors.black87)
      ],
    );
  }

  /*
  * @return a Text Widget with a given weight and
  * color used for the texts in the cards.
  * */
  Text buildTextDetails(String text, FontWeight weight, Color color) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16.0,
        fontWeight: weight,
        color: color,
      ),
    );
  }

  // @return a row containing the city of a selected local
  Row buildRowCity(String city) {
    return Row(
      children: [
        _customWidgets.getWitdthSizedBox(20.0),
        Text(
          city,
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // @return a row containing the street of a selected local
  Row buildRowStreet(String street) {
    return Row(
      children: [
        _customWidgets.getWitdthSizedBox(20.0),
        Text(
          street,
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  /*
  * Launches the phone number in the
  * phone, so that the user can directly call
  * this number or send a message to it when
  * the number is pressed.
  * */
  launchPhoneNumber(String phoneNumber) async {
    var url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  /*
  * Launches the website of the restaurant.
  * */
  launchUrl(String website) async {
    var url = 'https://' + website.substring(3, website.length);
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  /*
  * Creates the text for the distance.
  * If the distance is negative (when user has his
  * location not open), then the city will
  * be displayed. Otherwise, the distance in Km will be
  * displayed.
  * */
  String _createDistanceText(String city, double distance) {
    if (distance.isNegative) {
      return city;
    } else {
      return distance.toStringAsFixed(1) + ' km away';
    }
  }
}