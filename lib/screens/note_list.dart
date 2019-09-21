import 'package:flutter/material.dart';
import 'package:flutter_notekeeper/models/note.dart';
import 'package:flutter_notekeeper/screens/note_details.dart';
import 'package:flutter_notekeeper/storage/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget {
  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  int count = 0;
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = List<Note>();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
      ),
      body: _getAllListItem(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(Note("", "", 1), "Add Note");
        },
        elevation: 3.0,
        child: Icon(Icons.add),
      ),
    );
  }

  ListView _getAllListItem() {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
                backgroundColor: Colors.yellow,
                child: getPriorityIcon(this.noteList[position].priority),
            ),
            title: Text(this.noteList[position].title),
            subtitle: Text(this.noteList[position].date),
            trailing: GestureDetector(
              child: Icon(
                Icons.delete,
                color: Colors.grey,),
              onTap: () {
                _delete(context, noteList[position]);
              },
            ),
            onTap: () {
              navigateToDetail(this.noteList[position], "Edit Note");
            },
          ),
        );
      },
    );
  }

  void navigateToDetail(Note note, String title) async {
    bool result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
      return NoteDetails(note, title);
    }));

    if (result) {
      updateListView();
    }
  }

  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;
      default:
        return Colors.yellow;
        break;
    }
  }

  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.play_arrow);
        break;
      case 2:
        return Icon(Icons.keyboard_arrow_right);
        break;
      default:
        return Icon(Icons.keyboard_arrow_right);
        break;
    }
  }

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      //_showSnackbar(context,"Note Deleted Successfully!");
      updateListView();
    }
  }

  void updateListView() async {
    List<Note> noteList = await databaseHelper.getNoteList();
    setState(() {
      this.noteList = noteList;
      this.count = noteList.length;
    });
  }
}
