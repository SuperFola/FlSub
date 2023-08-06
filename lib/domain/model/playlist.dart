class Playlist {
  final String id;
  final String name;
  final String owner;
  final bool isPublic;
  final String createdAt;
  final String changedAt;
  final int songCount;
  final int durationSeconds;
  final String? covertArtId;

  Playlist(this.id, this.name, this.owner, this.isPublic, this.createdAt, this.changedAt, this.songCount, this.durationSeconds, this.covertArtId);
}