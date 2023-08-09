String formattedDurationWithHours(int durationSeconds) {
  var duration = Duration(seconds: durationSeconds);
  var hours = duration.inHours;
  var minutes = (duration.inMinutes % 60).toString().padLeft(2, "0");
  var seconds = (duration.inSeconds % 60).toString().padLeft(2, "0");
  return "$hours:$minutes:$seconds";
}

String formattedDuration(int durationSeconds) {
  var duration = Duration(seconds: durationSeconds);
  var minutes = (duration.inMinutes % 60).toString().padLeft(2, "0");
  var seconds = (duration.inSeconds % 60).toString().padLeft(2, "0");
  return "$minutes:$seconds";
}
