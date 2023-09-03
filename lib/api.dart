import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatever/data_models.dart';

class FirebaseApi {
  static FirebaseFirestore _db = FirebaseFirestore.instance;
  static User? _user = FirebaseAuth.instance.currentUser;

  static updateLocations(List<Location> locations) async {
    if (_user == null || _user?.uid == null) throw Error();
    final locationData = locations.map((location) => location.toMap()).toList();

    final userRef = await _db
        .collection('users')
        .doc(_user?.uid)
        .update({'locations': locationData});
  }
}
