import 'package:flutter/material.dart';
import 'package:subsonic_flutter/domain/model/bookmark.dart' as data;
import 'package:subsonic_flutter/infrastructure/time_utils.dart';
import 'package:subsonic_flutter/widgets/cover_art_leading.dart';

class Bookmark extends StatefulWidget {
  final data.Bookmark bookmark;
  final String imageUrl;
  final String? cacheKey;
  final void Function()? onPlay;
  final void Function()? onRemove;

  String get formattedPosition =>
      formattedDuration(bookmark.songPositionSeconds);

  String get formattedLength => formattedDuration(bookmark.songDurationSeconds);

  const Bookmark({
    super.key,
    required this.bookmark,
    required this.imageUrl,
    this.cacheKey,
    this.onPlay,
    this.onRemove,
  });

  @override
  State<Bookmark> createState() => _BookmarkState();
}

class _BookmarkState extends State<Bookmark> {
  bool _showDefinitiveDelete = false;

  void _firstTapDelete() {
    setState(() {
      _showDefinitiveDelete = true;
    });

    // put the delete button in its normal state if the user does not press it again
    Future.delayed(
        const Duration(seconds: 5),
        () => setState(() {
              _showDefinitiveDelete = false;
            }));
  }

  Widget _buildDeleteButton(BuildContext context) {
    if (!_showDefinitiveDelete) {
      return IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: _firstTapDelete,
      );
    } else {
      return IconButton(
        icon: const Icon(
          Icons.delete_forever_outlined,
          color: Colors.red,
        ),
        onPressed: widget.onRemove,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CoverArtLeading(
        imageUrl: widget.imageUrl,
        cacheKey: widget.cacheKey,
      ),
      title: Text(widget.bookmark.playlistName),
      subtitle: Text(
          "${widget.bookmark.songTitle} - ${widget.formattedPosition}/${widget.formattedLength}"),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDeleteButton(context),
          IconButton(
            icon: const Icon(Icons.play_arrow_outlined),
            onPressed: widget.onPlay,
          ),
        ],
      ),
    );
  }
}
