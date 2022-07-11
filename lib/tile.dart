import 'package:flutter/material.dart';
import 'package:piano_v15_05_22/note.dart';

class Tile extends StatelessWidget {
  //To handle user taps on tiles. We are going to handle only taps on tiles
  //--not outside of them. To do that we are going to use GestureDetector.
  final double height;
  final NoteState state;
  final VoidCallback onTap;

  const Tile({Key? key, required this.height, required this.state, required this.onTap }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: GestureDetector(
        onTapDown: (_) => {
          onTap(),
        },
        child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: color,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  )
              ),
            ),
          ),
    );
  }
  Color get color {
    switch (state) {
      case NoteState.ready: return Colors.black;
      case NoteState.missed: return Colors.red;
      case NoteState.tapped: return Colors.transparent;
      default: return Colors.black;
    }
  }
}