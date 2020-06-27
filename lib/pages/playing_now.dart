import 'dart:io';
import 'package:flutter/material.dart';
import 'package:muzic/providers/mp_provider.dart';
import 'package:muzic/ui_tools/circle_btn.dart';
import 'package:provider/provider.dart';

class PlayingNow extends StatefulWidget {
  @override
  _PlayingNowState createState() => _PlayingNowState();
}

class _PlayingNowState extends State<PlayingNow> {
  bool buttonsEnabled = true;
  @override
  Widget build(BuildContext context) {
    MPProvider mpProvider = Provider.of<MPProvider>(context);
    return Padding(
        padding: EdgeInsets.fromLTRB(5,40,5,0),
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                CircleAvatar(
                  backgroundImage: mpProvider.currentSongPic == null
                      ? AssetImage('images/song_icon.jpg')
                      : FileImage(File(mpProvider.currentSongPic)),
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
                  mpProvider.currentSongTitle,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                  ),
                ),
                SizedBox(height: 20),
                Slider(
                  max: mpProvider.songs == null
                      ? 0
                      : double.parse(
                          mpProvider.songs[mpProvider.songIndex].duration),
                  min: 0,
                  value: mpProvider.sliderVal,
                  activeColor: Colors.orange[700],
                  onChanged: (newVal) {
                    setState(() {
                      mpProvider.audioPlayer
                          .seek(Duration(milliseconds: newVal.round()));
                      mpProvider.sliderVal = newVal;
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        mpProvider.songCurrTime == ""
                            ? '00:00:00'
                            : mpProvider.songCurrTime,
                        style: TextStyle(color: Colors.black),
                      ),
                      Text(
                          mpProvider.calculateSongTime(
                              mpProvider.songs[mpProvider.songIndex].duration),
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
                            mpProvider.previous();
                          });
                      },
                    ),
                    RoundIconButton(
                      icon: mpProvider.playIconState,
                      onPressed: () {
                        if (buttonsEnabled)
                          setState(() {
                            mpProvider.playOrPause();
                          });
                      },
                    ),
                    RoundIconButton(
                      icon: Icons.skip_next,
                      onPressed: () {
                        if (buttonsEnabled)
                          setState(() {
                            mpProvider.next();
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
          ),
        ));
  }
}

class PNIcon extends StatefulWidget {
  IconData icon;

  PNIcon({this.icon});
  @override
  _PNIconState createState() => _PNIconState();
}

class _PNIconState extends State<PNIcon> {
  @override
  Widget build(BuildContext context) {
    MPProvider mpProvider = Provider.of<MPProvider>(context);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (widget.icon == Icons.shuffle){
            mpProvider.shuffle = !mpProvider.shuffle;
            print('a8aa');
            }
          else
            mpProvider.repeat = !mpProvider.repeat;
        });
      },
      child: Icon(
        widget.icon,
        color: mpProvider.repeat == true && widget.icon == Icons.repeat ||
                mpProvider.shuffle == true && widget.icon == Icons.shuffle
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
  Widget build(BuildContext context) {
    MPProvider mpProvider = Provider.of<MPProvider>(context, listen: false);
    return GestureDetector(
        onTap: () async {
          mpProvider.toggleFav(mpProvider.currentSongTitle,mpProvider.favState);
        },
        child: Icon(
            mpProvider.favState ? Icons.favorite : Icons.favorite_border,
            color: mpProvider.favState ? Colors.yellow[900] : Colors.black));
  }

  @override
  void dispose() {
    super.dispose();
    Provider.of<MPProvider>(context, listen: false).audioPlayer.dispose();
  }
}
