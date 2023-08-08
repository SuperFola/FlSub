class Song {
  final String id;
  final String parentId;
  final String title;
  final String type;
  final String albumId;
  final String album;
  final String artistId;
  final String artist;
  final String? covertArtId;
  final int durationSeconds;
  final int bitRate;
  final int year;
  final int size;
  final String contentType;

  Song(
    this.id,
    this.parentId,
    this.title,
    this.type,
    this.albumId,
    this.album,
    this.artistId,
    this.artist,
    this.covertArtId,
    this.durationSeconds,
    this.bitRate,
    this.year,
    this.size,
    this.contentType,
  );

  String get formattedDuration {
    var duration = Duration(seconds: durationSeconds);
    var minutes = (duration.inMinutes % 60).toString().padLeft(2, "0");
    var seconds = (duration.inSeconds % 60).toString().padLeft(2, "0");
    return "$minutes:$seconds";
  }
}
