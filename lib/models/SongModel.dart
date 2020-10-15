import 'package:flutter/material.dart';

class Song {
  String songId;
  String songName;
  String songUrl;
  String album;
  var duration;
  String artist;
  String source;

  Song({songId, songName, songUrl, album, duration, artist, source}) {
    this.songId = songId;
    this.songName = songName;
    this.songUrl = songUrl;
    this.album = album;
    this.duration = duration;
    this.artist = artist;
    this.source = source;
  }
}
