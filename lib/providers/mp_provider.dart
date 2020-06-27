import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:muzic/models/favs.dart';
import 'package:muzic/ui_tools/song_item.dart';

class MPProvider with ChangeNotifier {
  AudioPlayer _audioPlayer = AudioPlayer();
  String _currentSongTitle;
  String _currentSongPath;
  String _currentSongPic;
  List<Song> _songsWidgets = [];
  List<Song> _favSongsWidgets = [];
  List<SongInfo> _songs;
  int _songIndex = 0;
  var _playIconState = Icons.play_arrow;
  bool favState = false;
  bool shuffle = false;
  bool repeat = false;
  String songCurrTime = "";
  double sliderVal = 0;

  MPProvider() {
    _audioPlayer.onAudioPositionChanged.listen((d) {
      sliderVal = double.parse(d.inMilliseconds.toString());
      songCurrTime = calculateSongTime(d.inMilliseconds.toString());
      notifyListeners();
    });
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == AudioPlayerState.COMPLETED) {
        _playIconState = Icons.play_arrow;
        if (shuffle) {
          print('random!!');
          playRandom();
        } else if (repeat && _songIndex == _songs.length - 1) {
          next();
        } else if (!repeat) {
        } else
          next();
      } else if (state == AudioPlayerState.PAUSED ||
          state == AudioPlayerState.STOPPED) {
        _playIconState = Icons.play_arrow;
      } else
        _playIconState = Icons.pause;
      checkFav();
    });
  }

  AudioPlayer get audioPlayer {
    return _audioPlayer;
  }

  String get currentSongTitle {
    return _currentSongTitle;
  }

  List<Song> get songsWidgets {
    return _songsWidgets;
  }

  List<Song> get favSongsWidgets {
    return _favSongsWidgets;
  }

  String get currentSongPath {
    return _currentSongPath;
  }

  String get currentSongPic {
    return _currentSongPic;
  }

  List<SongInfo> get songs {
    return _songs;
  }

  int get songIndex {
    return _songIndex;
  }

  dynamic get playIconState {
    return _playIconState;
  }

  setCurrentSongTitle(String title) {
    _currentSongTitle = title;
  }

  setCurrentSongPath(String path) {
    _currentSongPath = path;
  }

  setCurrentSongPic(String pic) {
    _currentSongPic = pic;
  }

  Future<void> fetchSongs() async {
    _songs = [];
    _songs = await FlutterAudioQuery().getSongs();
    setPlayNow(songs[songIndex].title, songs[songIndex].albumArtwork,
        songs[songIndex].filePath);
    Fav fav = new Fav();
    favState = await fav.getFavouritesByTitle(_currentSongTitle);
    _songsWidgets = [];
    _favSongsWidgets = [];
    for (SongInfo song in _songs) {
      if (await fav.getFavouritesByTitle(song.title)) {
        _favSongsWidgets.add(new Song(
          song: song,
          isFav: true,
        ));
        _songsWidgets.add(new Song(
          song: song,
          isFav: true,
        ));
      } else
        _songsWidgets.add(new Song(
          song: song,
          isFav: false,
        ));
    }
    notifyListeners();
  }

  Future<void> checkFav() async {
    Fav fav = Fav();
    bool state = await fav.getFavouritesByTitle(_currentSongTitle);
    favState = state;
    notifyListeners();
  }

  Future<void> playOrPause() async {
    try {
      if (_audioPlayer.state == AudioPlayerState.PLAYING)
        _audioPlayer.pause();
      else if (_audioPlayer.state == AudioPlayerState.PAUSED)
        _audioPlayer.resume();
      else {
        setPlayNow(songs[songIndex].title, songs[songIndex].albumArtwork,
            songs[songIndex].filePath);
        await _audioPlayer.play(_songs[_songIndex].filePath, isLocal: true);
      }
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> next() async {
    if (shuffle) {
      playRandom();
      return;
    }
    if (_songIndex == _songs.length - 1)
      _songIndex = 0;
    else
      _songIndex++;
    setPlayNow(songs[songIndex].title, songs[songIndex].albumArtwork,
        songs[songIndex].filePath);
    await _audioPlayer.play(_songs[_songIndex].filePath, isLocal: true);
    notifyListeners();
  }

  Future<void> previous() async {
    if (shuffle) {
      playRandom();
      return;
    }
    if (_songIndex == 0)
      _songIndex = _songs.length - 1;
    else
      _songIndex--;
    setPlayNow(songs[songIndex].title, songs[songIndex].albumArtwork,
        songs[songIndex].filePath);
    await _audioPlayer.play(_songs[_songIndex].filePath, isLocal: true);
    notifyListeners();
  }

  Future<void> playRandom() async {
    int rand = Random().nextInt(_songs.length);
    _songIndex = rand;
    setPlayNow(
        songs[rand].title, songs[rand].albumArtwork, songs[rand].filePath);
    await _audioPlayer.play(_songs[_songIndex].filePath, isLocal: true);
    notifyListeners();
  }

  playSong(SongInfo song) async {
    Fav fav = Fav();
    for (int i = 0; i < _songs.length; i++)
      if (song.title == _songs[i].title) _songIndex = i;
    setPlayNow(song.title, song.albumArtwork, song.filePath);
    favState = await fav.getFavouritesByTitle(song.title);
    await _audioPlayer.play(song.filePath, isLocal: true);
    notifyListeners();
  }

  toggleFav(String title, bool isFav) async {
    Fav fav = Fav();
    if (isFav) {
      await fav.deleteItem(title);
      favSongsWidgets.removeWhere((e) => e.song.title == title);
      songsWidgets
          .firstWhere((element) => element.song.title == title)
          .setFav(false);
      if (title == currentSongTitle) favState = false;
    } else {
      await fav.create(title);
      favSongsWidgets.add(Song(
        song: songs.firstWhere((element) => element.title == title),
        isFav: true,
      ));
      songsWidgets
          .firstWhere((element) => element.song.title == title)
          .setFav(true);
      if (title == currentSongTitle) favState = true;
    }
    notifyListeners();
  }

  String calculateSongTime(String string) {
    int time = int.parse(string);
    int hrs, mins, secs;
    hrs = time ~/ (1000 * 60 * 60);
    time %= (1000 * 60 * 60);
    mins = time ~/ (1000 * 60);
    time %= (1000 * 60);
    secs = time ~/ 1000;
    String seconds, minutes;
    if (mins < 10)
      minutes = '0' + mins.toString();
    else
      minutes = mins.toString();
    if (secs < 10)
      seconds = '0' + secs.toString();
    else
      seconds = secs.toString();
    return '0$hrs:$minutes:$seconds';
  }

  setPlayNow(String title, String pic, path) async {
    Fav fav = Fav();
    _currentSongPath = path;
    _currentSongPic = pic;
    _currentSongTitle = title;
    favState = await fav.getFavouritesByTitle(title);
  }
}
