import 'dart:async';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:reserve_it_app/models/local.dart';
import 'package:reserve_it_app/screens/reservation_dialog_helper.dart';
import 'package:reserve_it_app/screens/screenUtils/local_details_helper.dart';
import 'package:reserve_it_app/screens/screenUtils/custom_widgets.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:reserve_it_app/services/authentication_service.dart';

/*
* Contains the details of a selected local.
* */
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
  //selected local
  Local _local;

  //distance between the selected local and the user's location
  double _distance;

  //images of the selected local
  var _images = [];

  //geopoint of the selected location
  static LatLng _center;

  //markers for the selected local
  Set<Marker> _markers = {};

  LocalDetailsHelper _detailsHelper = LocalDetailsHelper();
  AuthService _authService = AuthService();

  CustomWidgets _customWidgets = CustomWidgets();
  Completer<GoogleMapController> _controller = Completer();

  _LocalDetailsState(this._local, this._distance) {
    _local.photoUrls.forEach((element) {
      _images.add(NetworkImage(element));
    });
    transformMeterInKm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomPadding: true,
      body: Center(
        child: Container(
          width: 800,
          child: CustomScrollView(
            slivers: [
              buildSliverAppBar(),
              buildSliverList(context),
            ],
          ),
        ),
      ),
    );
  }

  /*
  * Creates the SliverAppBar containing
  * the image carousel, the rating bar and
  * the favourite button.
  * */
  SliverAppBar buildSliverAppBar() {
    return SliverAppBar(
        backgroundColor: Colors.deepPurple,
        expandedHeight: 250.0,
        floating: true,
        pinned: true,
        flexibleSpace: FlexibleSpaceBar(background: getImagesCarousel()));
  }

  /*
  * Creates a SliverList containing all the details
  * of the restaurant.
  * */
  SliverList buildSliverList(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          _customWidgets.getHeightSizedBox(35.0),
          _detailsHelper.buildTextLocalName(_local.name),
          _customWidgets.getHeightSizedBox(5.0),
          _detailsHelper.buildRowDistance(
              _local.address.street, _local.address.city, _distance),
          _customWidgets.getHeightSizedBox(5.0),
          _detailsHelper.buildRowDescription(_local.description),
          _customWidgets.getHeightSizedBox(25.0),
          buildDetailsCard(context),
          buildLocationCard(context),
          buildAttractionsCard(context),
          buildReserveCard(context),
        ],
      ),
    );
  }

  /*
  * Adds a card containing all the details of the
  * restaurant: payment methods, phone number,
  * website, pet restrictions, smoking restriction,
  * email.
  * */
  Widget buildDetailsCard(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Card(
          child: ListTile(
            title: Column(
              children: <Widget>[
                _customWidgets.getHeightSizedBox(10.0),
                _detailsHelper.buildRowCardTitle(
                    Icons.info_outline, 'About the ' + _local.type),
                _customWidgets.getHeightSizedBox(10.0),
                _detailsHelper.buildRowPhone(_local.phoneNumber),
                _customWidgets.getHeightSizedBox(5.0),
                buildRowPayments(),
                !_local.email.startsWith('-')
                    ? _customWidgets.getHeightSizedBox(5.0)
                    : Offstage(),
                !_local.email.startsWith('-')
                    ? _detailsHelper.buildRowEmail(_local.email)
                    : Offstage(),
                !_local.website.startsWith('-')
                    ? _customWidgets.getHeightSizedBox(5.0)
                    : Offstage(),
                !_local.website.startsWith('-')
                    ? _detailsHelper.buildRowWebsite(_local.website)
                    : Offstage(),
                _customWidgets.getHeightSizedBox(5.0),
                buildRowPets(),
                _customWidgets.getHeightSizedBox(5.0),
                buildRowSmoking(),
                _customWidgets.getHeightSizedBox(10.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /*
  * Adds a card containing the Google Map with
  * the selected restaurant and the address of it.
  * */
  Widget buildLocationCard(BuildContext context) {
    buildMapCenter();
    addMarker();
    return SingleChildScrollView(
      child: Container(
        child: Card(
          child: ListTile(
            title: Column(
              children: <Widget>[
                _customWidgets.getHeightSizedBox(10.0),
                _detailsHelper.buildRowCardTitle(
                    Icons.zoom_out_map, 'Location'),
                _customWidgets.getHeightSizedBox(5.0),
                _detailsHelper.buildRowStreet(_local.address.street),
                _customWidgets.getHeightSizedBox(5.0),
                _detailsHelper.buildRowCity(_local.address.city),
                _customWidgets.getHeightSizedBox(10.0),
                buildContainerMap(),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget buildReserveCard(BuildContext context) {
    buildMapCenter();
    addMarker();
    return SingleChildScrollView(
      child: Container(
        child: Card(
          child: ListTile(
            title: Column(
              children: <Widget>[
              ],
            ),
          ),
        ),
      ),
    );
  }

  /*
  * Adds a card containing the 3 top
  * attractions of the restaurant.
  * */
  Widget buildAttractionsCard(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Card(
          child: ListTile(
            title: Column(
              children: <Widget>[
                _customWidgets.getHeightSizedBox(10.0),
                _detailsHelper.buildRowCardTitle(
                    Icons.favorite_border, 'Attractions'),
                _customWidgets.getHeightSizedBox(10.0),
                _detailsHelper.buildRowChips(_local)
              ],
            ),
          ),
        ),
      ),
    );
  }

  /*
  * @return the Carousel containing the images
  * of the restaurant, the rating bar and the
  * favourite button.
  * */
  Widget getImagesCarousel() {
    return new Container(
      height: 300.0,
      child: Stack(children: [
        buildCarousel(),
        Padding(
          padding: !kIsWeb
              ? EdgeInsets.only(top: 30.0, right: 20)
              : EdgeInsets.only(top: 5, right: 15),
          child: Align(
            alignment: Alignment.topRight,
            child: buildColumnFavorites(),
          ),
        ),
        Padding(
          padding: !kIsWeb
              ? EdgeInsets.only(top: 250.0)
              : EdgeInsets.only(top: 225.0),
          child: Align(
            alignment: Alignment.topRight,
            child: buildColumnRating(),
          ),
        ),
      ]),
    );
  }

  /*
  * Builds a carousel containing the
  * photos of the restaurant.
  * */
  Carousel buildCarousel() {
    return Carousel(
      boxFit: BoxFit.cover,
      images: _images,
      autoplay: false,
      animationCurve: Curves.fastOutSlowIn,
      dotSize: 5.0,
      indicatorBgPadding: 9.0,
      dotBgColor: Colors.black12,
    );
  }

  /*
  * @return the column with the favourite
  * IconButton. By pressing it, the user
  * adds the local to his favourite restaurant
  * list.
  * */
  Column buildColumnFavorites() {
    return Column(
      children: [
        Expanded(
          child: Wrap(
            children: [
              IconButton(
                icon: Icon(Icons.favorite_border,
                    color: Colors.white, size: 30.0),
                tooltip: 'Add to favorites',
                onPressed: () {
                  //TODO add local to the favourite list
                },
              )
            ],
          ),
        ),
      ],
    );
  }

  /*
  * @return the column with the rating of the restaurant.
  * It contains a rating bar followed by the value of the
  * rating.
  * */
  Column buildColumnRating() {
    return Column(
      children: [
        Expanded(
          child: Wrap(
            children: [
              _customWidgets.getHeightSizedBox(245.0),
              Row(
                children: [
                  _customWidgets.getWitdthSizedBox(10.0),
                  _customWidgets.getRatingBar(_local.rating, 20.0),
                  _customWidgets.getWitdthSizedBox(2.0),
                  Text(
                    _local.rating.toString(),
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /*
  * @return the row with the payment details
  * */
  Row buildRowPayments() {
    String paymentText = createPaymentText();
    return _detailsHelper.buildRow(Icons.credit_card, 'Payment Options',
        paymentText.substring(0, paymentText.length - 2));
  }

  /*
  * @return the row with the smoking details
  * */
  Row buildRowSmoking() {
    return _detailsHelper.buildRow(Icons.smoking_rooms, 'Smoking allowed',
        _local.smokingRestriction ? 'no' : 'yes');
  }

  /*
  * @return the row with the pet details
  * */
  Row buildRowPets() {
    return _detailsHelper.buildRow(
        Icons.pets, 'Pets allowed', _local.petRestriction ? 'no' : 'yes');
  }

  /*
  * Concatenates the payment methods
  * from the list in a string split
  * by comma.
  * */
  String createPaymentText() {
    String paymentText = '';
    for (String paymentMethod in _local.paymentMethods) {
      paymentText = paymentText + paymentMethod + ', ';
    }
    return paymentText;
  }

  /*
  * Sets the center of the map in the
  * selected restaurant's location.
  * */
  buildMapCenter() {
    _center = LatLng(_local.geoPoint.latitude, _local.geoPoint.longitude);
  }

  /*
  * Adds the marker of the selected
  * restaurant
  * */
  bool addMarker() {
    return _markers.add(Marker(
        markerId: MarkerId('Location'),
        position: _center,
        infoWindow: InfoWindow(title: _local.name, snippet: _local.type),
        icon: BitmapDescriptor.defaultMarker));
  }

  /*
  * @return a container with a Google Map.
  * It is centered in the selected restaurant
  * location's address.
  * */
  Container buildContainerMap() {
    return Container(
      height: 200,
//      child:
//      GoogleMap(
//        onMapCreated: onMapCreated,
//        initialCameraPosition: CameraPosition(
//          target: _center,
//          zoom: 15.0,
//        ),
//        mapType: MapType.normal,
//        markers: _markers,
//      ),
    );
  }

  /*
  * Creates a controller for the Google Map.
  * */
  onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  /*
  * Transforms a meter in a kilometer.
  * */
  double transformMeterInKm() => _distance = this._distance / 1000;
}
