// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:whatever/notification_service.dart';

class AddLocation extends StatefulWidget {
  const AddLocation({super.key});

  @override
  State<AddLocation> createState() => _AddLocationState();
}

class _AddLocationState extends State<AddLocation> {
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<Position?> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) {
      return null;
    }

    final position = await _geolocatorPlatform.getCurrentPosition();
    return position;
  }

  final locationNameController = TextEditingController();
  var loading = false;
  DateTime dateTime = DateTime.now();

  Future<DateTime?> pickDate() => showDatePicker(
      context: context,
      initialDate: dateTime,
      firstDate: dateTime,
      lastDate: DateTime(dateTime.year + 100));

  Future<TimeOfDay?> pickTime() => showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: dateTime.hour, minute: dateTime.minute));

  handleSubmit() async {
    setState(() {
      loading = true;
    });

    FirebaseFirestore db = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;
    Position? position = await _getCurrentPosition();

    if (user == null || position == null) return;
    Map<String, dynamic> location = {
      'locationName': locationNameController.text,
      'reminderDate': dateTime.toString(),
      'latitude': position.latitude,
      'longitude': position.longitude,
      'createdBy': user.uid,
    };

    final usersRef = db.collection('users');
    final userRef = usersRef.doc(user.uid);
    NotificationService().scheduleNotification(
        title: locationNameController.text,
        body: '$dateTime',
        scheduledNotificationDateTime: dateTime,
        payload:
            'lat=${position.latitude}&lon=${position.longitude}&title=${locationNameController.text}');
    await userRef.update({
      'locations': FieldValue.arrayUnion([location])
    });
    setState(() {
      loading = false;
    });
    Navigator.pop(context);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    locationNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hours = dateTime.hour.toString().padLeft(2, '0');
    final minutes = dateTime.minute.toString().padLeft(2, '0');

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextFormField(
            controller: locationNameController,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Location Name',
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              const Text("Date : "),
              TextButton(
                  onPressed: () async {
                    final date = await pickDate();
                    if (date == null) return;
                    final newDateTime = DateTime(date.year, date.month,
                        date.day, dateTime.hour, dateTime.minute);
                    setState(() {
                      dateTime = newDateTime;
                    });
                  },
                  child: Text(
                      "${dateTime.day}/${dateTime.month}/${dateTime.year}"))
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              const Text("Time : "),
              TextButton(
                onPressed: () async {
                  final time = await pickTime();
                  if (time == null) return;

                  final newDateTime = DateTime(dateTime.year, dateTime.month,
                      dateTime.day, time.hour, time.minute);
                  setState(() {
                    dateTime = newDateTime;
                  });
                },
                child: Text("$hours:$minutes"),
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: loading ? null : handleSubmit,
            child: loading
                ? SizedBox(
                    child: CircularProgressIndicator(),
                    height: 30,
                    width: 30,
                  )
                : const Text("Submit"),
          )
        ]),
      ),
    );
  }
}
