import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:muzic/pages/favourites.dart';
import 'package:muzic/pages/playing_now.dart';
import 'package:muzic/pages/playlist.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:muzic/tools/injection.dart';
import 'package:muzic/ui_tools/loading.dart';
import 'models/favs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Injection.initInjection();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primaryColor: Colors.white,
          primaryTextTheme: TextTheme(title: TextStyle(color: Colors.black))),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  static AudioPlayer audioPlayer = AudioPlayer();
  static String currentSongTitle = "None";
  static String currentSongPath;
  static List<SongInfo> songs;
  static List<Fav> favs;
  static int songIndex = 0;
  static var playIconState = Icons.play_arrow;

  PlayingNow playingNow = PlayingNow();
  Favourites favourites = Favourites();
  PlayList playList = PlayList();
  final PageController _pageController = PageController();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int ind = 0;
  bool loading = true; 
  Future<void> getSongs() async {
    setState(() {
      loading = true ;
    });
    MyHomePage.songs = await FlutterAudioQuery().getSongs();
    setState(() {
      MyHomePage.currentSongTitle =
          MyHomePage.songs[MyHomePage.songIndex].title;
      MyHomePage.currentSongPath = MyHomePage.songs[0].filePath;
    });
        setState(() {
      loading = false ;
    });
  }

@override
  void initState() {
    super.initState();
        getSongs();
  }
  @override
  void dispose() {
    super.dispose();
    MyHomePage.audioPlayer.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return loading ? Loading():Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        animationDuration: Duration(milliseconds: 300),
        index: ind,
        backgroundColor: Colors.orange[700],
        items: <Widget>[
          Icon(
            Icons.music_note,
            color: Colors.orange[700],
          ),
          Icon(
            Icons.favorite,
            color: Colors.orange[700],
          ),
          Icon(
            Icons.list,
            color: Colors.orange[700],
          ),
        ],
        onTap: (index) {
          setState(() {
            ind = index;
            widget._pageController.jumpToPage(ind);
          });
        },
      ),
      body: PageView(
        onPageChanged: (index) {
          setState(() {
            ind = index;
          });
        },
        controller: widget._pageController,
        children: <Widget>[
          widget.playingNow,
          widget.favourites,
          widget.playList,
        ],
      ),
    );
  }
}
