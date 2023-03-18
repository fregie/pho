import 'package:flutter/material.dart';
import 'package:img_syncer/storage/storage.dart';
import 'package:img_syncer/asset.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view.dart';

class NewRoute extends StatelessWidget {
  const NewRoute({
    Key? key,
    required this.asset,
  }) : super(key: key);

  final Asset asset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
      future: asset.imageData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return PhotoView(
            imageProvider: MemoryImage(snapshot.data!),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    ));
  }
}
