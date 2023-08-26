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
