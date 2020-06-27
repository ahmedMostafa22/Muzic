import 'package:flutter/material.dart';
import 'package:muzic/providers/mp_provider.dart';
import 'package:provider/provider.dart';

class Favourites extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MPProvider mpProvider = Provider.of<MPProvider>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
          title: Text('Favourites'),
        ),
        body: ListView(children: mpProvider.favSongsWidgets));
  }
}
