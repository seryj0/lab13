import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database.dart';

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _databaseHelper = DatabaseHelper();

  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  _loadNotes() async {
    List<Note> notes = await _databaseHelper.getNotes();
    setState(() {
      _notes = notes;
    });
  }

  _addNote() async {
    if (_formKey.currentState!.validate()) {
      String content = _controller.text;
      DateTime now = DateTime.now();
      Note note = Note(content: content, createdAt: now);
      await _databaseHelper.insertNote(note);
      _controller.clear();

      setState(() {
        _notes.insert(0, note);
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Note added at ${now.toIso8601String()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notes')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _controller,
                decoration: InputDecoration(labelText: 'Enter note'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Note cannot be empty';
                  }
                  return null;
                },
              ),
            ),
            ElevatedButton(
              onPressed: _addNote,
              child: Text('Add Note'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  final note = _notes[index];
                  return ListTile(
                    title: Text(note.content),
                    subtitle: Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(note.createdAt)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
