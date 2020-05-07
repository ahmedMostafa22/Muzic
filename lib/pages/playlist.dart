import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:muzic/models/favs.dart';
import 'package:muzic/ui_tools/loading.dart';
import 'package:muzic/ui_tools/song_item.dart';

import '../main.dart';

class PlayList extends StatefulWidget {
  @override
  _PlayListState createState() => _PlayListState();
}

class _PlayListState extends State<PlayList>
    with AutomaticKeepAliveClientMixin {
  List<Song> songsWidgets = [];
  String searchVal = "";
  bool searchVisability = false;
  Fav fav = Fav();
  bool loading = true;
  @override
  void initState() {
    super.initState();
    refreshListView();
  }

  Future<void> refreshListView() async {
    setState(() {
      loading = true;
    });
    for (SongInfo song in MyHomePage.songs) {
      if (searchVal == "" || song.title.contains(searchVal)) {
        bool isFav = await fav.getFavouritesByTitle(song.title);
        songsWidgets.add(new Song(
          song: song,
          isFav: isFav,
        ));
      }
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Songs'),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              setState(() {
                searchVisability = !searchVisability;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                Icons.search,
                color: Colors.black,
                size: 30,
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Visibility(
                visible: searchVisability,
                child: TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.orange[900], width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.orange[900], width: 2.0),
                    ),
                  ),
                  cursorColor: Colors.orange[900],
                  onChanged: ((newVal) {
                    setState(() {
                      if (newVal == "") searchVisability = false;
                      searchVal = newVal;
                    });
                  }),
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Visibility(
                visible: searchVisability,
                child: RaisedButton(
                    color: Colors.orange[700],
                    onPressed: (() {
                      setState(() {
                            songsWidgets.clear();
                        refreshListView();
                      });
                    }),
                    child: Text(
                      'Search',
                      style: TextStyle(color: Colors.white),
                    )),
              ),
              SizedBox(
                height: 10.0,
              ),
              loading
                  ? Loading()
                  : Expanded(
                      child: ListView.builder(
                          itemCount: songsWidgets.length,
                          itemBuilder: (BuildContext context, int i) {
                            return songsWidgets[i];
                          }),
                    )
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
