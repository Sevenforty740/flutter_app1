import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app1/models/SongModel.dart';
import 'models/PlayingSongModel.dart';
import 'package:provider/provider.dart';
import 'models/PlayListModel.dart';

enum PlayerState { stopped, playing, paused }
enum PlayingRouteState { speakers, earpiece }

class PlayerWidget extends StatefulWidget {
  final PlayingSong playingSong;
  final PlayerMode mode;

  PlayerWidget(
      {Key key,
      @required this.playingSong,
      this.mode = PlayerMode.MEDIA_PLAYER})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PlayerWidgetState(playingSong, mode);
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {
  PlayingSong playingSong;
  PlayerMode mode;
  int playMode = 1;

  AudioPlayer _audioPlayer;
  AudioPlayerState _audioPlayerState;
  Duration _duration;
  Duration _position;

  PlayerState _playerState = PlayerState.stopped;
  PlayingRouteState _playingRouteState = PlayingRouteState.speakers;
  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerErrorSubscription;
  StreamSubscription _playerStateSubscription;
  StreamSubscription<PlayerControlCommand> _playerControlCommandSubscription;

  get _isPlaying => _playerState == PlayerState.playing;
  get _isPaused => _playerState == PlayerState.paused;
  get _durationText => _duration?.toString()?.split('.')?.first ?? '';
  get _positionText => _position?.toString()?.split('.')?.first ?? '';

  get _isPlayingThroughEarpiece =>
      _playingRouteState == PlayingRouteState.earpiece;

  _PlayerWidgetState(this.playingSong, this.mode);

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _playerControlCommandSubscription?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(PlayerWidget oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (_isPlaying || _isPaused) {
      _playerState = PlayerState.stopped;
      _position = Duration();
      _play();
    } else {
      _play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: Key('play_button'),
              onPressed: _isPlaying ? null : () => _play(),
              iconSize: 48.0,
              icon: Icon(Icons.play_arrow),
              color: Colors.cyan,
            ),
            IconButton(
              key: Key('pause_button'),
              onPressed: _isPlaying ? () => _pause() : null,
              iconSize: 48.0,
              icon: Icon(Icons.pause),
              color: Colors.cyan,
            ),
            IconButton(
              key: Key('prev_button'),
              onPressed: () => _prev(),
              iconSize: 48.0,
              icon: Icon(Icons.skip_previous),
              color: Colors.cyan,
            ),
            IconButton(
              key: Key('next_button'),
              onPressed: () => _next(),
              iconSize: 48.0,
              icon: Icon(Icons.skip_next),
              color: Colors.cyan,
            ),
            IconButton(
              key: Key('play_mode'),
              onPressed: () {
                setState(() {
                  if (playMode == 1 || playMode == 2) {
                    playMode++;
                  } else {
                    playMode = 1;
                  }
                });
              },
              iconSize: 26.0,
              icon: playModeIcon(playMode),
              color: Colors.cyan,
            ),
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Stack(
                children: [
                  Slider(
                    onChanged: (v) {
                      final Position = v * _duration.inMilliseconds;
                      _audioPlayer
                          .seek(Duration(milliseconds: Position.round()));
                    },
                    value: (_position != null &&
                            _duration != null &&
                            _position.inMilliseconds > 0 &&
                            _position.inMilliseconds < _duration.inMilliseconds)
                        ? _position.inMilliseconds / _duration.inMilliseconds
                        : 0.0,
                  ),
                ],
              ),
            ),
            Text(
              _position != null
                  ? '${_positionText ?? ''} / ${_durationText ?? ''}'
                  : _duration != null ? _durationText : '',
              style: TextStyle(fontSize: 24.0),
            ),
          ],
        ),
        Text('State: $_audioPlayerState')
      ],
    );
  }

  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer(mode: mode);

    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);

      // TODO implemented for iOS, waiting for android impl
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        // (Optional) listen for notification updates in the background
        _audioPlayer.startHeadlessService();

        // set at least title to see the notification bar on ios.
        _audioPlayer.setNotification(
          title: 'App Name',
          artist: 'Artist or blank',
          albumTitle: 'Name or blank',
          imageUrl: 'url or blank',
          // forwardSkipInterval: const Duration(seconds: 30), // default is 30s
          // backwardSkipInterval: const Duration(seconds: 30), // default is 30s
          duration: duration,
          elapsedTime: Duration(seconds: 0),
          hasNextTrack: true,
          hasPreviousTrack: false,
        );
      }
    });

    _positionSubscription =
        _audioPlayer.onAudioPositionChanged.listen((p) => setState(() {
              _position = p;
            }));

    _playerCompleteSubscription =
        _audioPlayer.onPlayerCompletion.listen((event) {
      _onComplete();
      if (playMode == 2) {
        _playerState = PlayerState.stopped;
        _position = Duration();
        _play();
      } else {
        _next(); // 播放完成后 播下一首
        setState(() {
          _position = _duration;
        });
      }
    });

    _playerErrorSubscription = _audioPlayer.onPlayerError.listen((msg) {
      print('audioPlayer error : $msg');
      setState(() {
        _playerState = PlayerState.stopped;
        _duration = Duration(seconds: 0);
        _position = Duration(seconds: 0);
      });
    });

    _playerControlCommandSubscription =
        _audioPlayer.onPlayerCommand.listen((command) {
      print('command');
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _audioPlayerState = state;
      });
    });

    _audioPlayer.onNotificationPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _audioPlayerState = state);
    });

    _playingRouteState = PlayingRouteState.speakers;
  }

  // Kmusic使用 需要在play中通过id source 获取播放url
  Future<int> _play() async {
    final playPosition = (_position != null &&
            _duration != null &&
            _position.inMilliseconds > 0 &&
            _position.inMilliseconds < _duration.inMilliseconds)
        ? _position
        : null;
    final result =
        await _audioPlayer.play(playingSong.songUrl, position: playPosition);
    if (result == 1) setState(() => _playerState = PlayerState.playing);

    // default playback rate is 1.0
    // this should be called after _audioPlayer.play() or _audioPlayer.resume()
    // this can also be called everytime the user wants to change playback rate in the UI
    _audioPlayer.setPlaybackRate(playbackRate: 1.0);

    return result;
  }

  Future<int> _pause() async {
    final result = await _audioPlayer.pause();
    if (result == 1) setState(() => _playerState = PlayerState.paused);
    return result;
  }

  Future<int> _earpieceOrSpeakersToggle() async {
    final result = await _audioPlayer.earpieceOrSpeakersToggle();
    if (result == 1)
      setState(() => _playingRouteState =
          _playingRouteState == PlayingRouteState.speakers
              ? PlayingRouteState.earpiece
              : PlayingRouteState.speakers);
    return result;
  }

  Future<int> _stop() async {
    final result = await _audioPlayer.stop();
    if (result == 1) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = Duration();
      });
    }
    return result;
  }

  Future<int> _next() async {
    var playlist;
    if (playMode == 3) {
      playlist = Provider.of<PlayList>(context, listen: false).shuffle;
      for (var i = 0; i < playlist.length; i++) {
        print(playlist[i].songName);
      }
    } else {
      playlist = Provider.of<PlayList>(context, listen: false).list;
    }

    int index = checkSameSong(playlist, playingSong);
    if (index == -1) {
      if (playlist.isEmpty) {
        return -1;
      } else {
        Provider.of<PlayingSong>(context, listen: false).update(
            songId: playlist[0].songId,
            songName: playlist[0].songName,
            songUrl: playlist[0].songUrl,
            album: playlist[0].album,
            duration: playlist[0].duration,
            artist: playlist[0].artist,
            source: playlist[0].source);
      }
    } else {
      if (index == playlist.length - 1) {
        index = 0;
      } else {
        index++;
      }
      Provider.of<PlayingSong>(context, listen: false).update(
          songId: playlist[index].songId,
          songName: playlist[index].songName,
          songUrl: playlist[index].songUrl,
          album: playlist[index].album,
          duration: playlist[index].duration,
          artist: playlist[index].artist,
          source: playlist[index].source);
    }
    return 1;
  }

  Future<int> _prev() async {
    var playlist;
    if (playMode == 3) {
      playlist = Provider.of<PlayList>(context, listen: false).shuffle;
    } else {
      playlist = Provider.of<PlayList>(context, listen: false).list;
    }
    int index = checkSameSong(playlist, playingSong);
    if (index == -1) {
      if (playlist.isEmpty) {
        return -1;
      } else {
        Provider.of<PlayingSong>(context, listen: false).update(
            songId: playlist[-1].songId,
            songName: playlist[-1].songName,
            songUrl: playlist[-1].songUrl,
            album: playlist[-1].album,
            duration: playlist[-1].duration,
            artist: playlist[-1].artist,
            source: playlist[-1].source);
      }
    } else {
      if (index == 0) {
        index = playlist.length - 1;
      } else {
        index--;
      }
      Provider.of<PlayingSong>(context, listen: false).update(
          songId: playlist[index].songId,
          songName: playlist[index].songName,
          songUrl: playlist[index].songUrl,
          album: playlist[index].album,
          duration: playlist[index].duration,
          artist: playlist[index].artist,
          source: playlist[index].source);
    }
    return 1;
  }

  void _onComplete() {
    setState(() => _playerState = PlayerState.stopped);
  }
}

int checkSameSong(List list, PlayingSong playingSong) {
  for (var i = 0; i < list.length; i++) {
    if (list[i].songName == playingSong.songName &&
        list[i].songUrl == playingSong.songUrl &&
        list[i].songId == playingSong.songId &&
        list[i].album == playingSong.album &&
        list[i].duration == playingSong.duration &&
        list[i].artist == playingSong.artist &&
        list[i].source == playingSong.source) {
      return i;
    }
  }
  return -1;
}

Icon playModeIcon(int playMode) {
  if (playMode == 1) {
    // 顺序
    return Icon(IconData(0xe6cf, fontFamily: 'iconfont'));
  } else if (playMode == 2) {
    //单曲
    return Icon(IconData(0xe698, fontFamily: 'iconfont'));
  } // 随机
  return Icon(IconData(0xe7ff, fontFamily: 'iconfont'));
}
