import 'dart:async';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:reserve_it_app/models/local.dart';
import 'package:reserve_it_app/utils/custom_widgets.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

class LocalDetails extends StatefulWidget {
  Local selectedLocal;
  double distance;
  bool locationEnabled;

  LocalDetails({Key key, @required this.selectedLocal, @required this.distance})
      : super(key: key);

  @override
  _LocalDetailsState createState() =>
      _LocalDetailsState(this.selectedLocal, this.distance);
}

class _LocalDetailsState extends State<LocalDetails> {
  Local _local;
  double _distance;
  var _images = [];
  static LatLng _center;
  Set<Marker> _markers = {};
  CustomWidgets _customWidgets = CustomWidgets();
  Completer<GoogleMapController> _controller = Completer();

  _LocalDetailsState(this._local, this._distance) {
    _local.photoUrls.forEach((element) {
      _images.add(NetworkImage(element));
    });
    _distance = this._distance / 1000;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomPadding: true,
        body: Center(
            child: Container(
                width: 800,
                child: CustomScrollView(slivers: [
                  SliverAppBar(
                      backgroundColor: Colors.deepPurple,
                      expandedHeight: 250.0,
                      floating: true,
                      pinned: true,
                      flexibleSpace:
                          FlexibleSpaceBar(background: getImagesCarousel())),
                  SliverList(
                      delegate: SliverChildListDelegate([
                    _customWidgets.getHeightSizedBox(35.0),
                    buildTextLocalName(),
                    _customWidgets.getHeightSizedBox(5.0),
                    buildRowDistance(),
                    _customWidgets.getHeightSizedBox(5.0),
                    buildRowDescription(),
                    _customWidgets.getHeightSizedBox(25.0),
                    buildDetailsCard(context, _local),
                    buildLocationCard(context, _local),
                    buildAttractions(context, _local)
                  ]))
                ]))));
  }

  /*
  * @return a text with the name of the restaurant
  * */
  Text buildTextLocalName() {
    return Text(_local.name,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
            color: Colors.black87));
  }

  /*
  * @return a row with the street where the restaurant
  * is situated and the distance between the restaurant
  * and the user's location;
  * If the user's location is unknown, then the distance
  * is replaced with the City of the restaurant
  * */
  Row buildRowDistance() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(_local.address.street,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15.0, color: Colors.grey)),
      _customWidgets.getWitdthSizedBox(5.0),
      Icon(Icons.location_on, color: Colors.redAccent),
      Text(
          !_distance.isNegative
              ? _distance.toStringAsFixed(1) + ' km away'
              : _local.address.city,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 15.0, color: Colors.grey, fontWeight: FontWeight.bold))
    ]);
  }

  /*
  * @return a row with a short description/ logo
  * of the restaurant
  * */
  Row buildRowDescription() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.scatter_plot, color: Colors.redAccent),
      _customWidgets.getWitdthSizedBox(2.0),
      Text(_local.description,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 15.0,
              color: Colors.black87,
              fontWeight: FontWeight.bold))
    ]);
  }

  Widget getImagesCarousel() {
    return new Container(
      height: 300.0,
      child: Stack(children: [
        Carousel(
          boxFit: BoxFit.cover,
          images: _images,
          autoplay: false,
          animationCurve: Curves.fastOutSlowIn,
          dotSize: 5.0,
          indicatorBgPadding: 9.0,
          dotBgColor: Colors.black12,
        ),
        Padding(
          padding: !kIsWeb
              ? EdgeInsets.only(top: 30.0, right: 20)
              : EdgeInsets.only(top: 5, right: 15),
          child: Align(
            alignment: Alignment.topRight,
            child: Column(
              children: [
                Expanded(
                  child: Wrap(children: [
                    IconButton(
                      icon: Icon(Icons.favorite_border,
                          color: Colors.white, size: 30.0),
                      tooltip: 'Add to favorites',
                      onPressed: () {},
                    )
                  ]),
                )
              ],
            ),
          ),
        ),
        Padding(
          padding: !kIsWeb
              ? EdgeInsets.only(top: 250.0)
              : EdgeInsets.only(top: 225.0),
          child: Align(
            alignment: Alignment.topRight,
            child: Column(
              children: [
                Expanded(
                  child: Wrap(children: [
                    _customWidgets.getHeightSizedBox(245.0),
                    Row(children: [
                      _customWidgets.getWitdthSizedBox(10.0),
                      _customWidgets.getRatingBar(_local.rating, 20.0),
                      _customWidgets.getWitdthSizedBox(2.0),
                      Text(_local.rating.toString(),
                          style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold))
                    ])
                  ]),
                )
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget buildDetailsCard(BuildContext context, Local local) {
    return SingleChildScrollView(
        child: Container(
            child: Card(
      child: ListTile(
        title: Column(
          children: <Widget>[
            _customWidgets.getHeightSizedBox(10.0),
            buildRowDetails(),
            _customWidgets.getHeightSizedBox(10.0),
            buildRowPhone(),
            _customWidgets.getHeightSizedBox(5.0),
            buildRowPayments(),
            _customWidgets.getHeightSizedBox(5.0),
            buildRowEmail(),
            _customWidgets.getHeightSizedBox(5.0),
            buildRowWebsite(),
            _customWidgets.getHeightSizedBox(5.0),
            buildRowPets(),
            _customWidgets.getHeightSizedBox(5.0),
            buildRowSmoking(),
            _customWidgets.getHeightSizedBox(10.0),
          ],
        ),
      ),
    )));
  }

  Row buildRowSmoking() {
    return Row(
      children: [
        _customWidgets.getWitdthSizedBox(20.0),
        Icon(Icons.smoking_rooms, color: Colors.red, size: 20.0),
        _customWidgets.getWitdthSizedBox(5.0),
        Text(
          'Smoking allowed',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87),
        ),
        _customWidgets.getWitdthSizedBox(5.0),
        Text(
          _local.smokingRestriction ? 'no' : 'yes',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.0, color: Colors.black87),
        ),
      ],
    );
  }

  Row buildRowPets() {
    return Row(
      children: [
        _customWidgets.getWitdthSizedBox(20.0),
        Icon(Icons.pets, color: Colors.red, size: 20.0),
        _customWidgets.getWitdthSizedBox(5.0),
        Text(
          'Pets allowed',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87),
        ),
        _customWidgets.getWitdthSizedBox(5.0),
        Text(
          _local.petRestriction ? 'no' : 'yes',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.0, color: Colors.black87),
        ),
      ],
    );
  }

  Row buildRowDetails() {
    return Row(
      children: [
        Icon(Icons.info_outline, size: 15.0, color: Colors.deepPurple),
        _customWidgets.getWitdthSizedBox(5.0),
        Text(
          'About the ' + _local.type,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22.0, color: Colors.black87),
        )
      ],
    );
  }

  Row buildRowPhone() {
    return Row(
      children: [
        _customWidgets.getWitdthSizedBox(20.0),
        Icon(Icons.phone, color: Colors.red, size: 20.0),
        _customWidgets.getWitdthSizedBox(5.0),
        Text(
          'Phone',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87),
        ),
        _customWidgets.getWitdthSizedBox(5.0),
        GestureDetector(
          onTap: () {
            if (!kIsWeb) launchPhoneNumber();
          },
          child: Text(
            _local.phoneNumber.substring(2, _local.phoneNumber.length),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0, color: Colors.black87),
          ),
        )
      ],
    );
  }

  Row buildRowWebsite() {
    return Row(
      children: [
        _customWidgets.getWitdthSizedBox(20.0),
        Icon(Icons.link, color: Colors.red, size: 20.0),
        _customWidgets.getWitdthSizedBox(5.0),
        Text(
          'Website',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87),
        ),
        _customWidgets.getWitdthSizedBox(5.0),
        GestureDetector(
            onTap: () {
              launchUrl();
            },
            child: Text(
              _local.website,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0, color: Colors.blue),
            )),
      ],
    );
  }

  Row buildRowEmail() {
    return Row(
      children: [
        _customWidgets.getWitdthSizedBox(20.0),
        Icon(Icons.email, color: Colors.red, size: 20.0),
        _customWidgets.getWitdthSizedBox(5.0),
        Text(
          'Email',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87),
        ),
        _customWidgets.getWitdthSizedBox(5.0),
        Text(
          _local.email,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.0, color: Colors.black87),
        ),
      ],
    );
  }

  Row buildRowPayments() {
    String paymentText = '';
    for (String paymentMethod in _local.paymentMethods) {
      paymentText = paymentText + paymentMethod + ',';
    }
    return Row(
      children: [
        _customWidgets.getWitdthSizedBox(20.0),
        Icon(Icons.attach_money, color: Colors.red, size: 20.0),
        _customWidgets.getWitdthSizedBox(5.0),
        Text(
          'Payment Options',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87),
        ),
        _customWidgets.getWitdthSizedBox(5.0),
        Text(
          paymentText.substring(0, paymentText.length - 1),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.0, color: Colors.black87),
        ),
      ],
    );
  }

  Widget buildLocationCard(BuildContext context, Local local) {
    _center = LatLng(_local.geoPoint.latitude, _local.geoPoint.longitude);
    _markers.add(Marker(
        markerId: MarkerId('Location'),
        position: _center,
        infoWindow: InfoWindow(title: local.name, snippet: local.type),
        icon: BitmapDescriptor.defaultMarker));
    return SingleChildScrollView(
        child: Container(
            child: Card(
      child: ListTile(
        title: Column(
          children: <Widget>[
            _customWidgets.getHeightSizedBox(10.0),
            buildRowLocation(),
            _customWidgets.getHeightSizedBox(5.0),
            buildRowStreet(),
            _customWidgets.getHeightSizedBox(5.0),
            buildRowCity(),
            _customWidgets.getHeightSizedBox(10.0),
            buildContainerMap(),
          ],
        ),
      ),
    )));
  }

  Row buildRowLocation() {
    return Row(
      children: [
        Icon(Icons.zoom_out_map, size: 15.0, color: Colors.deepPurple),
        _customWidgets.getWitdthSizedBox(5.0),
        Text(
          'Location',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22.0, color: Colors.black87),
        )
      ],
    );
  }

  Container buildContainerMap() {
    return Container(
      height: 200,
      child: GoogleMap(
        onMapCreated: onMapCreated,
        initialCameraPosition: CameraPosition(target: _center, zoom: 15.0),
        mapType: MapType.normal,
        markers: _markers,
      ),
    );
  }

  Row buildRowCity() {
    return Row(
      children: [
        _customWidgets.getWitdthSizedBox(20.0),
        Text(
          _local.address.city,
          style: TextStyle(fontSize: 16.0, color: Colors.black87),
        ),
      ],
    );
  }

  Row buildRowStreet() {
    return Row(
      children: [
        _customWidgets.getWitdthSizedBox(20.0),
        Text(
          _local.address.street,
          style: TextStyle(fontSize: 16.0, color: Colors.black87),
        ),
      ],
    );
  }

  Widget buildAttractions(BuildContext context, Local local) {
    return SingleChildScrollView(
        child: Container(
            child: Card(
                child: ListTile(
      title: Column(
        children: <Widget>[
          _customWidgets.getHeightSizedBox(10.0),
          buildRowAttractions(),
          _customWidgets.getHeightSizedBox(10.0),
          buildRowChips(local)
        ],
      ),
    ))));
  }

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

  Row buildRowAttractions() {
    return Row(
      children: [
        Icon(Icons.favorite_border, size: 15.0, color: Colors.deepPurple),
        _customWidgets.getWitdthSizedBox(5.0),
        Text(
          'Attractions',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22.0, color: Colors.black87),
        ),
      ],
    );
  }

  onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  /*
  * Launches the website of the restaurant.
  * */
  launchUrl() async {
    var url = 'https://' + _local.website.substring(3, _local.website.length);
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  /*
  * Launches the phone number in the
  * phone, so that the user can directly call
  * this number or send a message to it when
  * the number is pressed.
  * */
  launchPhoneNumber() async {
    var url = 'tel:${_local.phoneNumber}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
