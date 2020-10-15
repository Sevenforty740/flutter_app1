import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/src/foundation/constants.dart';
import 'models/PlayingSongModel.dart';
import 'models/SongModel.dart';
import 'models/PlayListModel.dart';

import 'player_widget.dart';

typedef void OnError(Exception exception);
Song song1 = new Song(
    songId: '1',
    songName: "We Don't Talk Anymore",
    songUrl:
        "https://s320.xiami.net/258/23258/2102673536/1795425255_1482921827440.mp3?ccode=xiami_web_web&expire=86400&duration=218&psid=673927da76a79c9552bc0b0ee93e25d7&ups_client_netip=2408:8207:30dd:7130:c560:5e90:f28d:828b&ups_ts=1602682128&ups_userid=0&utid=S0HuFhM+nwUCAd3crf05pX+o&vid=1795425255&fn=1795425255_1482921827440.mp3&vkey=Bd5e72f66f0ed5bcc2a482580ac7e6eec",
    album: "Your Songs 2017",
    duration: "03:39",
    artist: "Selena Gomez",
    source: "xiami");

Song song2 = new Song(
    songId: '2',
    songName: "Tuscany",
    songUrl:
        "https://s128.xiami.net/267/2111840267/5020760237/2100857155_1590687184422_2103.mp3?ccode=xiami_web_web&expire=86400&duration=205&psid=03f1b2ab3dcc891962b1514b205e29da&ups_client_netip=2408:8207:30dd:7130:c560:5e90:f28d:828b&ups_ts=1602682215&ups_userid=0&utid=S0HuFhM+nwUCAd3crf05pX+o&vid=2100857155&fn=2100857155_1590687184422_2103.mp3&vkey=B2d141b23878e20de6b20a9e692520ed9",
    album: "Tuscany",
    duration: "03:25",
    artist: "Anja Kotar",
    source: "xiami");

Song song3 = new Song(
    songId: '3',
    songName: "New York City",
    songUrl:
        "https://s320.xiami.net/644/2110194644/5021383811/2104473798_1598873681261_516.mp3?ccode=xiami_web_web&expire=86400&duration=197&psid=05f48f7eda1d6fa07d9c98b8fb28846c&ups_client_netip=2408:8207:30dd:7130:c560:5e90:f28d:828b&ups_ts=1602682260&ups_userid=0&utid=S0HuFhM+nwUCAd3crf05pX+o&vid=2104473798&fn=2104473798_1598873681261_516.mp3&vkey=Be83f4741e2070be39baad5f7217c7163",
    album: "Losing Your Love",
    duration: "03:17",
    artist: "Micky Skeel",
    source: "xiami");

Song song4 = new Song(
    songId: '4',
    songName: "Falling",
    songUrl:
        "https://s320.xiami.net/180/2110620180/2104831524/1811396663_1556641873692_9470.mp3?ccode=xiami_web_web&expire=86400&duration=193&psid=037ac0866113f0537a592a12cec8d03c&ups_client_netip=2408:8207:30dd:7130:c560:5e90:f28d:828b&ups_ts=1602682300&ups_userid=0&utid=S0HuFhM+nwUCAd3crf05pX+o&vid=1811396663&fn=1811396663_1556641873692_9470.mp3&vkey=B5f41fa272942cc4a83c56f6955ae9bc5",
    album: "Lovestruck",
    duration: "03:13",
    artist: "大笑",
    source: "xiami");

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) {
      return new PlayingSong(
          songId: '999',
          songName: "他的方式(Demo)",
          songUrl:
              "https://s320.xiami.net/248/1472992248/0/1776354248_0_h.mp3?ccode=xiami_web_web&expire=86400&duration=269&psid=8c940927e16f9f3fe66a2e9366bc0ff9&ups_client_netip=2408:8207:30dd:7130:c560:5e90:f28d:828b&ups_ts=1602682072&ups_userid=0&utid=S0HuFhM+nwUCAd3crf05pX+o&vid=1776354248&fn=1776354248_0_h.mp3&vkey=Ba1f1134c0985822ccd46a8fd05929065",
          album: "他的方式",
          duration: "04:29",
          artist: "大波浪",
          source: "xiami");
    }),
    ChangeNotifierProvider(create: (_) {
      var l = new PlayList();
      l.add(song1);
      l.add(song2);
      l.add(song3);
      l.add(song4);
      return l;
    }),
  ], child: MaterialApp(home: ExampleApp())));
}

class ExampleApp extends StatefulWidget {
  @override
  _ExampleAppState createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  AudioCache audioCache = AudioCache();
  AudioPlayer advancedPlayer = AudioPlayer();
  String localFilePath;
  PlayList playList = new PlayList();

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      // Calls to Platform.isIOS fails on web
      return;
    }
    if (Platform.isIOS) {
      if (audioCache.fixedPlayer != null) {
        audioCache.fixedPlayer.startHeadlessService();
      }
      advancedPlayer.startHeadlessService();
    }
  }

  Widget remoteUrl() {
    return SingleChildScrollView(
        child: _Tab(children: [
      Text(
        '播放控件Demo',
        key: Key('url1'),
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      PlayerWidget(
          playingSong: Provider.of<PlayingSong>(context, listen: true)),
      Text(Provider.of<PlayingSong>(context, listen: true).songName),
      Text(Provider.of<PlayingSong>(context, listen: true).artist),
      Text("《${Provider.of<PlayingSong>(context, listen: true).album}》"),
      PlaylistWidget(playlist: Provider.of<PlayList>(context, listen: true))
    ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('audioplayers Demo'),
      ),
      body: remoteUrl(),
    );
  }
}

class _Tab extends StatelessWidget {
  final List<Widget> children;

  const _Tab({Key key, this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: children
                .map((w) => Container(child: w, padding: EdgeInsets.all(6.0)))
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final String txt;
  final VoidCallback onPressed;

  const _Btn({Key key, this.txt, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
        minWidth: 48.0,
        child: RaisedButton(child: Text(txt), onPressed: onPressed));
  }
}

class PlaylistWidget extends StatefulWidget {
  final PlayList playlist;
  PlaylistWidget({Key key, this.playlist}) : super(key: key);

  @override
  _PlaylistWidgetState createState() => _PlaylistWidgetState();
}

class _PlaylistWidgetState extends State<PlaylistWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
        children: widget.playlist.value.map<Widget>((song) {
      return SizedBox(
          width: 400,
          child: FlatButton(
              color: Colors.blue[100],
              onPressed: () {
                Provider.of<PlayingSong>(context, listen: false).update(
                    songId: song.songId,
                    songName: song.songName,
                    songUrl: song.songUrl,
                    album: song.album,
                    duration: song.duration,
                    artist: song.artist,
                    source: song.source);
              },
              child: Column(children: [Text("${song.songName}")])));
    }).toList());
  }
}
