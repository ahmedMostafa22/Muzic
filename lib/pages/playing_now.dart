import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:muzic/models/favs.dart';
import 'package:muzic/tools/mp3_conrloller.dart';
import 'package:muzic/ui_tools/circle_btn.dart';
import '../main.dart';

class PlayingNow extends StatefulWidget {
  static bool favState = false;
  static bool shuffle = false;
  static bool repeat = false;
  static String songCurrTime = "";
  @override
  _PlayingNowState createState() => _PlayingNowState();
}

class _PlayingNowState extends State<PlayingNow>
    with AutomaticKeepAliveClientMixin {
  double sliderVal = 0;
  bool buttonsEnabled = true;
  var icon = Icons.play_arrow;
  Fav fav = Fav();
  @override
  void initState() {
    super.initState();
    MyHomePage.audioPlayer.onAudioPositionChanged.listen((d) {
      sliderVal = double.parse(d.inMilliseconds.toString());
      setState(() {
        PlayingNow.songCurrTime =
            MP3Controller.calculateSongTime(d.inMilliseconds.toString());
      });
    });

    MyHomePage.audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == AudioPlayerState.COMPLETED) {
                  setState(() {
            MyHomePage.playIconState = Icons.play_arrow;
          });
        if (PlayingNow.shuffle) {
          setState(() {
            MP3Controller.playRandom();
          });
        } else if (PlayingNow.repeat &&
            MyHomePage.songIndex == MyHomePage.songs.length - 1) {
          setState(() {
            MP3Controller.next();
          });
        }else if (!PlayingNow.repeat){}
         else
          setState(() {
            MP3Controller.next();
          });
      } else if (state == AudioPlayerState.PAUSED ||
          state == AudioPlayerState.STOPPED) {
          setState(() {
            MyHomePage.playIconState = Icons.play_arrow;
          });
      } else 
        setState(() {
          MyHomePage.playIconState = Icons.pause;
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 40.0),
      child: Column(
        children: <Widget>[
          CircleAvatar(
            backgroundImage: AssetImage('images/song_icon.jpg'),
            radius: 80.0,
          ),
          SizedBox(
            height: 25.0,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              PNIcon(
                icon: Icons.shuffle,
              ),
              PlayFav(),
              PNIcon(icon: Icons.repeat)
            ],
          ),
          SizedBox(
            height: 25.0,
          ),
          Text(
            MyHomePage.currentSongTitle,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Expanded(child: SizedBox()),
          Slider(
            max: MyHomePage.songs == null
                ? 0
                : double.parse(MyHomePage.songs[MyHomePage.songIndex].duration),
            min: 0,
            value: sliderVal,
            activeColor: Colors.orange[700],
            onChanged: (newVal) {
              setState(() {
                MyHomePage.audioPlayer
                    .seek(Duration(milliseconds: newVal.round()));
                sliderVal = newVal;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  PlayingNow.songCurrTime == ""
                      ? '00:00'
                      : PlayingNow.songCurrTime,
                  style: TextStyle(color: Colors.black),
                ),
                Text(
                    MP3Controller.calculateSongTime(
                        MyHomePage.songs[MyHomePage.songIndex].duration),
                    style: TextStyle(color: Colors.black))
              ],
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RoundIconButton(
                icon: Icons.skip_previous,
                onPressed: () {
                  if (buttonsEnabled)
                    setState(() {
                      MP3Controller.previous();
                    });
                },
              ),
              RoundIconButton(
                icon: MyHomePage.playIconState,
                onPressed: () {
                  if (buttonsEnabled)
                    setState(() {
                      MP3Controller.playOrPause();
                    });
                },
              ),
              RoundIconButton(
                icon: Icons.skip_next,
                onPressed: () {
                  if (buttonsEnabled)
                    setState(() {
                      MP3Controller.next();
                    });
                },
              )
            ],
          ),
          SizedBox(
            height: 35.0,
          ),
        ],
      ),
    );
  }
  @override
  bool get wantKeepAlive => true;
}

class PNIcon extends StatefulWidget {
  var icon;

  PNIcon({this.icon});
  @override
  _PNIconState createState() => _PNIconState();
}

class _PNIconState extends State<PNIcon> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (widget.icon == Icons.shuffle)
            PlayingNow.shuffle = !PlayingNow.shuffle;
          else
            PlayingNow.repeat = !PlayingNow.repeat;
        });
      },
      child: Icon(
        widget.icon,
        color: PlayingNow.repeat == true && widget.icon == Icons.repeat ||
                PlayingNow.shuffle == true && widget.icon == Icons.shuffle
            ? Colors.orange[700]
            : Colors.black,
        size: 30,
      ),
    );
  }
}

class PlayFav extends StatefulWidget {
  @override
  _PlayFavState createState() => _PlayFavState();
}

class _PlayFavState extends State<PlayFav> {
  @override
  void initState() {
    super.initState();
        MyHomePage.audioPlayer.onPlayerStateChanged.listen((state) {
          setState(() {
            checkFav() ; 
          });
        });

    checkFav();
  }

  Future<void> checkFav() async {
    Fav fav= Fav();
    bool state = await fav.getFavouritesByTitle(MyHomePage.currentSongTitle);
    setState(() {
      PlayingNow.favState = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () async {
          Fav fav = Fav();
          if (PlayingNow.favState) {
            print(await fav.deleteItem(MyHomePage.currentSongTitle));
          } else {
            print(await fav.create(MyHomePage.currentSongTitle));
          }
          setState(() {
            PlayingNow.favState = !PlayingNow.favState;
          });
        },
        child: Icon(
            PlayingNow.favState ? Icons.favorite : Icons.favorite_border,
            color: PlayingNow.favState ? Colors.yellow[900] : Colors.black));
  }
}
