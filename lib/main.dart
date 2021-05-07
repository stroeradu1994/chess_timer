import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'duration_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Timer whiteTimer = new Timer(Duration.zero, () {});
  late Timer blackTimer = new Timer(Duration.zero, () {});

  bool isWhiteOnTop = false;

  double whiteRotation = 0;
  double blackRotation = 0;

  int selectedWhiteTime = 10 * 60;
  int selectedBlackTime = 10 * 60;
  int whiteTime = 10 * 60;
  int blackTime = 10 * 60;

  bool showMenu = true;

  /*
  0 - Not Started
  1 - White turn
  2 - Black turn
  3 - Out of time
   */
  int status = 0;

  bool isPaused = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  startGame() {
    setState(() {
      status = 1;
    });
    startWhiteTimer();
  }

  resetTimes() {
    setState(() {
      whiteTime = selectedWhiteTime;
      blackTime = selectedBlackTime;
    });
  }

  whiteTurn() {
    setState(() {
      showMenu = false;
      status = 1;
    });
    stopBlackTimer();
    startWhiteTimer();
  }

  blackTurn() {
    setState(() {
      showMenu = false;
      status = 2;
    });
    stopWhiteTimer();
    startBlackTimer();
  }

  stopWhiteTimer() {
    setState(() {
      whiteTimer.cancel();
    });
  }

  stopBlackTimer() {
    setState(() {
      blackTimer.cancel();
    });
  }

  startWhiteTimer() {
    whiteTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (whiteTime > 0) {
          whiteTime--;
        } else {
          status = 3;
          whiteTimer.cancel();
          blackTimer.cancel();
        }
      });
    });
  }

  startBlackTimer() {
    blackTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (blackTime > 0) {
          blackTime--;
        } else {
          status = 3;
          whiteTimer.cancel();
          blackTimer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey,
        body: Stack(
          children: [
            Column(
              children: [
                _buildTopContainer(),
                _buildBottomContainer(),
              ],
            ),
            status == 0 ? _buildTopSlider() : SizedBox.shrink(),
            status == 0 ? _buildBottomSlider() : SizedBox.shrink(),
            status == 0 ? _buildControls() : SizedBox.shrink(),
            status == 3 ? _buildTimeout() : SizedBox.shrink(),
            status == 1 || status == 2
                ? (isPaused
                    ? _buildPausedControls()
                    : _buildPauseButtonControls())
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  _buildTopContainer() {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (isWhiteOnTop && status == 1 && !isPaused) {
            blackTurn();
          } else if (!isWhiteOnTop && status == 2 && !isPaused) {
            whiteTurn();
          }
        },
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Colors.grey,
            // isWhiteOnTop ? (status == 2 ? Colors.grey : Colors.white) : (status == 1 ? Colors.grey : Colors.black),
            isWhiteOnTop ? Colors.white : Colors.black,
            isWhiteOnTop ? Colors.white : Colors.black,
            isWhiteOnTop ? Colors.white : Colors.black
          ], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
          // color: isWhiteOnTop ? Colors.white : Colors.black,
          child: Center(
            child: RotatedBox(
              quarterTurns: 2,
              child: Transform.rotate(
                angle: (isWhiteOnTop ? whiteRotation : blackRotation) == 0.0
                    ? pi / 180
                    : (isWhiteOnTop ? whiteRotation : blackRotation) * pi / 180,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "",
                      style: TextStyle(
                          color: isWhiteOnTop ? Colors.white : Colors.black,
                          fontSize: 24),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      isWhiteOnTop
                          ? fromSecondsToString(whiteTime)
                          : fromSecondsToString(blackTime),
                      style: TextStyle(
                          color: isWhiteOnTop ? Colors.black : Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 80),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      isWhiteOnTop
                          ? fromSecondsToString(blackTime)
                          : fromSecondsToString(whiteTime),
                      style: TextStyle(
                          color: isWhiteOnTop ? Colors.black : Colors.white,
                          fontSize: 30),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _buildBottomContainer() {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (isWhiteOnTop && status == 2 && !isPaused) {
            whiteTurn();
          } else if (!isWhiteOnTop && status == 1 && !isPaused) {
            blackTurn();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.grey,
              // isWhiteOnTop ? (status == 1 ? Colors.grey : Colors.black) : (status == 2 ? Colors.grey : Colors.white),
              isWhiteOnTop ? Colors.black : Colors.white,
              isWhiteOnTop ? Colors.black : Colors.white,
              isWhiteOnTop ? Colors.black : Colors.white
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          ),
          child: Center(
              child: Transform.rotate(
                  angle: (isWhiteOnTop ? -blackRotation : -whiteRotation) == 0.0
                      ? pi / 180
                      : (isWhiteOnTop ? -blackRotation : -whiteRotation) *
                          pi /
                          180,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "",
                        style: TextStyle(
                            color: isWhiteOnTop ? Colors.white : Colors.black,
                            fontSize: 24),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        isWhiteOnTop
                            ? fromSecondsToString(blackTime)
                            : fromSecondsToString(whiteTime),
                        style: TextStyle(
                            color: isWhiteOnTop ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 90),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        isWhiteOnTop
                            ? fromSecondsToString(whiteTime)
                            : fromSecondsToString(blackTime),
                        style: TextStyle(
                            color: isWhiteOnTop ? Colors.white : Colors.black,
                            fontSize: 24),
                      ),
                    ],
                  ))),
        ),
      ),
    );
  }

  _buildControls() {
    return Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            width: 16,
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                IconButton(
                  color: Color(0xff40e0d0),
                  icon: Icon(
                    Icons.info_outline,
                    size: 35,
                    color: Colors.white,
                  ),
                  onPressed: () {
                      showAboutDialog(context: context,
                      );
                  },
                ),
                IconButton(
                  color: Color(0xff40e0d0),
                  icon: Icon(
                    Icons.timer,
                    size: 35,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      // Create the SelectionScreen in the next step.
                      MaterialPageRoute(
                          builder: (context) =>
                              DurationScreen(selectedWhiteTime, selectedBlackTime)),
                    );

                    if (result != null && result[0] != null && result[0] != null) {
                      setState(() {
                        selectedWhiteTime = result[0];
                        whiteTime = result[0];
                        selectedBlackTime = result[1];
                        blackTime = result[1];
                      });
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setInt('whiteTime', whiteTime);
                      prefs.setInt('blackTime', blackTime);
                    }
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            width: 16,
          ),
          Expanded(
              flex: 3,
              child: TextButton(
                onPressed: () {
                  whiteTurn();
                },
                child: Text('START',
                    style: TextStyle(
                        letterSpacing: 4,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 28)),
                style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        EdgeInsets.symmetric(vertical: 8)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ))),
              )),
          SizedBox(
            width: 32,
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              color: Color(0xff40e0d0),
              icon: RotatedBox(
                  quarterTurns: 1,
                  child: Icon(
                    Icons.compare_arrows,
                    size: 35,
                    color: Colors.white,
                  )),
              onPressed: () {
                setState(() async {
                  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                      statusBarColor:
                          isWhiteOnTop ? Colors.white : Colors.black,
                      systemNavigationBarColor:
                          isWhiteOnTop ? Colors.black : Colors.white));
                  isWhiteOnTop = !isWhiteOnTop;
                  (await SharedPreferences.getInstance())
                      .setBool('isWhiteOnTop', isWhiteOnTop);
                });
              },
            ),
          ),
          SizedBox(
            width: 16,
          ),
        ],
      ),
    );
  }

  _buildTopSlider() {
    return Positioned(
        top: 0,
        right: 0,
        left: 0,
        child: Slider(
          onChanged: (double value) async {
            setState(() {
              isWhiteOnTop ? whiteRotation = value : blackRotation = value;
            });
            isWhiteOnTop
                ? (await SharedPreferences.getInstance())
                    .setDouble('whiteRotation', whiteRotation)
                : (await SharedPreferences.getInstance())
                    .setDouble('blackRotation', blackRotation);
          },
          value: isWhiteOnTop ? whiteRotation : blackRotation,
          max: 90,
          min: -90,
          divisions: 12,
          activeColor: isWhiteOnTop ? Colors.black : Colors.white,
          inactiveColor: isWhiteOnTop ? Colors.black : Colors.white,
        ));
  }

  _buildBottomSlider() {
    return Positioned(
        bottom: 0,
        right: 0,
        left: 0,
        child: Slider(
          onChanged: (double value) async {
            setState(() {
              isWhiteOnTop ? blackRotation = value : whiteRotation = value;
            });
            isWhiteOnTop
                ? (await SharedPreferences.getInstance())
                    .setDouble('blackRotation', blackRotation)
                : (await SharedPreferences.getInstance())
                    .setDouble('whiteRotation', whiteRotation);
          },
          value: isWhiteOnTop ? blackRotation : whiteRotation,
          max: 90,
          min: -90,
          divisions: 16,
          activeColor: isWhiteOnTop ? Colors.white : Colors.black,
          inactiveColor: isWhiteOnTop ? Colors.white : Colors.black,
        ));
  }

  _buildPauseButtonControls() {
    bool showOnLeft = blackRotation > 0 && whiteRotation > 0;

    print(showOnLeft);
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          showOnLeft ? _buildPauseButton() : SizedBox.shrink(),
          !showOnLeft ? _buildPauseButton() : SizedBox.shrink(),
        ],
      ),
    );
  }

  _buildPausedControls() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox.shrink(),
          showMenu
              ? IconButton(
                  color: Color(0xff40e0d0),
                  icon: Icon(
                    Icons.play_arrow,
                    size: 35,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    stopBlackTimer();
                    stopWhiteTimer();
                    setState(() {
                      isPaused = false;
                      showMenu = false;
                      if (status == 1) {
                        startWhiteTimer();
                      } else if (status == 2) {
                        startBlackTimer();
                      }
                    });
                  },
                )
              : SizedBox.shrink(),
          showMenu
              ? IconButton(
                  color: Color(0xff40e0d0),
                  icon: Icon(
                    Icons.stop,
                    size: 35,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      status = 0;
                      isPaused = false;
                    });
                    stopBlackTimer();
                    stopWhiteTimer();
                    resetTimes();
                  },
                )
              : SizedBox.shrink(),
          SizedBox.shrink(),
        ],
      ),
    );
  }

  _buildPauseButton() {
    return IconButton(
        icon: Icon(
          Icons.pause,
          color: Colors.white,
          size: 35,
        ),
        splashColor: Colors.red,
        onPressed: () {
          setState(() {
            if (showMenu) {
              isPaused = false;
              showMenu = false;
              if (status == 1) {
                startWhiteTimer();
              } else if (status == 2) {
                startBlackTimer();
              }
            } else {
              stopWhiteTimer();
              stopBlackTimer();
              isPaused = true;
              showMenu = true;
            }
          });
        });
  }

  _buildTimeout() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            color: Color(0xff40e0d0),
            icon: Icon(
              Icons.refresh,
              size: 35,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                status = 0;
              });
              stopBlackTimer();
              stopWhiteTimer();
              resetTimes();
            },
          )
        ],
      ),
    );
  }

  _whiteChoiceChip(int seconds, setStateDialog) {
    return ChoiceChip(
      label: Text(fromSecondsToString(seconds),
          style: TextStyle(
              color: whiteTime == seconds ? Colors.white : Colors.black)),
      selected: whiteTime == seconds,
      selectedColor: Colors.black,
      onSelected: (value) {
        setState(() {
          whiteTime = seconds;
          selectedWhiteTime = seconds;
        });
        setStateDialog(() {
          whiteTime = seconds;
        });
      },
    );
  }

  _blackChoiceChip(int seconds, setStateDialog) {
    return ChoiceChip(
      label: Text(
        fromSecondsToString(seconds),
        style: TextStyle(
            color: blackTime == seconds ? Colors.white : Colors.black),
      ),
      selected: blackTime == seconds,
      selectedColor: Colors.black,
      onSelected: (value) {
        setState(() {
          blackTime = seconds;
          selectedBlackTime = seconds;
        });
        setStateDialog(() {
          blackTime = seconds;
        });
      },
    );
  }

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isWhiteOnTop = (prefs.getBool('isWhiteOnTop') ?? false);
      whiteRotation = (prefs.getDouble('whiteRotation') ?? 0);
      blackRotation = (prefs.getDouble('blackRotation') ?? 0);
      whiteTime = (prefs.getInt('whiteTime') ?? 10 * 60);
      blackTime = (prefs.getInt('blackTime') ?? 10 * 60);

      selectedWhiteTime = whiteTime;
      selectedBlackTime = blackTime;
    });
  }

  fromSecondsToString(int seconds) {
    int minutes = Duration(seconds: seconds).inMinutes;
    return minutes.toString().padLeft(2, "0") +
        ':' +
        Duration(seconds: (seconds - minutes * 60))
            .inSeconds
            .toString()
            .padLeft(2, "0");
  }
}
