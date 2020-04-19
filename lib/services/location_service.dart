import 'dart:async';

import 'package:location/location.dart';
import 'package:reserve_it_app/models/current_location.dart';

class LocationService {
  Location _location = Location();
  CurrentUserLocation _currentLocation;

  StreamController<CurrentUserLocation> _locationController =
      StreamController<CurrentUserLocation>.broadcast();

  LocationService() {
    _location.requestPermission().then((granted) {
      if (granted != null) {
        _location.onLocationChanged.listen((LocationData locationData) {
          if (locationData != null) {
            _locationController.add(CurrentUserLocation(
                latitude: locationData.latitude,
                longitude: locationData.longitude));
          }
        });
      }
    });
  }

  Stream<CurrentUserLocation> get locationStream => _locationController.stream;

  Future<CurrentUserLocation> getLocation() async {
    try {
      var userLocation = await _location.getLocation();
      _currentLocation = CurrentUserLocation(
          latitude: userLocation.latitude, longitude: userLocation.longitude);
    } catch (exception) {
      print('Could not get the location $exception');
    }
    return _currentLocation;
  }
}
