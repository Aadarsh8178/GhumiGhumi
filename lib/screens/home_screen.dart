import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:whatever/auth.dart';
import 'package:whatever/components/add_location.dart';
import 'package:whatever/components/locations.dart';
import 'package:whatever/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  addLocationModal() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return const AddLocation();
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FilledButton(
                          onPressed: addLocationModal,
                          child: const Text("Add a Location"),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: OutlinedButton(
                          onPressed: () async {
                            context.go("/login");
                            await Auth.instance.logoutUser();
                          },
                          child: const Text("Logout"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Locations()
            ],
          ),
        ),
      ),
    );
  }
}
