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
        "https://s320.xiami.net/258/23258/2102673536/1795425255_1482921827440.mp3?ccode=xiami_web_web&expire=86400&duration=218&psid=e46c3ff612e74411e0a792a446ce9470&ups_client_netip=218.249.201.130&ups_ts=1602814811&ups_userid=0&utid=0cxpF6nDWRsCAdr5yYKfFVQD&vid=1795425255&fn=1795425255_1482921827440.mp3&vkey=B3354e4ab339352c8791a85aa94693f8f",
    album: "Your Songs 2017",
    duration: "03:39",
    artist: "Selena Gomez",
    source: "xiami");

Song song2 = new Song(
    songId: '2',
    songName: "Tuscany",
    songUrl:
        "https://s128.xiami.net/267/2111840267/5020760237/2100857155_1590687184422_2103.mp3?ccode=xiami_web_web&expire=86400&duration=205&psid=f9662c6345b29cd9b6147b97e895f5b1&ups_client_netip=218.249.201.130&ups_ts=1602814847&ups_userid=0&utid=0cxpF6nDWRsCAdr5yYKfFVQD&vid=2100857155&fn=2100857155_1590687184422_2103.mp3&vkey=B9ef76ed3555c5c4a6552cfaaaeecc6be",
    album: "Tuscany",
    duration: "03:25",
    artist: "Anja Kotar",
    source: "xiami");

Song song3 = new Song(
    songId: '3',
    songName: "Creep",
    songUrl:
        "https://s128.xiami.net/454/10454/169475/2092776_2026402_l.mp3?ccode=xiami_web_web&expire=86400&duration=237&psid=f82104e0b54dbfc43407e93637279bca&ups_client_netip=218.249.201.130&ups_ts=1602814907&ups_userid=0&utid=0cxpF6nDWRsCAdr5yYKfFVQD&vid=2092776&fn=2092776_2026402_l.mp3&vkey=Bb818a124ef61995f20c69c04da7ad8f0",
    album: "The Best of Radiohead",
    duration: "03:57",
    artist: "RadioHead",
    source: "xiami");

Song song4 = new Song(
    songId: '4',
    songName: "Do You?",
    songUrl:
        "https://s320.xiami.net/177/1787589177/126831533/1774082918_16421925_h.mp3?ccode=xiami_web_web&expire=86400&duration=202&psid=05fd74520dbb22ff2615d85ef27acb13&ups_client_netip=218.249.201.130&ups_ts=1602815074&ups_userid=0&utid=0cxpF6nDWRsCAdr5yYKfFVQD&vid=1774082918&fn=1774082918_16421925_h.mp3&vkey=Be43f64aeafa2a4336f295c3ca9095866",
    album: "Do You?",
    duration: "03:22",
    artist: "TroyBoi",
    source: "xiami");

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) {
      return new PlayingSong(
          songId: '999',
          songName: "他的方式(Demo)",
          songUrl:
              "https://s320.xiami.net/248/1472992248/0/1776354248_0_h.mp3?ccode=xiami_web_web&expire=86400&duration=269&psid=cb967034b4ece6cc5a05117f5f62ae7e&ups_client_netip=218.249.201.130&ups_ts=1602814715&ups_userid=0&utid=0cxpF6nDWRsCAdr5yYKfFVQD&vid=1776354248&fn=1776354248_0_h.mp3&vkey=B638182d8d919234d80bd85dfd364993d",
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
        children: widget.playlist.list.map<Widget>((song) {
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
