import 'dart:async';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:studytimer/pages/calenderpage.dart';
import 'package:studytimer/pages/note.dart';
import 'package:studytimer/screens/welcome/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    if (user.displayName != null) {
    } else {}

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        logger.e('User is currently signed out!');
      } else {
        logger.e('User is signed in!');
      }
    });

    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Map<String, dynamic>> _events = [];

  late Timer _timer = Timer(Duration.zero, () {});
  int _start = 0;
  bool _isPlaying = false;
  bool _isWorking = true;
  bool isSessionFinished = false;
  int _elapsedFocusTime = 0;
  int _elapsedBreakTime = 0;
  late final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    print("Home User : ${FirebaseAuth.instance.currentUser}");
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      sound: RawResourceAndroidNotificationSound('notification'),
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'keep going',
      'complete youre session',
      platformChannelSpecifics,
    );
  }

  void handleSessionChange() {
    _showNotification();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: _isWorking
              ? const Text('Break Session Started')
              : const Text('Work Session Started'),
          content: _isWorking
              ? const Text('Take a break for 5 minutes!')
              : const Text('Focus for 25 minutes!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _handlePomodoroFinished() {
    _showNotification();
    if (_isWorking) {
      _startTimer(25);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Congratulations!'),
            content: const Text('You have completed one session.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    isSessionFinished = true;
                  });
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _updateTimer(Timer timer) {
    if (_isPlaying && _start > 0) {
      setState(() {
        _start--;
      });
      _updateElapsedTimes(1);
    } else if (_isPlaying && _start == 0) {
      if (_isWorking) {
        _handlePomodoroFinished();
      } else {
        _startTimer(5);
      }
    }
  }

  void _updateElapsedTimes(int minutes) {
    if (_isWorking) {
      _elapsedFocusTime += minutes;
    } else {
      _elapsedBreakTime += minutes;
    }
  }

  void _startTimer(int targetMinutes) {
    setState(() {
      _start = targetMinutes * 60;
      _isPlaying = true;
      _isWorking = !_isWorking;
    });
    handleSessionChange();
    if (targetMinutes == 25 && _isWorking) {
      _timer = Timer(const Duration(minutes: 25), () {
        _handlePomodoroFinished();
        if (!isSessionFinished) {
          _startTimer(5);
        } else {
          _timer.cancel();
        }
      });
    } else if (targetMinutes == 5 && !_isWorking) {
      _timer = Timer(const Duration(minutes: 5), () {
        _handlePomodoroFinished();
        if (!isSessionFinished) {
          _startTimer(25);
        } else {
          _timer.cancel();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Duration duration = Duration(seconds: _start);
    int hours = duration.inHours.remainder(24);
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);
    double progress = _start / 60.0;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeScreen(_events, progress, hours, minutes, seconds),
          ScreenCalendar(
            onEventAdded: (title, date, startTime) => _addEvent(
                title, date, startTime as TimeOfDay, startTime as TimeOfDay),
            onEventClicked: (title, date, endTime) {},
          ),
          const NotesApp(),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
        child: GNav(
          color: const Color.fromARGB(255, 62, 78, 47),
          activeColor: const Color.fromARGB(255, 62, 78, 47),
          tabBackgroundColor: const Color.fromARGB(255, 206, 222, 189),
          gap: 5,
          padding: const EdgeInsets.all(10),
          selectedIndex: _selectedIndex,
          onTabChange: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          tabs: const [
            GButton(
              icon: Icons.home_filled,
              iconSize: 23,
              text: 'Home',
            ),
            GButton(
              icon: Icons.calendar_today_rounded,
              iconSize: 23,
              text: 'Calendar',
            ),
            GButton(
              icon: Icons.assignment_outlined,
              iconSize: 23,
              text: 'Note',
            ),
          ],
        ),
      ),
    );
  }

  void _addEvent(
    String title,
    DateTime date,
    TimeOfDay startTime,
    TimeOfDay endTime,
  ) {
    setState(() {
      _events.add({
        'title': title,
        'date': date,
        'startTime': '${startTime.hour}:${startTime.minute}',
        'endTime': '${endTime.hour}:${endTime.minute}',
      });
    });
  }

  Widget _buildHomeScreen(List<Map<String, dynamic>> events, double progress,
      int hours, int minutes, int seconds) {
    String dateString = _getDateString(DateTime.now());
    String greeting = _getGreeting();
    int focusTime = _getFocusTime();
    int breakTime = _getBreakTime();
    String formattedFocusTime = _formatDuration(Duration(minutes: focusTime));

    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 30, left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Visibility(
                    visible: _selectedIndex == 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.lato(
                              textStyle: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w600,
                                color: Color.fromARGB(255, 62, 78, 47),
                              ),
                            ),
                            children: [
                              TextSpan(
                                text: greeting,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ready to be productive?',
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                              fontSize: 20,
                              color: Color.fromARGB(255, 128, 149, 102),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Visibility(
                      visible: _selectedIndex == 0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 48,
                          height: 48,
                          color: const Color.fromARGB(255, 62, 78, 47),
                          child: IconButton(
                            icon: const Icon(Icons.logout),
                            iconSize: 25,
                            color: Colors.white,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: null,
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        const SizedBox(height: 10),
                                        Image.asset('assets/images/Emot.png'),
                                        const SizedBox(height: 20),
                                        const Text(
                                          'Comeback Soon!',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        const Text(
                                          'Are you sure you want to log out?',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Color.fromARGB(
                                                  255, 82, 81, 81)),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const WelcomeScreen()),
                                          );
                                        },
                                        child: const Text(
                                          'Yes',
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Color.fromARGB(
                                                  255, 72, 101, 82)),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 300,
              height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Lingkaran border
                  Positioned(
                    top: 1,
                    child: SizedBox(
                      width: 250,
                      height: 250,
                      child: CustomPaint(
                        painter: CirclePainter(),
                      ),
                    ),
                  ),
                  // Lingkaran progres
                  Positioned(
                    top: 1,
                    child: SizedBox(
                      width: 250,
                      height: 250,
                      child: CustomPaint(
                        painter: ProgressPainter(progress),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                              style: GoogleFonts.lato(
                                textStyle: const TextStyle(
                                    fontSize: 40, fontWeight: FontWeight.w500),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              dateString,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                textStyle: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildSessionBox('Study Time',
                'Break Time: $breakTime min\n Focus Time: $formattedFocusTime'),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isPlaying = !_isPlaying;
                        if (_isPlaying) {
                          _timer = Timer.periodic(
                            const Duration(seconds: 1),
                            _updateTimer,
                          );
                        } else {
                          _timer.cancel();
                        }
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(8),
                      side: const BorderSide(
                          width: 4, color: Color.fromARGB(255, 62, 78, 47)),
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow_rounded,
                      size: 35,
                      color: const Color.fromARGB(255, 62, 78, 47),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _timer.cancel();
                        _isPlaying = false;
                        _start = 0;
                        _elapsedFocusTime = 0;
                        _elapsedBreakTime = 0;
                        isSessionFinished = false;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(8),
                      side: const BorderSide(
                          width: 4, color: Color.fromARGB(255, 62, 78, 47)),
                    ),
                    child: const Icon(
                      Icons.stop_rounded,
                      size: 35,
                      color: Color.fromARGB(255, 62, 78, 47),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildSessionBox(String title, String details) {
    return Container(
      width: 300,
      height: 150,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 206, 222, 189),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: GoogleFonts.lato(
                textStyle: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 62, 78, 47),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSubSessionBox('Time Break', '${_getFocusTime()}', true),
                _buildSubSessionBox('Time Focus', '${_getBreakTime()}', false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubSessionBox(String title, String time, bool showMin) {
    String formattedTime = title == 'Time Focus'
        ? _formatDuration(Duration(minutes: int.parse(time)))
        : time;
    double fontSize = title == 'Time Focus' ? 18.0 : 23.0;
    return Container(
      width: 120,
      height: 65,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.lato(
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 62, 78, 47),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                formattedTime,
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 62, 78, 47),
                  ),
                ),
              ),
              if (showMin && title == 'Time Break')
                Text(
                  ' min',
                  style: GoogleFonts.lato(
                    textStyle: const TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 62, 78, 47),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  int _getFocusTime() {
    int focusTime = (_events.length ~/ 2) * 25 + (_elapsedFocusTime ~/ 60);
    return focusTime;
  }

  int _getBreakTime() {
    int breakTime = (_events.length ~/ 2) * 5 + (_elapsedBreakTime ~/ 60);
    return breakTime;
  }

  String _getDateString(DateTime date) {
    String day = _getDayString(date.weekday);
    String dayOfMonth = date.day.toString();
    String month = _getMonthString(date.month);
    return '$day $dayOfMonth $month';
  }

  String _getDayString(int dayIndex) {
    switch (dayIndex) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }

  String _getMonthString(int monthIndex) {
    switch (monthIndex) {
      case DateTime.january:
        return 'Jan';
      case DateTime.february:
        return 'Feb';
      case DateTime.march:
        return 'Mar';
      case DateTime.april:
        return 'Apr';
      case DateTime.may:
        return 'May';
      case DateTime.june:
        return 'Jun';
      case DateTime.july:
        return 'Jul';
      case DateTime.august:
        return 'Aug';
      case DateTime.september:
        return 'Sep';
      case DateTime.october:
        return 'Oct';
      case DateTime.november:
        return 'Nov';
      case DateTime.december:
        return 'Dec';
      default:
        return '';
    }
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

class CirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 128, 149, 102)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class ProgressPainter extends CustomPainter {
  final double progress;

  ProgressPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 6;
    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double arcAngle = 2 * progress * math.pi;

    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 62, 78, 47)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      arcAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
