import 'package:flutter/material.dart';
import 'package:img_syncer/choose_album_route.dart';

Widget chooseAlbumButtun(BuildContext context) {
  return IconButton(
    icon: const Icon(Icons.photo_album),
    color: Theme.of(context).iconTheme.color,
    tooltip: 'Choose album',
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChooseAlbumRoute()),
      );
    },
  );
}
