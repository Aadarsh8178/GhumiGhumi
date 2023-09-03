import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:whatever/api.dart';
import 'package:whatever/data_models.dart';

class Locations extends StatefulWidget {
  const Locations({super.key});

  @override
  State<Locations> createState() => _LocationsState();
}

class _LocationsState extends State<Locations> {
  final Stream<DocumentSnapshot> _userStream = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .snapshots();

  openMaps(double lat, double lon, String locationName) async {
    final availableMaps = await MapLauncher.installedMaps;
    final coords = Coords(lat, lon);
    final title = locationName;

    print(
        availableMaps); // [AvailableMap { mapName: Google Maps, mapType: google }, ...]

    // ignore: use_build_context_synchronously
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Wrap(
              children: <Widget>[
                for (var map in availableMaps)
                  ListTile(
                    onTap: () => map.showMarker(
                      coords: coords,
                      title: title,
                    ),
                    title: Text(map.mapName),
                    leading: SvgPicture.asset(
                      map.icon,
                      height: 30.0,
                      width: 30.0,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  deleteLocation(List<Location> locations, int index) {
    List<Location> newLocations = List.from(locations);
    newLocations.removeAt(index);
    FirebaseApi.updateLocations(newLocations);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _userStream,
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        var data = snapshot.data?.data()! as Map<String, dynamic>;
        List<Location> locations = (data['locations'] as List)
            .map((item) => Location(
                createdBy: item['createdBy'],
                latitude: item['latitude'],
                locationName: item['locationName'],
                longitude: item['longitude'],
                reminderDate: item['reminderDate']))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20),
            ListView(
              shrinkWrap: true,
              children: locations.asMap().entries.map((e) {
                var location = e.value;
                var index = e.key;
                return Dismissible(
                  key: Key(location.latitude.toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    deleteLocation(locations, index);
                  },
                  background: Container(
                    alignment: AlignmentDirectional.centerEnd,
                    color: Colors.red,
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () => openMaps(location.latitude, location.longitude,
                        location.locationName),
                    child: Card(
                      shape: const RoundedRectangleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  location.locationName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(DateFormat('yMMMMEEEEd').format(
                                    DateTime.parse(location.reminderDate)))
                              ],
                            ),
                            Text(DateFormat('hh:mm a')
                                .format(DateTime.parse(location.reminderDate)))
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
