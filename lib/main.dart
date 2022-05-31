import 'dart:io';

import 'package:flutter/material.dart';
import 'package:music_player/play_song.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MaterialApp(
    home: first(),
  ));
}

class first extends StatefulWidget {
  @override
  State<first> createState() => _firstState();
}

class _firstState extends State<first> {
  OnAudioQuery audioQuery = OnAudioQuery();
  List<SongModel> songlist = [];
  bool getdata = false;

  someName() async {
    songlist = await audioQuery.querySongs();
    setState(() {
      getdata = true;
    });
  }

  permission() async {
    if (await Permission.storage.request().isGranted) {}

// You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();
    print(statuses[Permission.storage]);

    var status = await Permission.storage.status;
    if (status.isDenied) {
      permission();
    }
    if (status.isGranted) {
      someName();
    }
  }

  @override
  void initState() {
    super.initState();
    permission();
  }

  String printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: getdata
            ? ListView.builder(
                itemCount: songlist.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Image.file(File(songlist[index].),height: 50,width: 50,),
                    title: Text("${songlist[index].title}"),
                    subtitle: Text("${songlist[index].artist}"),
                    trailing: Text(printDuration(
                        Duration(milliseconds: songlist[index].duration!))),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return play_song(songlist, index);
                        },
                      ));
                    },
                  );
                },
              )
            : Center(
                child: CircularProgressIndicator(color: Colors.amber),
              ));
  }
}
