import 'package:flutter/material.dart';
import 'package:piano_v15_05_22/note.dart';
import 'package:piano_v15_05_22/tile.dart';

// Line should be rebuilt on every animation change. To easily achieve that,
// we can change Line’s superclass from StatelessWidget to AnimatedWidget,
// which ensures that on every animation tick, the widget will be drawn again.

class Line extends AnimatedWidget { //use animation widget
  final int lineNumber;
  final List<Note> currentNotes;
  final Function(Note) onTileTap;

  const Line({
    Key? key,
    required this.currentNotes,
    required this.lineNumber,
    required this.onTileTap,
    required Animation<double> animation //add animation to constructor
  }) : super(key: key, listenable: animation); //and pass it to super constructor

  @override
  Widget build(BuildContext context) {

    // BUG FIXED BY KUSHAGRA TOMAR;THIS CODE MAKES ANIMATION WORK SMOOTHLY
    // ********************************************* //
    final animation = listenable as Animation<double>; //get the animation
    // ********************************************* //
    //to retrieve the device screen size
    double height = MediaQuery.of(context).size.height;
    double tileHeight = height / 4; //to set tile height

    //now we need to get tiles only for that lineNumber
    //first we will make a list of notes
    List<Note> thisLineNotes =
    currentNotes.where((note) => note.line == lineNumber).toList();

    //now we need to create a map to position those tiles on different lines
    List<Widget> tiles = thisLineNotes.map((note){
      //specify note distance from top
      int index = currentNotes.indexOf(note);
      //add animation.value to offset
      double offset = (3 - index + animation.value) * tileHeight;

      return Transform.translate(
        offset: Offset(0, offset),
        child: Tile(
          height: tileHeight,
          state: note.state,
          onTap: () => onTileTap(note),//<-- pass tap callback
        ),
      );
    }).toList();

    return SizedBox.expand(
      child: Stack(
        children: tiles,
      ),
    );
  }
}

