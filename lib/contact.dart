class Contact {
  String username;
  String visibleName;
  String avatarURL;
  bool requestSent = false;
  DateTime lastContacted; // Change to datetime

  Contact({this.username, this.avatarURL = "", this.lastContacted, this.visibleName});

  Map<String, dynamic> toJson() {
    return {
      "username" : username,
      "avatar_url" : avatarURL,
      "visible_name" : visibleName, 
      "last_contacted" : lastContacted.toIso8601String(),
    };
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
        username: json['username'],
        avatarURL: json['avatar_url'],
        visibleName : json['visible_name'], 
        lastContacted: DateTime.parse(json['last_contacted']));
  }
}
