class Contact {
  String username;
  String visibleName;
  String avatarURL;
  bool requestSent = false;
  bool accepted = false;
  bool hasBeenCalled = false;
  DateTime lastContacted = DateTime.now(); // Change to datetime

  Contact(
      {this.username,
      this.avatarURL = "",
      this.lastContacted,
      this.requestSent = false,
      this.accepted = false,
      this.hasBeenCalled = false,
      this.visibleName});

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "avatar_url": avatarURL,
      "visible_name": visibleName,
      "last_contacted": lastContacted.toIso8601String(),
      "request_sent": requestSent,
      "accepted": accepted,
      "has_been_called": hasBeenCalled,
    };
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
        username: json['username'],
        avatarURL: json['avatar_url'],
        visibleName: json['visible_name'],
        requestSent: json['request_sent'],
        accepted: json['accepted'],
        hasBeenCalled: json['has_been_called'],
        lastContacted: DateTime.parse(json['last_contacted']));
  }
}
