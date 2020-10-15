import 'package:flutter/material.dart';

class PlayList<Song> extends ChangeNotifier {
  List list = new List<Song>();

  void add<Song>(Song song) {
    this.list.add(song);
    notifyListeners();
  }

  get value {
    return this.list;
  }

  void remove<Song>(Song song) {
    this.list.remove(song);
    notifyListeners();
  }

  void clear() {
    this.list.clear();
    notifyListeners();
  }

  get length {
    return this.list.length;
  }
}
