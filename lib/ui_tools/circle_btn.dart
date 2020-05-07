import 'package:flutter/material.dart';

class RoundIconButton extends StatefulWidget {
     RoundIconButton({this.icon, this.onPressed});
    var icon;
  final Function onPressed;
  @override
  _RoundIconButtonState createState() => _RoundIconButtonState();
}

class _RoundIconButtonState extends State<RoundIconButton> {
  @override
  Widget build(BuildContext context) {
    return  RawMaterialButton(
      elevation: 100.0,
      child: Icon(widget.icon, color: Colors.white,),
      onPressed: (){
        setState(() {
          if (widget.icon==Icons.pause)
          widget.icon = Icons.play_arrow ;
          else if (widget.icon==Icons.play_arrow) 
                    widget.icon = Icons.pause ;
                    widget.onPressed();
                  
        });
      },
      constraints: BoxConstraints.tightFor(width: 56.0, height: 56.0),
      shape: CircleBorder(),
      fillColor: Colors.orange[700],
    );
  }
}
