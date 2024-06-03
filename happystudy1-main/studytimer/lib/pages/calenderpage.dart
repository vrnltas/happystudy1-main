import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timezone/timezone.dart' as tz;

final Logger logger = Logger();

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ScreenCalendar(
        onEventAdded: (String title, DateTime date, String startTime, ) {},
        onEventClicked: (String title, DateTime date, String startTime,) {},
      ),
    );
  }
}

class ScreenCalendar extends StatefulWidget {
  final void Function(String title, DateTime date, String startTime,)
      onEventAdded;
  final void Function(String title, DateTime date, String startTime,)
      onEventClicked;

  const ScreenCalendar({
    Key? key,
    required this.onEventAdded,
    required this.onEventClicked,
  }) : super(key: key);

  @override
  ScreenCalendarState createState() => ScreenCalendarState();
}

class ScreenCalendarState extends State<ScreenCalendar> {
  late DateTime _selectedDate;
  List<Map<String, dynamic>> _events = [];
  late Timer _timer;
  Map<DateTime, double> dailyTimerData = {};

  

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _timer = Timer(const Duration(seconds: 0), () {});
    _loadEventsFromFirestore();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadEventsFromFirestore() async {
    FirebaseFirestore.instance.collection('events').get().then((snapshot) {
      setState(() {
        _events = snapshot.docs.map((doc) {
          final data = doc.data();
          data['date'] = (data['date'] as Timestamp)
              .toDate(); // Convert Timestamp to DateTime
          return data;
        }).toList();
      });
    }).catchError((error) {
      print("Error loading events: $error");
    });
  }

  void _addEvent(String uid, String title, DateTime date, String startTime) {
    final event = {
      'uid': uid,
      'create-at': title,
      'date': date,
      'Time': startTime,
    };
    FirebaseFirestore.instance
        .collection('events')
        .add(event)
        .then((documentRef) {
      final String docId = documentRef.id;
      // Add the ID to the event object
      event['id'] = docId;
      // Update the document with the ID
      documentRef.update({'id': docId});
      setState(() {
        _events.add(event);
      });
    }).catchError((error) {
      print("Error adding event: $error");
    });
  }

