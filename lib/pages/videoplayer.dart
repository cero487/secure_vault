import 'dart:ffi';
import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:video_player/video_player.dart';

class Videoplayer extends StatefulWidget {
  final int initialindex;
  const Videoplayer(this.initialindex, {super.key});

  @override
  State<Videoplayer> createState() => _VideoplayerState();
}

class _VideoplayerState extends State<Videoplayer> {
  final _videobox = Hive.box<String>('videobox');

  late PageController _pageController;

  @override
  void initState(){
    super.initState();
    _pageController = PageController(initialPage: widget.initialindex);
  }

  @override
  void dispose(){
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      body: ValueListenableBuilder(
        valueListenable: _videobox.listenable(),
        builder: (context, Box<String> box, _) {
          final List<String> savedData = box.values.toList();
          if (savedData.isEmpty) {
            return Center(child: Text("No video found", style: TextStyle(color: Colors.white),),);
          }
          return PageView.builder(
            controller: _pageController,
            itemCount: savedData.length,
            itemBuilder: (context, index){
              int reversedindex = savedData.length-1-index;
              List<String> paths = savedData[reversedindex].split('||');
              String videopath = paths[0];
              return SingleVideoScreen(
                actualindex: reversedindex,
                videoPath: videopath
                );
          });
        }
      ),
      // floatingActionButton:SizedBox(
      //   width: 140,
      //   child: Row(
      //     children: [
      //       GestureDetector(
      //         onTap: ()async{
      //         int currentindex = _pageController.page?.round() ?? widget.initialindex;
      //         int reverseindex = _videobox.length-1-currentindex;
      //         String? data = _videobox.getAt(reverseindex);

      //         if (data != null){
      //           try{
      //             List<String> paths = data.split('||');
      //             String videopath = paths[0];
      //             String thumbpath = paths.length > 1 ? paths[1]: '';
      //             await Gal.putVideo(videopath);
      //             ScaffoldMessenger.of(context).showSnackBar(
      //               const SnackBar(content: Text("Restored to gallary")),
      //             );
      //           }catch (e){
      //             ScaffoldMessenger.of(context).showSnackBar(
      //               SnackBar(content: Text("Error: $e")),
      //             );
      //           }
      //         }
      //       },
      //         child: Container(
      //           height: 50,
      //           width: 70,
      //           decoration: BoxDecoration(
      //             color: Colors.purpleAccent,
      //             borderRadius: BorderRadius.only(
      //               topLeft: Radius.circular(50),
      //               bottomLeft: Radius.circular(50)
      //             )
      //           ),
      //           child: Icon(Icons.restore,color: Colors.white,size: 30,),
      //         ),
      //       ),
      //       GestureDetector(
      //         onTap: () async{
      //           int uiIndex = _pageController.page?.round() ?? widget.initialindex;
      //           int reversedindex = _videobox.length-1-uiIndex;
      //           String? data = _videobox.getAt(reversedindex);

      //           if(data != null){
      //             List<String> paths = data.split('||');
      //             File videoFile = File(paths[0]);
      //             File thumbFile = File(paths.length > 1 ? paths[1]: '');

      //             if(await videoFile.exists()) await videoFile.delete();
      //             if(await thumbFile.exists()) await thumbFile.delete();
      //             await _videobox.deleteAt(reversedindex);

      //             if(_videobox.isEmpty) Navigator.pop(context);}

      //         },
      //         child: Container(
      //           height: 50,
      //           width: 70,
      //           decoration: BoxDecoration(
      //             color: Colors.redAccent,
      //             borderRadius: BorderRadius.only(
      //               topRight: Radius.circular(50),
      //               bottomRight: Radius.circular(50)
      //             )
      //           ),
      //           child: Icon(Icons.delete,color: Colors.white,size: 30,),
      //         ),
      //       )
      //     ],
      //   ),
      // ) 
      // FloatingActionButton(
      //   backgroundColor: Colors.redAccent,
      //   child: Icon(Icons.delete, color: Colors.white,),
      //   onPressed: () async {
      //     int uiIndex = _pageController.page?.round() ?? widget.initialindex;
      //     int reversedindex = _videobox.length-1-uiIndex;
      //     String? data = _videobox.getAt(reversedindex);

      //     if(data != null){
      //       List<String> paths = data.split('||');
      //       File videoFile = File(paths[0]);
      //       File thumbFile = File(paths.length > 1 ? paths[1]: '');

      //       if(await videoFile.exists()) await videoFile.delete();
      //       if(await thumbFile.exists()) await thumbFile.delete();
      //       await _videobox.deleteAt(reversedindex);

      //       if(_videobox.isEmpty) Navigator.pop(context);
      //     }
      // }),
    );
  }
}


class SingleVideoScreen extends StatefulWidget{
  final String videoPath;
  final int actualindex;
  const SingleVideoScreen({super.key, required this.videoPath, required this.actualindex});

  @override
  State<SingleVideoScreen> createState() => _SingleVideoScreenState();
}
class _SingleVideoScreenState extends State<SingleVideoScreen>{
  late VideoPlayerController _controller;
  bool _showControls = true;
  final _videobox = Hive.box<String>('videobox');
  Timer? _hideTimer;

