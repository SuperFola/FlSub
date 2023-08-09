import 'package:flutter/material.dart';
import 'package:subsonic_flutter/widgets/cover_art_leading.dart';

class SubsonicCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final List<Widget> content;
  final String? cacheKey;
  final bool? isThreeLines;
  final void Function()? onTap;

  const SubsonicCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.content,
    this.cacheKey,
    this.isThreeLines,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
      child: Card(
        child: ListTile(
          leading: CoverArtLeading(
            imageUrl: imageUrl,
            cacheKey: cacheKey,
          ),
          onTap: onTap,
          title: Text(title, overflow: TextOverflow.ellipsis, maxLines: 1),
          subtitle: Column(
            children: content,
          ),
          isThreeLine: isThreeLines ?? false,
        ),
      ),
    );
  }
}
