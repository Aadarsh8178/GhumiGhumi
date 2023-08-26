import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatever/data_models.dart';
import 'package:whatever/signaling.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final channelNameController = TextEditingController();
  final channelIdController = TextEditingController();

  @override
  void dispose() {
    channelNameController.dispose();
    channelIdController.dispose();
    super.dispose();
  }

  onCreateChannel() {
    var channelId =
        Signalling.instance.createChannel(channelNameController.text);

    print(channelId);
    // String userId = user.uid;

    // CollectionReference channels =
    //     FirebaseFirestore.instance.collection('channels');

    // Channel channel = Channel(
    //     name: channelNameController.text, createdBy: userId, users: [userId]);
    // return channels
    //     .add(channel)
    //     .then((value) => print("Channel Added"))
    //     .catchError((error) => print("Failed to add user: $error"));
  }

  onJoinChannel() {
    var channelId = channelIdController.text;

    Signalling.instance.joinChat(channelId);
  }

  createChatModal(context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: "Channel name"),
                  controller: channelNameController,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: FilledButton.tonal(
                      onPressed: onCreateChannel,
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Text("Create"),
                      )),
                ),
              ],
            ),
          );
        });
  }

  joinChatModal(context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: "Channel Id"),
                  controller: channelIdController,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: FilledButton.tonal(
                      onPressed: onJoinChannel(),
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Text("Join"),
                      )),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FilledButton(
                onPressed: () => createChatModal(context),
                child: const Text("Create a chat"),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FilledButton(
                onPressed: () => joinChatModal(context),
                child: const Text("Join a chat"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
