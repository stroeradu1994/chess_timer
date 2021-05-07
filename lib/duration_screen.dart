import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DurationScreen extends StatefulWidget {
  final int white;
  final int black;

  DurationScreen(this.white, this.black);

  @override
  _DurationScreenState createState() => _DurationScreenState();
}

class _DurationScreenState extends State<DurationScreen> {
  int white = 10 * 60;
  int black = 10 * 60;

  List<int> durations = [
    30,
    60,
    90,
    2 * 60,
    2 * 60 + 30,
    3 * 60,
    3 * 60 + 30,
    4 * 60,
    4 * 60 + 30,
    5 * 60,
    6 * 60,
    7 * 60,
    8 * 60,
    9 * 60,
    10 * 60,
    12 * 60,
    15 * 60,
    20 * 60,
    25 * 60,
    30 * 60,
  ];

  @override
  void initState() {
    super.initState();
    white = widget.white;
    black = widget.black;
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    // Widget addChip = ActionChip(
    //   onPressed: () {
    //     showTimePicker(context: context, initialTime: TimeOfDay(hour: 10, minute: 0));
    //   },
    //   label: Padding(
    //     padding: const EdgeInsets.symmetric(horizontal: 5.0),
    //     child: Text(
    //       'Add',
    //       style: TextStyle(color: Colors.black),
    //     ),
    //   ),
    //   backgroundColor: Colors.white,
    //   elevation: 2,
    // );

    List<Widget> whiteChips =
        durations.map((duration) => _whiteChoiceChip(duration)).toList();
    // whiteChips.add(addChip);

    List<Widget> blackChips =
        durations.map((duration) => _blackChoiceChip(duration)).toList();
    // blackChips.add(addChip);

    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            bottomOpacity: 0.0,
            elevation: 0.0,
            iconTheme: IconThemeData(
              color: Colors.black, //change your color here
            ),
            title: Text(
              'Game Duration',
              style: TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.w500),
            ),
            centerTitle: true,
          ),
            body: ListView(
      physics: BouncingScrollPhysics(),
      children: [
        SizedBox(
          height: 16,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'White Duration',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 8,
              ),
              Wrap(
                  alignment: WrapAlignment.spaceAround,
                  spacing: 8,
                  children: whiteChips),
            ],
          ),
        ),
        SizedBox(
          height: 32,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Black Duration',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 8,
              ),
              Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 8,
                  children: blackChips),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  )),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.black)),
              onPressed: () {
                Navigator.pop(context, [white, black]);
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8),
                child: Text(
                  'OK',
                ),
              )),
        )
      ],
    )));
  }

  Widget _whiteChoiceChip(int seconds) {
    return ChoiceChip(
      label: Text(fromSecondsToString(seconds),
          style:
              TextStyle(color: white == seconds ? Colors.white : Colors.black)),
      selected: white == seconds,
      backgroundColor: Colors.white,
      elevation: 2,
      selectedColor: Colors.black,
      onSelected: (value) {
        setState(() {
          white = seconds;
        });
      },
    );
  }

  Widget _blackChoiceChip(int seconds) {
    return ChoiceChip(
      label: Text(
        fromSecondsToString(seconds),
        style: TextStyle(color: black == seconds ? Colors.white : Colors.black),
      ),
      backgroundColor: Colors.white,
      elevation: 2,
      selected: black == seconds,
      selectedColor: Colors.black,
      onSelected: (value) {
        setState(() {
          black = seconds;
        });
      },
    );
  }

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedDurations = prefs.getStringList('durations2');
    if (storedDurations != null && storedDurations.isNotEmpty) {
      setState(() {
        durations = storedDurations.map((e) => int.parse(e)).toList();
      });
    } else {
      prefs.setStringList(
          'durations', durations.map((e) => e.toString()).toList());
    }
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
