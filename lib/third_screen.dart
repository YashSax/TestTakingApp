import 'package:flutter/material.dart';
import 'package:test_timer/Test.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class PlayTestScreen extends StatefulWidget {
  final Test testToPlay;
  const PlayTestScreen({Key? key, required this.testToPlay}) : super(key: key);

  @override
  _PlayTestScreenState createState() => _PlayTestScreenState();
}

class _PlayTestScreenState extends State<PlayTestScreen> with SingleTickerProviderStateMixin{
  AnimationController? _controller;
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(minutes: widget.testToPlay.totalMinutes));
    _controller?.forward();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.testToPlay.name)
      ),
      body: CountDownTimerPage(testToDisplay: widget.testToPlay),
    );
  }
  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}


class CountDownTimerPage extends StatefulWidget {
  final Test testToDisplay;
  const CountDownTimerPage({Key? key, required this.testToDisplay}) : super(key: key);
  @override
  _State createState() => _State();
}

class _State extends State<CountDownTimerPage> {
  final _isHours = true;
  int currQuestions = 0;
  bool timerIsCounting = false;

  // variables for saving after test
  int finalMillisecondsLeft = -1;
  String finalDisplayTime = "";
  int seconds = -1;
  int minutes = -1;
  int secondsLeft = -1;
  int minutesLeft = -1;
  int secondsLeftFiveMinutes = -1;
  int minutesLeftFiveMinutes = -1;
  String aheadOrBehind = "";
  int secondsSchedule = -1;
  int minutesSchedule = -1;

  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countDown,
    presetMillisecond: StopWatchTimer.getMilliSecFromSecond(0),
    onChange: (value) => {},
    onChangeRawSecond: (value) => {},
    onChangeRawMinute: (value) => {},
    onEnded: () {
      print('onEnded');
    },
  );

  @override
  void initState() {
    super.initState();
    _stopWatchTimer.setPresetTime(mSec: widget.testToDisplay.totalMinutes*60*1000);
  }

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            /// Display stop watch time
            Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: StreamBuilder<int>(
                stream: _stopWatchTimer.rawTime,
                initialData: _stopWatchTimer.rawTime.value,
                builder: (context, snap) {
                  final value = snap.data!;
                  final displayTime = StopWatchTimer.getDisplayTime(value, hours: _isHours);
                  return Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          currQuestions>=widget.testToDisplay.numQuestions?finalDisplayTime:displayTime,
                          style: const TextStyle(
                              fontSize: 40,
                              fontFamily: 'Helvetica',
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            StreamBuilder<int>(
                stream: _stopWatchTimer.rawTime,
                initialData: _stopWatchTimer.rawTime.value,
                builder: (context, snap) {
                  if(currQuestions < widget.testToDisplay.numQuestions) {
                    int millisecondsLeft = snap.data!;
                    print("millis left: " + millisecondsLeft.toString());
                    int millisecondsElapsed = widget.testToDisplay.totalMinutes*60*1000 - millisecondsLeft; // Current Average time per question
                    double millisecondsPerQuestion = millisecondsElapsed/(currQuestions+1);
                    seconds = (millisecondsPerQuestion/1000).remainder(60).round();
                    minutes = (((millisecondsPerQuestion/1000)-seconds)/60).round();

                     // Required time per question
                    int questionsLeft = widget.testToDisplay.numQuestions - currQuestions;
                    double millisecondsLeftPerQuestion = millisecondsLeft/questionsLeft;
                    secondsLeft = (millisecondsLeftPerQuestion/1000).remainder(60).round();
                    minutesLeft = ((millisecondsLeftPerQuestion/1000-secondsLeft)/60).round();

                    int millisecondsLeftFiveMinutes = millisecondsLeft - 5*60*1000; // Required time per question to end 5 minutes early
                    double millisecondsLeftPerQuestionFiveMinutes = millisecondsLeftFiveMinutes/questionsLeft;
                    secondsLeftFiveMinutes = (millisecondsLeftPerQuestionFiveMinutes/1000).remainder(60).round();
                    minutesLeftFiveMinutes = (((millisecondsLeftPerQuestionFiveMinutes/1000)-secondsLeftFiveMinutes)/60).round();

                    double staticMillisPerQuestion = widget.testToDisplay.totalMinutes*1000*60/widget.testToDisplay.numQuestions; // Ahead/Behind Schedule
                    double schedule = staticMillisPerQuestion*currQuestions - millisecondsElapsed;
                    aheadOrBehind = schedule>0?"Ahead of":"Behind";
                    schedule = schedule.abs();
                    secondsSchedule = (schedule/1000).remainder(60).round();
                    minutesSchedule = (((schedule/1000)-secondsSchedule)/60).round();
                    }

                  return Column(
                    children: [
                      Text("Your Average Time Per Question: ${minutes.toString().padLeft(2,"0")}:${seconds.toString().padLeft(2,"0")}"),
                      Text("Required Time Per Question: ${minutesLeft.toString().padLeft(2,"0")}:${secondsLeft.toString().padLeft(2,"0")}"),
                      if (widget.testToDisplay.totalMinutes>=5) Text("Required Time Per Question To Finish 5 Minutes Early: ${minutesLeftFiveMinutes.toString().padLeft(2,"0")}:${secondsLeftFiveMinutes.toString().padLeft(2,"0")}"),
                      Text("Question $currQuestions of ${widget.testToDisplay.numQuestions}"),
                      Text("$aheadOrBehind Schedule by: ${minutesSchedule.toString().padLeft(2,"0")}:${secondsSchedule.toString().padLeft(2,"0")}"),
                    ],
                  );
                }
            ),
            /// Button
            Padding(
              padding: const EdgeInsets.all(2),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.lightBlue,
                              onPrimary: Colors.white,
                              shape: const StadiumBorder(),
                            ),
                            onPressed: () async {
                              timerIsCounting = true;
                              _stopWatchTimer.onExecute
                                  .add(StopWatchExecute.start);
                            },
                            child: const Text(
                              'Start',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                              onPrimary: Colors.white,
                              shape: const StadiumBorder(),
                            ),
                            onPressed: () async {
                              timerIsCounting = false;
                              _stopWatchTimer.onExecute
                                  .add(StopWatchExecute.stop);
                            },
                            child: const Text(
                              'Pause',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red,
                              onPrimary: Colors.white,
                              shape: const StadiumBorder(),
                            ),
                            onPressed: () async {
                              timerIsCounting = false;
                              _stopWatchTimer.onExecute
                                  .add(StopWatchExecute.reset);
                              currQuestions = 0;
                            },
                            child: const Text(
                              'Reset',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: StreamBuilder<int>(
        stream: _stopWatchTimer.rawTime,
        initialData: _stopWatchTimer.rawTime.value,
        builder: (context, snap) {
          return FloatingActionButton(
              onPressed: () {
                setState(() {
                  if(timerIsCounting) {
                    currQuestions++;
                  }
                  if(currQuestions == widget.testToDisplay.numQuestions) {
                    if(finalDisplayTime == "") {
                      final value = snap.data!;
                      finalDisplayTime = StopWatchTimer.getDisplayTime(value, hours: _isHours);
                      finalMillisecondsLeft = value;
                    }
                    print("final millis:" + finalMillisecondsLeft.toString());
                    timerIsCounting = false;
                    print("done with questions");
                  }
                });
              },
              child: Icon(Icons.control_point_rounded)
          );
        }
      ),
    );
  }
}

