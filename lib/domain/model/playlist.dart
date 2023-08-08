import 'dart:convert';

class Playlist {
  final String id;
  final String name;
  final String owner;
  final bool isPublic;
  final String createdAt;
  final String changedAt;
  final int songCount;
  final int durationSeconds;
  final String? coverArtId;

  Playlist({
    required this.id,
    required this.name,
    required this.owner,
    required this.isPublic,
    required this.createdAt,
    required this.changedAt,
    required this.songCount,
    required this.durationSeconds,
    this.coverArtId,
  });

  String get formattedDuration {
    var duration = Duration(seconds: durationSeconds);
    var hours = duration.inHours;
    var minutes = (duration.inMinutes % 60).toString().padLeft(2, "0");
    var seconds = (duration.inSeconds % 60).toString().padLeft(2, "0");
    return "$hours:$minutes:$seconds";
  }

  factory Playlist.fromJson(Map<String, dynamic> jsonData) {
    return Playlist(
      id: jsonData["id"],
      name: jsonData["name"],
      owner: jsonData["owner"],
      isPublic: jsonData["isPublic"],
      createdAt: jsonData["createdAt"],
      changedAt: jsonData["changedAt"],
      songCount: jsonData["songCount"],
      durationSeconds: jsonData["durationSeconds"],
      coverArtId: jsonData["coverArtId"],
    );
  }

  static Map<String, dynamic> toMap(Playlist playlist) => {
        "id": playlist.id,
        "name": playlist.name,
        "owner": playlist.owner,
        "isPublic": playlist.isPublic,
        "createdAt": playlist.createdAt,
        "changedAt": playlist.changedAt,
        "songCount": playlist.songCount,
        "durationSeconds": playlist.durationSeconds,
        "coverArtId": playlist.coverArtId,
      };

  static String encode(List<Playlist> playlists) => json.encode(
        playlists.map<Map<String, dynamic>>(Playlist.toMap).toList(),
      );

  static List<Playlist> decode(String playlists) =>
      (json.decode(playlists) as List<dynamic>)
          .map<Playlist>((item) => Playlist.fromJson(item))
          .toList();
}
