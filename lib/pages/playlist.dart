import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:muzic/providers/mp_provider.dart';
import 'package:provider/provider.dart';

class PlayList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MPProvider mpProvider = Provider.of<MPProvider>(context, listen: false);
    return Scaffold(
        appBar: AppBar(title: Text('All Songs')),
        body: ListView.builder(
            itemCount: mpProvider.songsWidgets.length,
            itemBuilder: (BuildContext context, int i) {
              return mpProvider.songsWidgets[i];
            }));
  }
}
