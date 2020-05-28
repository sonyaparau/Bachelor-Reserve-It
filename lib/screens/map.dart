import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong/latlong.dart' as ll;
import 'package:provider/provider.dart';
import 'package:reserve_it_app/models/current_location.dart';
import 'package:reserve_it_app/models/local.dart';
import 'package:reserve_it_app/screens/local_details.dart';
import 'package:reserve_it_app/screens/screenUtils/utils.dart';
import 'package:reserve_it_app/screens/screenUtils/custom_widgets.dart';

class Map extends StatefulWidget {
  List<Local> locals;

  Map({Key key, @required this.locals}) : super(key: key);

  @override
  _MapState createState() => _MapState(locals);
}

class _MapState extends State<Map> {
  Completer<GoogleMapController> _controller = Completer();

  //Cluj center points
  static const LatLng _center = const LatLng(46.769905, 23.588890);
  LatLng _lastMapPosition = _center;

  //set with all the points of the found restaurants
  Set<Marker> _markers = {};

  MapType _currentMapType = MapType.normal;
  List<Local> locals;
  CustomWidgets _customWidgets = CustomWidgets();

  //current user's location
  BitmapDescriptor pinLocationIcon;
  //distance between the user and the local
  double _km = -1;

  _MapState(this.locals) {
    addMarkersOnMap();
    setCustomMapPin();
  }

  /*
  * Sets the user location on the map, if this is
  * provided. A special icon will be displayed on
  * the marker to differentiate the location of the
  * user and the location of the locals.
  * */
  void setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5, size: Size(10.0, 15.0)),
        'assets/user_location.png');
  }

  @override
  Widget build(BuildContext context) {
    var userLocation = Provider.of<CurrentUserLocation>(context);
    bool activatedLocation = _setLocationUser(userLocation);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: Text('Restaurants'),
          centerTitle: true,
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Stack(
          children: [
            _buildGoogleMap(),
            _buildButtonsMap(),
            buildContainer(activatedLocation)
          ],
        ),
      ),
    );
  }

  /*
  * Add a new marker for the user's location if this
  * is provided and return true. Otherwise, return false.
  * */
  bool _setLocationUser(CurrentUserLocation userLocation) {
    bool activatedLocation = false;
    if (userLocation != null) {
      _markers.add(Marker(
          markerId: MarkerId('userLocation'),
          position: LatLng(userLocation.latitude, userLocation.longitude),
          infoWindow: InfoWindow(title: 'You are here 🙂'),
          icon: pinLocationIcon));
      activatedLocation = true;
    }
    return activatedLocation;
  }

  /*
  * Build buttons for the map. On pressed, this
  * change the location on the map.
  * */
  Padding _buildButtonsMap() {
    return Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topRight,
              child: Column(
                children: [
                  getButton(_onMapTypeButtonPressed, Icons.map),
                  _customWidgets.getHeightSizedBox(16.0),
                  getButton(_goToPosition, Icons.location_searching)
                ],
              ),
            ),
          );
  }

  /*
  * @return Google map
  * */
  GoogleMap _buildGoogleMap() {
    return GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition:
                CameraPosition(target: _center, zoom: 11.0),
            mapType: _currentMapType,
            markers: _markers,
            onCameraMove: _onCameraMove,
          );
  }

  //position of the central part of the city Cluj
  static final CameraPosition _position = CameraPosition(
      bearing: 46.769905,
      target: LatLng(46.769905, 23.588890),
      tilt: 23.588890,
      zoom: 15.0);

  /*
  * Changes the position on the map depending
  * on the pressed local and its location.
  * */
  Future<void> _goToPosition() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_position));
  }

  /*
  * Creates a Google Map cotroller.
  * */
  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  /*
  * Creates a button displayed on the map based
  * on the given parameters.
  * */
  Widget getButton(Function function, IconData iconData) {
    return FloatingActionButton(
        onPressed: function,
        heroTag: null,
        materialTapTargetSize: MaterialTapTargetSize.padded,
        backgroundColor: Colors.deepPurple,
        child: Icon(iconData, size: 36.0));
  }

  /*
  * Displays the map in two moods, based on the
  * user's preference: normal map or with a view
  * from the satellite.
  * */
  _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  /*
  * Adds the set of markers on the Map.
  * */
  addMarkersOnMap() {
    locals.forEach((element) {
      _markers.add(Marker(
          markerId: MarkerId(element.geoPoint.toString()),
          position:
              LatLng(element.geoPoint.latitude, element.geoPoint.longitude),
          infoWindow: InfoWindow(title: element.name, snippet: element.type),
          icon: BitmapDescriptor.defaultMarker));
    });
  }

  Widget buildContainer(bool activatedLocation) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20.0),
        height: 150.0,
        child: ListView(
            scrollDirection: Axis.horizontal,
            children: getElements(activatedLocation)),
      ),
    );
  }

  Future<void> goToLocation(double latitude, double longitude) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(latitude, longitude), zoom: 15, tilt: 15, bearing: 45)));
  }

  List<Widget> getElements(bool activatedLocation) {
    List<Widget> elements = [];
    locals.forEach((element) {
      elements.add(_customWidgets.getWidthSizedBox(10.0));
      elements.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: getLocalBox(element, activatedLocation),
      ));
    });
    return elements;
  }

  Widget getLocalBox(Local restaurant, bool activatedLocation){
    return GestureDetector(
      onTap: () {
        goToLocation(
            restaurant.geoPoint.latitude, restaurant.geoPoint.longitude);
      },
      onDoubleTap: () async {
        bool isFavouriteLocal;
        await Utils().isFavouriteLocal(restaurant.id).then((favourite) => isFavouriteLocal = favourite);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => LocalDetails(selectedLocal: restaurant, distance: _km, isFavouriteLocal: isFavouriteLocal)));
      },
      child: new FittedBox(
        child: Material(
          color: Colors.white,
          elevation: 14.0,
          borderRadius: BorderRadius.circular(24.0),
          shadowColor: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 180,
                height: 200,
                child: ClipRRect(
                  borderRadius: new BorderRadius.circular(24.0),
                  child: Image(
                    fit: BoxFit.fill,
                    image: NetworkImage(restaurant.mainPhoto),
                  ),
                ),
              ),
              Container(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: detailsContainer(restaurant, activatedLocation)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget detailsContainer(Local restaurant, bool activatedLocation) {
    var userLocation = Provider.of<CurrentUserLocation>(context);
    ll.Distance distance = ll.Distance();
    if(userLocation != null) {
      _km = distance.as(
          ll.LengthUnit.Meter,
          new ll.LatLng(
              restaurant.geoPoint.latitude, restaurant.geoPoint.longitude),
          new ll.LatLng(userLocation.latitude, userLocation.longitude));
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
              child: Text(
            restaurant.name,
            style: TextStyle(color: Colors.deepPurple, fontSize: 24.0),
          )),
        ),
        _customWidgets.getHeightSizedBox(5.0),
        Container(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(child: _customWidgets.getRatingBar(restaurant.rating, 25.0)),
            Container(
                child: Text(
              ' (' + restaurant.rating.toString() + ')',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 18.0,
              ),
            )),
            _customWidgets.getWidthSizedBox(20.0),
          ],
        )),
        _customWidgets.getHeightSizedBox(10.0),
        _customWidgets.getWidgetsForLocation(activatedLocation, _km)[0],
        _customWidgets.getWidgetsForLocation(activatedLocation, _km)[1],
      ],
    );
  }
}
