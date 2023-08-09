import 'dart:convert';

class Song {
  final String id;
  final String parentId;
  final String title;
  final String type;
  final String albumId;
  final String album;
  final String artistId;
  final String artist;
  final String? coverArtId;
  final int durationSeconds;
  final int bitRate;
  final int? year;
  final int size;
  final String contentType;

  Song({
    required this.id,
    required this.parentId,
    required this.title,
    required this.type,
    required this.albumId,
    required this.album,
    required this.artistId,
    required this.artist,
    this.coverArtId,
    required this.durationSeconds,
    required this.bitRate,
    this.year,
    required this.size,
    required this.contentType,
  });

  String get safeCoverArtId => coverArtId ?? "800000000";

  factory Song.fromJson(Map<String, dynamic> jsonData) {
    return Song(
      id: jsonData["id"],
      parentId: jsonData["parentId"],
      title: jsonData["title"],
      type: jsonData["type"],
      albumId: jsonData["albumId"],
      album: jsonData["album"],
      artistId: jsonData["artistId"],
      artist: jsonData["artist"],
      coverArtId: jsonData["coverArtId"],
      durationSeconds: jsonData["durationSeconds"],
      bitRate: jsonData["bitRate"],
      year: jsonData["year"],
      size: jsonData["size"],
      contentType: jsonData["contentType"],
    );
  }

  static Map<String, dynamic> toMap(Song song) => {
        "id": song.id,
        "parentId": song.parentId,
        "title": song.title,
        "type": song.type,
        "albumId": song.albumId,
        "album": song.album,
        "artistId": song.artistId,
        "artist": song.artist,
        "coverArtId": song.coverArtId,
        "durationSeconds": song.durationSeconds,
        "bitRate": song.bitRate,
        "year": song.year,
        "size": song.size,
        "contentType": song.contentType,
      };

  static String encode(List<Song> songs) => json.encode(
        songs.map<Map<String, dynamic>>(Song.toMap).toList(),
      );

  static List<Song> decode(String songs) =>
      (json.decode(songs) as List<dynamic>)
          .map<Song>((item) => Song.fromJson(item))
          .toList();
}
