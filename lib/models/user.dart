/*
* Class for the user entity.
* */
class User {
  String uid;
  String email;
  String phone;
  String photoUrl;
  String firstName;
  String lastName;
  String deviceToken;
  List<String> favouriteLocals;

  User(
      {this.uid,
      this.email,
      this.phone,
      this.photoUrl,
      this.favouriteLocals,
      this.firstName,
      this.lastName});
}
