import 'dart:io';
import 'package:flutter/material.dart';
import 'package:img_syncer/asset.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:img_syncer/global.dart';

class VideoRoute extends StatefulWidget {
  const VideoRoute({
    Key? key,
    required this.asset,
  }) : super(key: key);
  final Asset asset;

  @override
  _VideoRouteState createState() => _VideoRouteState();
}

class _VideoRouteState extends State<VideoRoute> {
  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  @override
  void dispose() {
    super.dispose();
    chewieController.dispose();
    videoPlayerController.dispose();
  }

  Future<void> initializePlayer() async {
    if (widget.asset.hasLocal) {
      final file = await widget.asset.local!.originFile;
      videoPlayerController = VideoPlayerController.file(file!);
    } else if (widget.asset.hasRemote) {
      var uri = widget.asset.remote!.path;
      if (uri[0] != '/') {
        uri = "/$uri";
      }
      final url = "$httpBaseUrl$uri";
      videoPlayerController = VideoPlayerController.network(url);
    }
    await videoPlayerController.initialize();
    Widget customControls = const MaterialControls();
    var controlsSafeAreaMinimum = const EdgeInsets.all(0);
    if (Platform.isIOS || Platform.isMacOS) {
      controlsSafeAreaMinimum = const EdgeInsets.fromLTRB(0, 30, 0, 20);
      customControls = const CupertinoControls(
          backgroundColor: Color.fromARGB(255, 82, 82, 82),
          iconColor: Colors.white);
    }
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      looping: false,
      showControlsOnInitialize: false,
      showOptions: false,
      customControls: customControls,
      allowFullScreen: false,
      allowMuting: false,
      controlsSafeAreaMinimum: controlsSafeAreaMinimum,
    );
    setState(() {
      isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
              child: isInitialized
                  ? Container(
                      // padding: const EdgeInsets.fromLTRB(0, 80, 0, 20),
                      child: Chewie(
                        controller: chewieController,
                      ),
                    )
                  : const CircularProgressIndicator(),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                backgroundColor: const Color(0x00000000),
                iconTheme: const IconThemeData(color: Colors.white),
              ),
            ),
          ],
        ));
  }
}
