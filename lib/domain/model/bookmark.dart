import 'dart:convert';

class Bookmark {
  final String songId;
  final String playlistId;
  final String coverArtId;
  final String songTitle;
  final String playlistName;
  final int songPositionSeconds;
  final int songDurationSeconds;

  Bookmark({
    required this.songId,
    required this.playlistId,
    required this.coverArtId,
    required this.songTitle,
    required this.playlistName,
    required this.songPositionSeconds,
    required this.songDurationSeconds,
  });

  factory Bookmark.fromJson(Map<String, dynamic> jsonData) {
    return Bookmark(
      songId: jsonData["songId"],
      playlistId: jsonData["playlistId"],
      coverArtId: jsonData["coverArtId"],
      songTitle: jsonData["songTitle"],
      playlistName: jsonData["playlistName"],
      songPositionSeconds: jsonData["songPositionSeconds"],
      songDurationSeconds: jsonData["songDurationSeconds"],
    );
  }

  static Map<String, dynamic> toMap(Bookmark bookmark) => {
        "songId": bookmark.songId,
        "playlistId": bookmark.playlistId,
        "coverArtId": bookmark.coverArtId,
        "songTitle": bookmark.songTitle,
        "playlistName": bookmark.playlistName,
        "songPositionSeconds": bookmark.songPositionSeconds,
        "songDurationSeconds": bookmark.songDurationSeconds,
      };

  static String encode(List<Bookmark> bookmarks) => json.encode(
        bookmarks.map<Map<String, dynamic>>(Bookmark.toMap).toList(),
      );

  static List<Bookmark> decode(String bookmarks) =>
      (json.decode(bookmarks) as List<dynamic>)
          .map<Bookmark>((item) => Bookmark.fromJson(item))
          .toList();
}
