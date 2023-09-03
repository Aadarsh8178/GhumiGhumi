class Channel {
  String name;
  String createdBy;
  List<String> users = [];
  String? localSDP;
  String? remoteSDP;

  Channel(
      {required this.name,
      required this.createdBy,
      required this.users,
      required this.localSDP});
}

class Location {
  String locationName;
  String createdBy;
  double latitude;
  double longitude;
  String reminderDate;

  Location({
    required this.locationName,
    required this.createdBy,
    required this.latitude,
    required this.longitude,
    required this.reminderDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'createdBy': createdBy,
      'locationName': locationName,
      'reminderDate': reminderDate
    };
  }

  static Location toLocation(Map<String, dynamic> location) {
    return Location(
        locationName: location['locationName'],
        createdBy: location['createdBy'],
        latitude: location['latitude'],
        longitude: location['longitude'],
        reminderDate: location['reminderDate']);
  }
}

class AppUser {
  String displayName;
  String avatar;
  String email;
  String uid;
  List<Location> locations = [];

  AppUser(
      {required this.displayName,
      required this.avatar,
      required this.email,
      required this.locations,
      required this.uid});
}
