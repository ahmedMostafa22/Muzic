import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:muzic/models/favs.dart';
import 'package:muzic/ui_tools/loading.dart';
import 'package:muzic/ui_tools/song_item.dart';
import '../main.dart';

class Favourites extends StatefulWidget {
  @override
  _FavouritesState createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
  Fav fav = Fav();
  List<Song> songsWidgets = [];
  bool loading = true ; 

  @override
  void initState() {
    super.initState();
    setup();
  }

  setup() async {
    for(SongInfo song in MyHomePage.songs) {
      if (await fav.getFavouritesByTitle(song.title))
      songsWidgets.add(new Song(
        song: song,
        isFav: true,
      ));
    }
    setState(() {
      loading = false ; 
    });
  }
  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        :Scaffold(
        appBar: AppBar(
          title: Text('Favourites'),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: songsWidgets,
              ),
            )
          ],
        ));
  }
}
