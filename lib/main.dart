import 'package:flutter/material.dart';
import 'package:piano_v15_05_22/note.dart';
import 'package:piano_v15_05_22/line.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:piano_v15_05_22/line_divider.dart';
import 'package:piano_v15_05_22/song_provider.dart';


void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //we are using MaterialApp instead of scaffold
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // title: 'Piano Tiles',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();

}

//we use AnimationController and add a listener to it, so that
//on every completed animation, currentNoteIndex will increase.
class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {

  AudioCache player = AudioCache(); //<-- use AudioCache
  List<Note> notes = initNotes();
  late AnimationController animationController;
  int currentNodeIndex = 0;
  int points = 0; //<-- add points field
  bool hasStarted = false;
  bool isPlaying = true;
  bool isShowing = false;

  // ** Needed for cmd if (notes[currentNoteIndex].state != NoteState.tapped) **
  // ** line number: 60 **
  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && isPlaying) {
        if (notes[currentNodeIndex].state != NoteState.tapped) {
          // game over
          setState(() {
            isPlaying = false;
            notes[currentNodeIndex].state = NoteState.missed;
          });
          animationController.reverse().then((_) => _showFinishDialog());
        }
        //animation gets completed
        // for Line to display moving Tiles it has
        // to have access to 5 of them instead of 4
        else if (currentNodeIndex == notes.length - 5) {
          //song finished
          _showFinishDialog();
        } else {
          //song not finished
          setState(() => ++currentNodeIndex);
          animationController.forward(from: 0); //start over the animation
        }
      }
    });
    //First tap will cause animationController to start
    //animationController.forward(); //start the animation for the first
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose(); //remember to dispose the controller
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                stops: [0.1, 0.5, 0.7, 0.9],
                colors: [
                  Color(0xFFCC33CC),
                  Color(0xFFA35CD6),
                  Color(0xFF7A85E0),
                  Color(0xFF52ADEB),
                ],
              ),
            ),
          ),
          Row(
            children: <Widget>[
              _drawLine(0),
              const LineDivider(),
              _drawLine(1),
              const LineDivider(),
              _drawLine(2),
              const LineDivider(),
              _drawLine(3),
            ],
          ),
          _drawPoints(), //<-- add points widget on top of stack
        ],
      ),
    );
  }

  void _restart() {
    setState(() {
      hasStarted = false;
      isPlaying = true;
      notes = initNotes();
      points = 0;
      currentNodeIndex = 0;
    });
    animationController.reset();
  }

  void _showFinishDialog() {
    _playOver();
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius. circular(50),
            ),
            backgroundColor: Colors.black,
            title: const Center(
              child: Text(
                  "GAME\nOVER",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.normal,
                ),
              )
            ),
            actions: <Widget>[
            TextButton(
              onPressed: () => {
                _restart(),
                Navigator.of(context).pop(),
              },
              child: const Center(
                child: Text(
                    "RESTART",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ),
            ),
           ],
          );
         },
      );
  }

  void _onTap(Note note) {
    //**IMPORTANT** TAP TO START THE ANIMATION
    bool areAllPreviousTapped = notes
        .sublist(0, note.orderNumber)
        .every((n) => n.state == NoteState.tapped);

    if (areAllPreviousTapped) {
      if (!hasStarted) {
        //<-- If game has not started
        setState(() => hasStarted = true); //<-- Set flag var to true
        animationController.forward(); //<-- And start the animation
      }
    }
    _playNote(note); //<-- play note on tap
    setState(() {
      note.state = NoteState.tapped; //<--set note state to tapped
      ++points; //<-- increase points on each successful tap
    });
  }

  _playNote(Note note) {
    switch (note.line) {
      // choose a sound depending on the note's line
      case 0:
        player.play('a.wav');
        return;
      case 1:
        player.play('c.wav');
        return;
      case 2:
        player.play('e.wav');
        return;
      case 3:
        player.play('f.wav');
        return;
    }
  }
  _playOver() {
    player.play('game-over.wav');
  }

  _drawPoints() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 64.0),
        child: Text(
          "$points",
          style: const TextStyle(
            fontSize: 64.0,
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
          ),
        )
      ),
    );
  }

  _drawLine(int lineNumber) {
    return Expanded(
      child: Line(
        lineNumber: lineNumber,
        currentNotes: notes.sublist(currentNodeIndex, currentNodeIndex + 5),
        onTileTap: _onTap, //<--specify onTap callback
        animation: animationController, //pass the animation
      ),
    );
  }
}
