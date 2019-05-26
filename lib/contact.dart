class Contact {
  String username;
  String avatarURL;
  DateTime lastContacted; // Change to datetime

  Contact({this.username, this.avatarURL, this.lastContacted});

  Map<String, dynamic> toJson() {
    return {
      "username" : username,
      "avatar_url" : avatarURL,
      "last_contacted" : lastContacted.toIso8601String(),
    };
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
        username: json['username'],
        avatarURL: json['avatar_url'],
        lastContacted: DateTime.parse(json['last_contacted']));
  }
}
