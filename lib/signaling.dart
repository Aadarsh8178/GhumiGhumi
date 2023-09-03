import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class Signalling {
  Signalling._();

  static final instance = Signalling._();

  final Map<String, dynamic> _configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302',
        ],
      }
    ]
  };

  List<String> messages = [];

  RTCPeerConnection? peerConnection;
  Map<String, RTCDataChannel> dataChannels = {};

  Future<String> createChannel(String chatName) async {
    print('creating a channel');
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference channelRef = db.collection('channels').doc();
    var channelId = channelRef.id;

    peerConnection = await createPeerConnection(_configuration);

    RTCSessionDescription offer = await peerConnection!.createOffer();
    print('offer created ${offer.sdp}');
    await peerConnection?.setLocalDescription(offer);
    Map<String, dynamic> channelWithOffer = {
      'offer': offer.toMap(),
      chatName: chatName
    };

    await channelRef.set(channelWithOffer);

    print('new channel id created $channelId');

    RTCDataChannelInit dataChannelInit = RTCDataChannelInit();
    print(dataChannelInit);

    RTCDataChannel dc =
        await peerConnection!.createDataChannel(chatName, dataChannelInit);
    dataChannels[channelId] = dc;

    dc!.onMessage = (data) {
      print('Recieved message from client ${data.toString()}');
      messages.add(data.text);
    };

    channelRef.snapshots().listen((snapshot) async {
      print("Got updated channel: ${snapshot.data()}");
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

      if (peerConnection?.getRemoteDescription() != null &&
          data['answer'] != null) {
        var answer = RTCSessionDescription(
          data['answer']['sdp'],
          data['answer']['type'],
        );

        print("Someone tried to connect");
        await peerConnection?.setRemoteDescription(answer);
        dc.send(RTCDataChannelMessage('hello from offer creator'));
        messages.add('hello from offer creator');
      }
    });

    return channelId;
  }

  Future<void> joinChat(String channelId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    print(channelId);

    DocumentReference channelRef = db.collection('channels').doc(channelId);
    var channelSnaphot = await channelRef.get();

    print('Got channel ${channelSnaphot.exists}');

    if (channelSnaphot.exists) {
      peerConnection = await createPeerConnection(_configuration);
      var data = channelSnaphot.data() as Map<String, dynamic>;
      var offer = data['offer'];
      await peerConnection?.setRemoteDescription(
          RTCSessionDescription(offer['sdp'], offer['type']));

      var answer = await peerConnection!.createAnswer();
      print('Created answer $answer');
      await peerConnection!.setLocalDescription(answer);

      Map<String, dynamic> channelWithAnswer = {
        'answer': {'type': answer.type, 'sdp': answer.sdp}
      };

      await channelRef.update(channelWithAnswer);

      RTCDataChannel dc;

      peerConnection!.onDataChannel = (channel) {
        print("data channel recieved");
        dc = channel;
        dc.onMessage = (data) {
          print("Recieved message from client $data");
          messages.add(data.text);
        };
        dc.send(RTCDataChannelMessage('hello from answer creator!'));
      };
    }
  }
}
