import 'package:flutter/material.dart';
import 'package:img_syncer/asset.dart';
import 'package:fijkplayer/fijkplayer.dart';
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
  final FijkPlayer player = FijkPlayer();
  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    player.setOption(FijkOption.playerCategory, "mediacodec-all-videos", 1);
    initializePlayer();
  }

  @override
  void dispose() {
    super.dispose();
    player.release();
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
      print(url);
      videoPlayerController = VideoPlayerController.network(url);
    }
    await videoPlayerController.initialize();
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      looping: true,
      showControlsOnInitialize: false,
      showOptions: false,
    );
    setState(() {
      isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0x00000000),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // body: Center(
      //   child: FutureBuilder(
      //     future: widget.asset.local!.originFile,
      //     builder: (context, file) {
      //       if (file.data != null) {
      //         final path = "file://${file.data!.absolute.path}";
      //         print(path);
      //         player.setDataSource(path, autoPlay: true, showCover: true);
      //         return FijkView(
      //           player: player,
      //           color: Colors.black,
      //         );
      //       }
      //       return Container();
      //     },
      //   ),
      // ),
      body: Center(
        child: isInitialized
            ? Chewie(
                controller: chewieController,
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
