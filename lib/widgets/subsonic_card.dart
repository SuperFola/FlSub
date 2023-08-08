import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class SubsonicCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final List<Widget> content;
  final void Function()? onTap;

  const SubsonicCard({super.key, required this.title, required this.imageUrl, required this.content, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: CachedNetworkImage(
            placeholder: (context, url) => const CircularProgressIndicator(),
            imageUrl: imageUrl,
            height: 72,
            fit: BoxFit.fill,
          ),
        ),
        onTap: onTap,
        title: Text(title),
        subtitle: Column(
          children: content,
        ),
      ),
    );
  }
}