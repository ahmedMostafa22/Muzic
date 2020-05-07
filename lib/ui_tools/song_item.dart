import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:muzic/main.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:muzic/models/favs.dart';

class Song extends StatefulWidget {
  final SongInfo song;
  bool isFav ; 

  Song({this.song, this.isFav});
  @override
  _SongState createState() => _SongState();
}

class _SongState extends State<Song> {
  bool playing = false;
  @override
  void initState() {
    super.initState();
    MyHomePage.audioPlayer.onPlayerStateChanged.listen((state) {
      if (MyHomePage.currentSongTitle != widget.song.title ||
          state == AudioPlayerState.STOPPED ||
          state == AudioPlayerState.PAUSED ||
          state == AudioPlayerState.COMPLETED) {
        if (mounted)
          setState(() {
            playing = false;
          });
      } else if (state == AudioPlayerState.PLAYING &&
          MyHomePage.currentSongTitle == widget.song.title) if (mounted)
        setState(() {
          playing = true;
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controlMP3,
      child: ListTile(
        leading: Container(
            margin: EdgeInsets.symmetric(vertical: 6.0),
            decoration: BoxDecoration(
                color: Colors.orange[700],
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                    bottomLeft: Radius.circular(15))),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(30.0)),
              child: Image(
                image: AssetImage('images/song_icon.jpg'),
              ),
            )),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(
                widget.song.title,
                maxLines: 2,
              ),
            ),
            Visibility(
              visible: playing,
              child: SpinKitWave(
                color: Colors.orange[900],
                size: 15.0,
                duration: const Duration(seconds: 2),
              ),
            )
          ],
        ),
        trailing: FavState(
            isFav: widget.isFav,
            fav: Fav(id: int.parse(widget.song.id), title: widget.song.title)),
      ),
    );
  }

  Future<void> controlMP3() async {
    setState(() async {
      if (MyHomePage.currentSongTitle == widget.song.title) {
        if (MyHomePage.audioPlayer.state == AudioPlayerState.PLAYING) {
          MyHomePage.audioPlayer.pause();
          return;
        } else if (MyHomePage.audioPlayer.state == AudioPlayerState.PAUSED) {
          MyHomePage.audioPlayer.resume();
          return;
        }
      }
      MyHomePage.songIndex = getSongIndex(widget.song.title);
      setState(() {
        MyHomePage.currentSongTitle = widget.song.title;
        MyHomePage.currentSongPath = widget.song.filePath;
      });
      await MyHomePage.audioPlayer.release();
      await MyHomePage.audioPlayer.play(widget.song.filePath, isLocal: true);
    });
  }

  int getSongIndex(String title) {
    for (int i = 0; i < MyHomePage.songs.length; i++)
      if (title == MyHomePage.songs[i].title) {
        return i;
      }
  }
}

class FavState extends StatefulWidget {
  bool isFav;
  final Fav fav;

  FavState({this.isFav, this.fav});
  @override
  _FavStateState createState() => _FavStateState(isFav);
}

class _FavStateState extends State<FavState> {
  bool isFav;
  _FavStateState(this.isFav);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () async {
          Fav fav = Fav();
          if (isFav) {
            print(await fav.deleteItem(widget.fav.title));
          } else {
            print(await fav.create(widget.fav.title));
          }
          setState(() {
            isFav = !isFav;
          });
        },
        child: Icon(isFav ? Icons.favorite : Icons.favorite_border,
            color: isFav ? Colors.yellow[900] : Colors.black));
  }
}
