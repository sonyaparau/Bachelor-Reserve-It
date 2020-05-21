/*
* Class for the address of a local.
* */
class Address {
  String city;
  String country;
  String street;
  String zipCode;

  Address.fromJson(Map<String, dynamic> data) {
    city = data['city'];
    country = data['country'];
    street = data['street'];
    zipCode = data['zip_code'];
  }
}
