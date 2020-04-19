import 'package:reserve_it_app/models/address.dart';

/*
* Class for the local entity.
* */
class Local {

  String id;
  Address address;
  List<String> attractions;
  String description;
  String email;
  String name;
  List<String> paymentMethods;
  bool petRestriction;
  String phoneNumber;
  String mainPhoto;
  List<String> photoUrls;
  bool smokingRestriction;
  String type;
  String website;
  double rating;

  Local.fromJson(Map<String, dynamic> data) {
      address = Address.fromJson(data['address']);
      attractions = List.from(data['attractions']);
      description = data['description'];
      email = data['email'];
      mainPhoto = data['mainPhoto'];
      name = data['name'];
      paymentMethods = List.from(data['paymentMethods']);
      petRestriction = data['petRestriction'];
      phoneNumber = data['phone_number'];
      photoUrls = List.from(data['photos']);
      smokingRestriction = data['smokingRestriction'];
      type = data['type'];
      website = data['website'];
      rating = data['rating'];
  }
}