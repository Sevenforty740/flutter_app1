import 'package:flutter/material.dart';
import 'SongModel.dart';

class PlayList extends ChangeNotifier {
  List nList = new List();
  List shuffleList = new List();
  get list {
    return this.nList;
  }

  get shuffle {
    return this.shuffleList;
  }

  void add(Song song) {
    this.nList.add(song);
    shuffleList.clear();
    shuffleList.addAll(nList);
    shuffleList.shuffle();
    notifyListeners();
  }

  void remove(Song song) {
    for (int i = 0; i < this.nList.length; i++) {
      if (this.nList[i].songId == song.songId &&
          this.nList[i].source == song.source) {
        this.nList[i].removeAt(i);
      }
    }
    if (nList.isEmpty) {
      shuffleList.clear();
    } else {
      shuffleList.clear();
      shuffleList.addAll(nList);
      shuffleList.shuffle();
    }
    notifyListeners();
  }

  void clear() {
    this.nList.clear();
    this.shuffleList.clear();
    notifyListeners();
  }

  get length {
    return this.nList.length;
  }
}
