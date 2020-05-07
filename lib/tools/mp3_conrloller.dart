import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:muzic/pages/playing_now.dart';

import '../main.dart';

class MP3Controller {
  static Future<void> playOrPause() async {
    try {
      if (MyHomePage.audioPlayer.state == AudioPlayerState.PLAYING)
        MyHomePage.audioPlayer.pause();
      else if (MyHomePage.audioPlayer.state == AudioPlayerState.PAUSED)
        MyHomePage.audioPlayer.resume();
      else {
        MyHomePage.currentSongTitle =
            MyHomePage.songs[MyHomePage.songIndex].title;
        await MyHomePage.audioPlayer.play(
            MyHomePage.songs[MyHomePage.songIndex].filePath,
            isLocal: true);
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<void> next() async {
    try {
      if (PlayingNow.shuffle) {
        playRandom();
        return;
      }
      if (MyHomePage.songIndex == MyHomePage.songs.length - 1)
        MyHomePage.songIndex = 0;
      else
        MyHomePage.songIndex++;
      MyHomePage.currentSongTitle =
          MyHomePage.songs[MyHomePage.songIndex].title;
      await MyHomePage.audioPlayer
          .play(MyHomePage.songs[MyHomePage.songIndex].filePath, isLocal: true);
    } catch (e) {
      print(e);
    }
  }

  static Future<void> previous() async {
    try {
      if (PlayingNow.shuffle) {
        playRandom();
        return;
      }
      if (MyHomePage.songIndex == 0)
        MyHomePage.songIndex = MyHomePage.songs.length - 1;
      else
        MyHomePage.songIndex--;
      MyHomePage.currentSongTitle =
          MyHomePage.songs[MyHomePage.songIndex].title;
      await MyHomePage.audioPlayer
          .play(MyHomePage.songs[MyHomePage.songIndex].filePath, isLocal: true);
    } catch (e) {
      print(e);
    }
  }

  static Future<void> playRandom() async {
    try {
      int rand = Random().nextInt(MyHomePage.songs.length);
      MyHomePage.songIndex = rand;
      MyHomePage.currentSongTitle = MyHomePage.songs[rand].title;
      await MyHomePage.audioPlayer
          .play(MyHomePage.songs[MyHomePage.songIndex].filePath, isLocal: true);
    } catch (e) {
      print(e);
    }
  }

  static String calculateSongTime(String string) {
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
}
