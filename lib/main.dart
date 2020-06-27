import 'package:flutter/material.dart';
import 'package:muzic/pages/favourites.dart';
import 'package:muzic/pages/playing_now.dart';
import 'package:muzic/pages/playlist.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:muzic/providers/mp_provider.dart';
import 'package:muzic/tools/injection.dart';
import 'package:provider/provider.dart';
import 'ui_tools/loading.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Injection.initInjection();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
          create: (context)=>MPProvider(),
          child: MaterialApp(
        theme: ThemeData(
            accentColor: Colors.orange[700],
            primaryColor: Colors.white,
            primaryTextTheme: TextTheme(headline6: TextStyle(color: Colors.black))),
        home:MyHomePage()
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final PageController _pageController = PageController();
  final PlayingNow playingNow = PlayingNow() ; 
  final Favourites favourites = Favourites() ; 
  final PlayList playList = PlayList(); 

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int ind = 0;
  bool loading = true; 
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await Provider.of<MPProvider>(context,listen:false).fetchSongs();
    setState(() {
      loading=false ;
    });
  }
  @override
  Widget build(BuildContext context) {
    return loading ? Loading() :Scaffold(
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
          Favourites(),
          PlayList(),
        ],
      ),
    );
  }
}
