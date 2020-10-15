import 'package:flutter/material.dart';

class PlayingSong extends ChangeNotifier {
  String songId;
  String songName;
  String songUrl;
  String album;
  var duration;
  String artist;
  String source;

  PlayingSong({songId, songName, songUrl, album, duration, artist, source}) {
    this.songId = songId;
    this.songName = songName;
    this.songUrl = songUrl;
    this.album = album;
    this.duration = duration;
    this.artist = artist;
    this.source = source;
  }

  void update({songId, songName, songUrl, album, duration, artist, source}) {
    this.songId = songId;
    this.songName = songName;
    this.songUrl = songUrl;
    this.album = album;
    this.duration = duration;
    this.artist = artist;
    this.source = source;
    notifyListeners();
  }
}
