import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const NotesPage(),
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  NotesPageState createState() => NotesPageState();
}

class NotesPageState extends State<NotesPage> {
  List<Note> notes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: AppBar(  
          title: Container(
            margin: const EdgeInsets.only(top: 10.0),
            child: const Text(
              'Notes',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 34,
                color: Color.fromARGB(255, 62, 78, 47),
              ),
            ),
          ),
          centerTitle: true,
        ),
      ),
      body: notes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/Logo.png',
                    width: 65,
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Your note is still empty, try clicking',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color.fromARGB(255, 62, 78, 47),
                    ),
                  ),
                  const Text(
                    'the "+" to add your note.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color.fromARGB(255, 62, 78, 47),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 20.0),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey),
                      bottom: BorderSide(color: Colors.grey),
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      notes[index].title,
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 62, 78, 47),
                      ),
                    ),
                    subtitle: Text(
                      notes[index].formattedDate(),
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Color.fromARGB(255, 128, 149, 102),
                      ),
                    ),
                    onTap: () {
                      _navigateToNoteDetail(context, notes[index]);
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        _onDeleteNotePressed(context, notes[index]);
                      },
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 19.0),
                  ),
                );
              },
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 30.0, right: 10.0),
        child: FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 62, 78, 47),
          onPressed: () {
            _navigateToAddNoteScreen(context);
          },
          shape: const CircleBorder(),
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _navigateToAddNoteScreen(BuildContext context) async {
    final newNote = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NoteEditPage()),
    );
    if (newNote != null) {
      setState(() {
        notes.add(newNote);
      });
    }
  }

  void _navigateToNoteDetail(BuildContext context, Note note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteDetailPage(note: note)),
    );

    if (result != null && result is Note) {
      int index = notes.indexWhere((element) => element.id == result.id);
      if (index != -1) {
        setState(() {
          notes[index] = result;
        });
      }
    }
  }

  void _onDeleteNotePressed(BuildContext context, Note note) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteNote(note);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteNote(Note note) {
    setState(() {
      notes.remove(note);
    });
  }
}

class Note {
  int id;
  String title;
  String text;
  DateTime dateCreated;
  File? image;

  Note(
      {required this.id,
      required this.title,
      required this.text,
      required this.dateCreated,
      this.image});

  String formattedDate() {
    return '${_getWeekDay(dateCreated.weekday)} ${dateCreated.day} ${_getMonth(dateCreated.month)}';
  }

