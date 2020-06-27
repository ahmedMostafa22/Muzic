import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:muzic/providers/mp_provider.dart';
import 'package:provider/provider.dart';

class Song extends StatefulWidget {
  final SongInfo song;
  bool isFav;
  setFav(bool fav){
    isFav = fav ; 
  }
  Song({this.song, this.isFav});
  @override
  _SongState createState() => _SongState();
}

class _SongState extends State<Song> {
  @override
  Widget build(BuildContext context) {
    MPProvider mpProvider = Provider.of<MPProvider>(context, listen: false);
    Future<void> controlMP3() async {
      if (mpProvider.currentSongTitle == widget.song.title) {
        if (mpProvider.audioPlayer.state == AudioPlayerState.PLAYING) {
          mpProvider.audioPlayer.pause();
          return;
        } else if (mpProvider.audioPlayer.state == AudioPlayerState.PAUSED) {
          mpProvider.audioPlayer.resume();
          return;
        }
      }
      else mpProvider.playSong(widget.song) ; 
    }

    return GestureDetector(
      onTap: controlMP3,
      child: ListTile(
        leading: Container(
            margin: EdgeInsets.symmetric(vertical: 6.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                    bottomLeft: Radius.circular(15))),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(30.0)),
              child: Image(
                image: widget.song.albumArtwork == null
                    ? AssetImage('images/song_icon.jpg')
                    : FileImage(File(widget.song.albumArtwork)),
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
            )
          ],
        ),
        trailing: FavState(
            isFav: widget.isFav,
             title: widget.song.title),
      ),
    );
  }
}

class FavState extends StatefulWidget {
  bool isFav;
  final String title;
  final int index ; 
  FavState({this.isFav, this.title, this.index});
  @override
  _FavStateState createState() => _FavStateState();
}

class _FavStateState extends State<FavState> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          MPProvider mpProvider =
              Provider.of<MPProvider>(context,listen: false);
              mpProvider.toggleFav(widget.title, widget.isFav);
          setState(() {
            widget.isFav = !widget.isFav;
          });
        },
        child: Icon(widget.isFav ? Icons.favorite : Icons.favorite_border,
            color: widget.isFav ? Colors.yellow[900] : Colors.black));
  }
}
