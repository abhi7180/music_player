import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class play_song extends StatefulWidget {
  List? current_song;
  int? next_song;

  play_song(this.current_song, this.next_song);

  @override
  State<play_song> createState() => _play_songState();
}

class _play_songState extends State<play_song> {
  AudioPlayer audioPlayer = AudioPlayer();
  bool psong = false;
  String? localPath;
  int slval = 0;
  double position = 0;
  double duration = 0;
  bool get = false;

  getsong() async {
    print("pos=${widget.next_song}");
    localPath = widget.current_song![widget.next_song!].data;
    await audioPlayer.play(localPath!, isLocal: true);

    // audioPlayer.getDuration().then((value) {
    //   setState(() {
    //     slval=value;
    //     get=true;
    //   });
    // });
    await audioPlayer.onDurationChanged.listen((Duration d) {
      print('Max duration: $d');
      setState(() {
        slval = d.inMilliseconds;
        get = true;
      });
    });

    audioPlayer.onAudioPositionChanged.listen((Duration p) {
      // print('Current position: $p');
      setState(() {
        position = p.inMilliseconds.toDouble();
      });
    });

    audioPlayer.onPlayerCompletion.listen((event) {
      setState(() {
        widget.next_song = widget.next_song! + 1;
      });
      getsong();
    });
  }

  @override
  void initState() {
    super.initState();
    getsong();
  }

  @override
  void dispose() {
    super.dispose();

    audioPlayer.stop().then((value) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: get
          ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("${widget.current_song![widget.next_song!].title}"),
                Slider(
                  onChanged: (value) async {
                    setState(() async {
                      await audioPlayer
                          .seek(Duration(milliseconds: value.toInt()));
                      print("pppppppppp$position");
                    });
                  },
                  value: position.toDouble(),
                  min: 0,
                  max: slval.toDouble(),
                  activeColor: Color(0xff219F94),
                  inactiveColor: Color(0xffF2F5C8),
                  thumbColor: Colors.black,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: () async {
                          if (widget.next_song! > 0) {
                            await audioPlayer.stop();
                            widget.next_song = widget.next_song! - 1;
                            localPath =
                                widget.current_song![widget.next_song!].data;
                            await audioPlayer.play(localPath!, isLocal: true);
                          }
                          setState(() {});
                        },
                        icon: Icon(Icons.arrow_back_ios)),
                    IconButton(
                        onPressed: () async {
                          setState(() {
                            psong = !psong;
                          });
                          if (psong) {
                            await audioPlayer.pause();
                          } else {
                            await audioPlayer.resume();
                          }
                        },
                        icon:
                            psong ? Icon(Icons.play_arrow) : Icon(Icons.pause)),
                    IconButton(
                        onPressed: () async {
                          if (widget.next_song! <
                              widget.current_song!.length - 1) {
                            await audioPlayer.stop();
                            widget.next_song = widget.next_song! + 1;
                            localPath =
                                widget.current_song![widget.next_song!].data;
                            await audioPlayer.play(localPath!, isLocal: true);
                          }
                          setState(() {});
                        },
                        icon: Icon(Icons.arrow_forward_ios)),
                  ],
                )
              ],
            )
          : CircularProgressIndicator(),
    );
  }
}