  String _getWeekDay(int weekday) {
    switch (weekday) {
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

  String _getMonth(int month) {
    switch (month) {
      case DateTime.january:
        return 'January';
      case DateTime.february:
        return 'February';
      case DateTime.march:
        return 'March';
      case DateTime.april:
        return 'April';
      case DateTime.may:
        return 'May';
      case DateTime.june:
        return 'June';
      case DateTime.july:
        return 'July';
      case DateTime.august:
        return 'August';
      case DateTime.september:
        return 'September';
      case DateTime.october:
        return 'October';
      case DateTime.november:
        return 'November';
      case DateTime.december:
        return 'December';
      default:
        return '';
    }
  }
}

class NoteEditPage extends StatefulWidget {
  const NoteEditPage({Key? key}) : super(key: key);

  @override
  NoteEditPageState createState() => NoteEditPageState();
}

class NoteEditPageState extends State<NoteEditPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  File? image;

  double getImageWidthFactor() {
    if (image != null) {
      return 0.4;
    } else {
      return 0.0;
    }
  }

  Future<void> getImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagePicked =
        await picker.pickImage(source: ImageSource.gallery);
    if (imagePicked != null) {
      setState(() {
        image = File(imagePicked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              _saveNote();
            },
            icon: const Icon(
              Icons.save_outlined,
              color: Color.fromARGB(255, 62, 78, 47),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'getImage') {
                getImage();
              } else if (value == 'share') {
                _share(_titleController.text, _textController.text);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'getImage',
                child: ListTile(
                  leading: Icon(Icons.image_outlined,
                      color: Color.fromARGB(255, 62, 78, 47)),
                  title: Text('Add Image',
                      style: TextStyle(
                        color: Color.fromARGB(255, 62, 78, 47),
                      )),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'share',
                child: ListTile(
                  leading: Icon(Icons.ios_share_outlined,
                      color: Color.fromARGB(255, 62, 78, 47)),
                  title: Text(
                    'Share',
                    style: TextStyle(
                      color: Color.fromARGB(255, 62, 78, 47),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
         padding: const EdgeInsets.symmetric(
          vertical: 2.0, 
          horizontal: 31.0), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                  hintText: 'Title',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    fontSize: 32.0,
                  )),
              style: GoogleFonts.lato(
                textStyle: const TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 62, 78, 47),
                ),
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              DateFormat('EEE dd MMM | HH:mm').format(DateTime.now()),
              style: GoogleFonts.lato(
                textStyle: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 128, 149, 102),
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            image != null
                ? GestureDetector(
                    onTap: () {
                      _showDeleteImageDialog();
                    },
                    child: SizedBox(
                      height: MediaQuery.of(context).size.width *
                          getImageWidthFactor(),
                      width: MediaQuery.of(context).size.width *
                          getImageWidthFactor(),
                      child: Image.file(
                        image!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : Container(),
            const SizedBox(height: 12.0),
            Expanded(
              child: Container(
                height: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: const Color.fromARGB(255, 246, 246, 246),
                ),
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Add your text here',
                    border: InputBorder.none,
                    hintStyle: GoogleFonts.lato(
                      textStyle: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 119, 119, 119),
                      ),
                    ),
                    alignLabelWithHint: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveNote() {
    final title = _titleController.text;
    final text = _textController.text;

    if (title.isNotEmpty) {
      final newNote = Note(
        id: DateTime.now().millisecondsSinceEpoch,
        title: title,
        text: text,
        dateCreated: DateTime.now(),
        image: image,
      );
      Navigator.pop(context, newNote);
    } else {
      // Handle empty fields
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Please enter a title.'),
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
  }

  void _share(String title, String text) {
    final title = _titleController.text;
    final text = _textController.text;

    if (title.isNotEmpty || text.isNotEmpty || image != null) {
      if (image != null) {
        List<XFile> xFiles = [XFile(image!.path)];
        Share.shareXFiles(xFiles, text: '$title\n$text');
      } else {
        Share.share(title);
        Share.share(text);
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('No text or image to share.'),
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
  }

  void _showDeleteImageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Image'),
          content: const Text('Are you sure you want to delete this image?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteImage();
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteImage() {
    setState(() {
      image = null;
    });
  }
}

class NoteDetailPage extends StatefulWidget {
  final Note note;

  const NoteDetailPage({Key? key, required this.note}) : super(key: key);

  @override
  NoteDetailPageState createState() => NoteDetailPageState();
}

class NoteDetailPageState extends State<NoteDetailPage> {
  late TextEditingController _titleController;
  late TextEditingController _textController;
  File? image;

  double getImageWidthFactor() {
    if (image != null) {
      return 0.4;
    } else {
      return 0.0;
    }
  }

  Future<void> getImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagePicked =
        await picker.pickImage(source: ImageSource.gallery);
    if (imagePicked != null) {
      setState(() {
        image = File(imagePicked.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _textController = TextEditingController(text: widget.note.text);
    image = widget.note.image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              _saveNote();
            },
            icon: const Icon(
              Icons.save_outlined,
              color: Color.fromARGB(255, 62, 78, 47),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'getImage') {
                getImage();
              } else if (value == 'share') {
                _share(_titleController.text, _textController.text);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'getImage',
                child: ListTile(
                  leading: Icon(Icons.image_outlined,
                      color: Color.fromARGB(255, 62, 78, 47)),
                  title: Text(
                    'Add Image',
                    style: TextStyle(color: Color.fromARGB(255, 63, 78, 47)),
                  ),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'share',
                child: ListTile(
                  leading: Icon(Icons.ios_share_outlined,
                      color: Color.fromARGB(255, 62, 78, 47)),
                  title: Text('Share',
                      style: TextStyle(color: Color.fromARGB(255, 62, 78, 47))),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
         padding: const EdgeInsets.symmetric(
          vertical: 2.0, 
          horizontal: 31.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                  hintText: 'Title',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    fontSize: 32.0,
                  )),
              style: GoogleFonts.lato(
                textStyle: const TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 62, 78, 47),
                ),
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              DateFormat('EEE dd MMM | HH:mm').format(DateTime.now()),
              style: GoogleFonts.lato(
                textStyle: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 128, 149, 102),
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            image != null
                ? GestureDetector(
                    onTap: () {
                      _showDeleteImageDialog();
                    },
                    child: SizedBox(
                      height: MediaQuery.of(context).size.width *
                          getImageWidthFactor(),
                      width: MediaQuery.of(context).size.width *
                          getImageWidthFactor(),
                      child: Image.file(
                        image!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : Container(),
            const SizedBox(height: 12.0),
            Expanded(
              child: Container(
                height: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: const Color.fromARGB(255, 246, 246, 246),
                ),
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Add your text here',
                    border: InputBorder.none,
                    hintStyle: GoogleFonts.lato(
                      textStyle: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 119, 119, 119),
                      ),
                    ),
                    alignLabelWithHint: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveNote() {
    final title = _titleController.text;
    final text = _textController.text;

    if (image == null) {
      widget.note.image = null;
    }
    if (title.isNotEmpty) {
      final updatedNote = widget.note.copyWith(
        title: title,
        text: text,
        dateCreated: DateTime.now(),
        image: image,
      );
      Navigator.pop(context, updatedNote);
    } else {
      // Handle empty fields
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Please enter a title.'),
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
  }

  void _share(String title, String text) {
    final title = _titleController.text;
    final text = _textController.text;

    if (title.isNotEmpty || text.isNotEmpty || image != null) {
      if (image != null) {
        List<XFile> xFiles = [XFile(image!.path)];
        Share.shareXFiles(xFiles, text: '$title\n$text');
      } else {
        Share.share(title);
        Share.share(text);
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('No text or image to share.'),
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
  }

  void _showDeleteImageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Image'),
          content: const Text('Are you sure you want to delete this image?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteImage();
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteImage() {
    setState(() {
      image = null;
    });
  }
}

extension CopyWithExtension on Note {
  Note copyWith({
    int? id,
    String? title,
    String? text,
    DateTime? dateCreated,
    File? image,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      text: text ?? this.text,
      dateCreated: dateCreated ?? this.dateCreated,
      image: image ?? this.image,
    );
  }
}