  void _deleteEvent(int index) {
    final event = _events[index];
    final docId = event['id'];

    FirebaseFirestore.instance
        .collection('events')
        .doc(docId)
        .delete()
        .then((_) {
      setState(() {
        _events.removeAt(index);
      });
    }).catchError((error) {
      print("Error deleting event: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: CalendarPage(
                  selectedDate: _selectedDate,
                  events: _events,
                  onDateSelected: (DateTime date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                ),
              )
            ],
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Container(
                margin: const EdgeInsets.only(top: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Reminder',
                        style: GoogleFonts.lato(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 35),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _events.isEmpty ? 1 : _events.length,
                        itemBuilder: (context, index) {
                          if (_events.isEmpty) {
                            return Center(
                              child: Column(
                                children: [
                                  const SizedBox(height: 2),
                                  Image.asset(
                                    'assets/images/Logo.png',
                                    width: 65,
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    'Your task is still empty, try clicking',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.lato(
                                      textStyle: const TextStyle(
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'the "+" to add your task.',
                                    style: GoogleFonts.lato(
                                      textStyle: const TextStyle(
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            // FirebaseFirestore.instance.collection('events').where(_uid == userId).snapshots()
                            final event = _events[index];
                            final eventDate = event['date'];
                            if (eventDate is DateTime) {
                              final selectedDateTime = DateTime(
                                  _selectedDate.year,
                                  _selectedDate.month,
                                  _selectedDate.day);
                              if (selectedDateTime.year == eventDate.year &&
                                  selectedDateTime.month == eventDate.month &&
                                  selectedDateTime.day == eventDate.day) {
                              } else {
                                print("eventDate is not a DateTime object");
                                return null;
                              }
                              return Dismissible(
                                key: Key(index.toString()),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20.0),
                                  color: Colors.grey[600],
                                  child: const Icon(Icons.delete,
                                      color: Colors.white),
                                ),
                                onDismissed: (direction) {
                                  _deleteEvent(index);
                                  try {
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Event ${event['title']} deleted")),
                                    );
                                  } catch (e, stackTrace) {
                                    logger.e('Error: $e',
                                        error: e, stackTrace: stackTrace);
                                  }
                                },
                                child: EventItem(
                                  event: event,
                                  onDelete: () => _deleteEvent(index),
                                  onStart: () => (
                                    event['title'],
                                    event['date'],
                                    event['Time']
                                  ),
                                ),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0, bottom: 20),
              child: MyCustomButton(
                onEventAdded: _addEvent,
                selectedDate: _selectedDate,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EventItem extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback onDelete;
  final VoidCallback onStart;

  const EventItem({
    Key? key,
    required this.event,
    required this.onDelete,
    required this.onStart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String startTime = event['Time'];

    return Dismissible(
      key: Key(event['title']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        color: Colors.grey[600],
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        onDelete();
        try {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Event ${event['title']} deleted")),
          );
        } catch (e, stackTrace) {
          logger.e('Error: $e', error: e, stackTrace: stackTrace);
        }
      },
      child: GestureDetector(
        onTap: onStart,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.black),
              bottom: BorderSide(color: Colors.black),
            ),
          ),
          padding: const EdgeInsets.all(19),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                event['title'],
                style:
                    const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    ' $startTime',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
              const Icon(Icons.notifications)
            ],
          ),
        ),
      ),
    );
  }
}

class MyCustomButton extends StatelessWidget {
  final Function(String, String, DateTime, String) onEventAdded;
  final DateTime selectedDate;

  const MyCustomButton({
    Key? key,
    required this.onEventAdded,
    required this.selectedDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 48, 64, 41),
        borderRadius: BorderRadius.circular(100),
      ),
      padding: const EdgeInsets.all(0.5),
      child: IconButton(
        icon: const Icon(
          Icons.add,
          color: Color.fromARGB(255, 255, 255, 255),
          size: 36,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewEventPage(
                onEventAdded: onEventAdded,
                selectedDate: selectedDate,
              ),
            ),
          );
        },
      ),
    );
  }
}

class CalendarPage extends StatelessWidget {
  final DateTime selectedDate;
  final List<Map<String, dynamic>> events;
  final ValueChanged<DateTime> onDateSelected;

  const CalendarPage({
    Key? key,
    required this.selectedDate,
    required this.events,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 5, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 1),
            child: TableCalendar(
              focusedDay: selectedDate,
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              calendarFormat: CalendarFormat.month,
              onFormatChanged: (format) {},
              startingDayOfWeek: StartingDayOfWeek.sunday,
              daysOfWeekVisible: true,
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: GoogleFonts.lato(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: GoogleFonts.lato(
                  fontWeight: FontWeight.bold,
                ),
                weekendStyle: GoogleFonts.lato(
                  fontWeight: FontWeight.bold,
                ),
              ),
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(
                  color: Color.fromARGB(255, 62, 78, 47),
                  shape: BoxShape.rectangle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.rectangle,
                  border: Border.all(
                    color: const Color.fromARGB(255, 62, 78, 47),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                todayTextStyle: GoogleFonts.lato(
                  color: const Color.fromARGB(255, 62, 78, 47),
                ),
              ),
              selectedDayPredicate: (day) {
                return isSameDay(selectedDate, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                onDateSelected(selectedDay);
              },
              eventLoader: (day) {
                return events
                    .where((event) {
                      if (event['date'] is Timestamp) {
                        DateTime eventDate = event['date'].toDate();
                        return isSameDay(eventDate, day);
                      } else if (event['date'] is DateTime) {
                        DateTime eventDate = event['date'];
                        return isSameDay(eventDate, day);
                      } else {
                        return false;
                      }
                    })
                    .map((event) => event['title'])
                    .toList();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class NewEventPage extends StatefulWidget {
  final Function(String, String, DateTime, String) onEventAdded;
  final DateTime selectedDate;

  const NewEventPage({
    Key? key,
    required this.onEventAdded,
    required this.selectedDate,
  }) : super(key: key);

  @override
  NewEventPageState createState() => NewEventPageState();
}

class NewEventPageState extends State<NewEventPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  late DateTime _date;
  TimeOfDay _startTime = TimeOfDay.now();
  final String _uid = FirebaseAuth.instance.currentUser!.uid;


  @override
  void initState() {
    super.initState();
    _date = widget.selectedDate;
    _startTime = TimeOfDay.now();
  }

  void _saveEventToFirestore(
      String uid, String title, DateTime date, String startTime) async {
    final event = {
      'uid' : uid,
      'title': title,
      'date': date,
      'Time': startTime,
      
    };
    await FirebaseFirestore.instance.collection('events').add(event);
  }

  Future<void> _scheduleNotification(DateTime scheduledDateTime) async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      '2',
      'Scheduled notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    final location = tz.getLocation('Asia/Jakarta');
    final scheduledTime = tz.TZDateTime.from(scheduledDateTime, location);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Scheduled',
      'Time to complete your task',
      scheduledTime,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'customData',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Reminder'),
      ),
      body: Center(
        child: Container(
          width: 330,
          height: 400,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text('Subject'),
                ),
                TextFormField(
                  textAlignVertical: TextAlignVertical.center,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    hintText: 'Enter title',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _title = value ?? '';
                  },
                ),
                if (_formKey.currentState?.validate() ?? false)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _formKey.currentState!.validate()
                          ? ''
                          : 'Please enter a title',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 10),
                _buildDateTimeInput(
                  label: 'Date',
                  value: '${_date.day}/${_date.month}/${_date.year}',
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2022),
                      lastDate: DateTime(2030),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _date = pickedDate;
                      });
                    }
                  },
                  icon: Icons.calendar_today,
                ),
                const SizedBox(height: 10),
                _buildDateTimeInput(
                  label: 'Time',
                  value: _startTime.format(context),
                  onTap: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: _startTime,
                    );
                    if (pickedTime != null && pickedTime != _startTime) {
                      setState(() {
                        _startTime = pickedTime;
                      });
                    }
                  },
                  icon: Icons.timer_outlined,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all<Color>(Colors.white),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        side: WidgetStateProperty.all<BorderSide>(
                          const BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      child: SizedBox(
                        width: 90,
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    OutlinedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          try {
                            _saveEventToFirestore(
                                _uid, _title, _date, _startTime.format(context));
                            widget.onEventAdded(
                                _uid, _title, _date, _startTime.format(context));
                            final scheduledDateTime = DateTime(
                              _date.year,
                              _date.month,
                              _date.day,
                              _startTime.hour,
                              _startTime.minute,
                            );
                            _scheduleNotification(scheduledDateTime);
                            Navigator.pop(context);
                          } catch (e) {
                            print("Error saving event to Firestore: $e");
                            // You can also show an error message to the user here
                          }
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                            const Color.fromARGB(255, 62, 78, 47)),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: const BorderSide(width: 10),
                          ),
                        ),
                        side: WidgetStateProperty.all<BorderSide>(
                          const BorderSide(
                            color: Color.fromARGB(255, 62, 78, 47),
                          ),
                        ),
                      ),
                      child: const SizedBox(
                        width: 90,
                        child: Center(
                          child: Text(
                            'Create',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeInput({
    required String label,
    required String value,
    required Function onTap,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(label),
        ),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: InkWell(
            onTap: onTap as void Function()?,
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    style: const TextStyle(fontSize: 15),
                    value,
                    textAlign: TextAlign.center,
                  ),
                ),
                Icon(icon),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
