import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: SizedBox.square(
              dimension: 56,
              child: CachedNetworkImage(
                fadeInCurve: Curves.fastLinearToSlowEaseIn,
                cacheKey: cacheKey ?? imageUrl,
                maxHeightDiskCache: 128,
                imageUrl: imageUrl,
                fit: BoxFit.cover,
              ),
            ),
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
