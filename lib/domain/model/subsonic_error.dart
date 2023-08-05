class SubsonicError {
  final int code;
  final String message;

  static const SubsonicError unknownError = SubsonicError(-1, "unknown");

  const SubsonicError(this.code, this.message);
}