  void _startHideTimer(){
    _hideTimer?.cancel();
    _hideTimer = Timer(Duration(seconds: 3), (){
      if (mounted && _controller.value.isPlaying){
        setState(() {
          _showControls = false;
        });
      }
    });
  }


  @override
  void initState(){
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_){
        setState(() {});
        _controller.play();
        _startHideTimer();
        WakelockPlus.enable();
      });
  }


@override
void dispose(){
  _hideTimer?.cancel();
  _controller.pause();
  _controller.dispose();
  WakelockPlus.disable();
  super.dispose();
}

@override
Widget build(BuildContext context){
  return Center(
    child: _controller.value.isInitialized ? GestureDetector(
      onTap: () {
        setState((){
          _showControls = !_showControls;
        });
        if(_showControls){
          _startHideTimer();
        }else{
          _hideTimer?.cancel();
        }
      },
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_controller),
            if (_showControls)...[
              Container(color: Colors.black38,),
              Positioned(
                top: 20,
                right: 16,
                child: Row(
                  children: [
                    Opacity(
                      opacity: 0.6,
                      child: GestureDetector(
                                    onTap: ()async{
                                    String? data = _videobox.getAt(widget.actualindex);
                      
                                    if (data != null){
                                      try{
                                        List<String> paths = data.split('||');
                                        String videopath = paths[0];
                                        String thumbpath = paths.length > 1 ? paths[1]: '';
                                        await Gal.putVideo(videopath);
                                        ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Restored to gallary")),
                                        );
                                      }catch (e){
                                        ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                                        );
                                      }
                                    }
                                  },
                                    child: Container(
                                      height: 50,
                                      width: 70,
                                      decoration: BoxDecoration(
                                        color: Colors.purpleAccent.withOpacity(0.1),
                                        borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      bottomLeft: Radius.circular(50)
                                        )
                                      ),
                                      child: Icon(Icons.restore,color: Colors.white,size: 30,),
                                    ),
                                  ),
                    ),
            Opacity(
              opacity: 0.6,
              child: GestureDetector(
                onTap: () async{
                  String? data = _videobox.getAt(widget.actualindex);
              
                  if(data != null){
                    List<String> paths = data.split('||');
                    File videoFile = File(paths[0]);
                    File thumbFile = File(paths.length > 1 ? paths[1]: '');
              
                    if(await videoFile.exists()) await videoFile.delete();
                    if(await thumbFile.exists()) await thumbFile.delete();
                    await _videobox.deleteAt(widget.actualindex);
              
                    if(_videobox.isEmpty) Navigator.pop(context);}
              
                },
                child: Container(
                  height: 50,
                  width: 70,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(50),
                      bottomRight: Radius.circular(50)
                    )
                  ),
                  child: Icon(Icons.delete,color: Colors.white,size: 30,),
                ),
              ),
            )
            ],
            )),
            GestureDetector(
              onTap: () {
                setState(() {
                  _controller.value.isPlaying ? _controller.pause(): _controller.play();
                });
              },
              child: Icon(_controller.value.isPlaying ? Icons.pause: Icons.play_circle_fill, size: 50, color: Colors.white70,),
            ),
            Positioned(
              bottom: 15,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PopupMenuButton<double>(
                    initialValue: _controller.value.playbackSpeed,
                    onSelected: (speed){
                      _controller.setPlaybackSpeed(speed);
                      setState(() {});
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 0.5, child: Text("0.5x (slow)")),
                      const PopupMenuItem(value: 1.0, child: Text("1.0x (normal)")),
                      const PopupMenuItem(value: 1.5, child: Text("1.5x (fast)")),
                      const PopupMenuItem(value: 2.0, child: Text("2.0x (very fast)")),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: Text("${_controller.value.playbackSpeed}x",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                    ),
                    ),
                    ValueListenableBuilder(
                      valueListenable: _controller,
                      builder: (context, VideoPlayerValue value, child) {
                        String formatTime(Duration duration){
                          String twoDigits(int n) => n.toString().padLeft(2, '0');
                          String minutes = twoDigits(duration.inMinutes.remainder(60));
                          String seconds = twoDigits(duration.inSeconds.remainder(60));
                          if (duration.inHours > 0){
                            return "${duration.inHours}:$minutes:$seconds";
                          }
                          return "$minutes:$seconds";
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formatTime(value.position),
                                  style: TextStyle(color: Colors.white,fontSize: 12),
                                ),
                                Text(
                                  formatTime(value.duration),
                                  style: TextStyle(color: Colors.white,fontSize: 12),
                                ),
                              ],
                            ),
                            SizedBox(height: 4,),
                            VideoProgressIndicator(
                              _controller, 
                              allowScrubbing: true,
                              padding: EdgeInsets.symmetric(vertical: 8),
                              colors: const VideoProgressColors(
                                playedColor: Color(0xFF6C63FF),
                                bufferedColor: Colors.white10,
                                backgroundColor: Colors.white10
                              )),
                          ],
                        );
                      }
                    )
                ],
              ))]
          ],
        ),
    ),)
  :CircularProgressIndicator(color: Color(0xFF6C63FF)),);
}}