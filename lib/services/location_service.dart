import 'dart:async';

import 'package:location/location.dart';
import 'package:reserve_it_app/models/current_location.dart';

/*
* Service for managing the current location
* of the logged user. Current location is enabled,
* only if the user allows it and has it's location
* on his mobile opened.
* */
class LocationService {
  Location location = Location();
  CurrentUserLocation _currentLocation;

  StreamController<CurrentUserLocation> _locationController =
      StreamController<CurrentUserLocation>.broadcast();

  Stream<CurrentUserLocation> get locationStream => _locationController.stream;

  LocationService() {
    location.requestPermission().then((granted) {
      if (granted != null) {
        location.onLocationChanged().listen((locationData) {
          if (locationData != null) {
            _locationController.add(CurrentUserLocation(
                latitude: locationData.latitude,
                longitude: locationData.longitude));
          }
        });
      }
    });
  }

  Future<CurrentUserLocation> getLocation() async {
    try {
      var userLocation = await location.getLocation();
      _currentLocation = CurrentUserLocation(
          latitude: userLocation.latitude, longitude: userLocation.longitude);
    } catch (exception) {
      print('Could not get the location $exception');
    }
    return _currentLocation;
  }
}
