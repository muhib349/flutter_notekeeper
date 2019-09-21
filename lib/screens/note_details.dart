import 'package:flutter/material.dart';
import 'package:flutter_notekeeper/models/note.dart';
import 'package:flutter_notekeeper/storage/database_helper.dart';
import 'package:intl/intl.dart';

class NoteDetails extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetails(this.note, this.appBarTitle);

  @override
  _NoteDetailsState createState() =>
      _NoteDetailsState(this.note, this.appBarTitle);
}

class _NoteDetailsState extends State<NoteDetails> {
  final String _appBarTitle;
  final Note note;

  _NoteDetailsState(this.note, this._appBarTitle);

  static var _priorities = ['High', 'Low'];

  DatabaseHelper helper = DatabaseHelper();

  TextEditingController txtTitleController = TextEditingController();
  TextEditingController txtDetailsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    txtTitleController.text = note.title;
    txtDetailsController.text = note.description;

    return Scaffold(
      appBar: AppBar(
          title: Text(_appBarTitle),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          )),
      body: Padding(
        padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
        child: ListView(
          children: <Widget>[
            //first element
            ListTile(
              title: DropdownButton(
                  items: _priorities.map((String dropdownItem) {
                    return DropdownMenuItem<String>(
                      value: dropdownItem,
                      child: Text(dropdownItem),
                    );
                  }).toList(),
                  style: textStyle,
                  value: getPriorityAsString(note.priority),
                  onChanged: (selectedItem) {
                    //setState(() => updatePriorityAsInt(selectedItem));
                    updatePriorityAsInt(selectedItem);
                  }),
            ),

            //second element
            Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 15),
              child: TextField(
                controller: txtTitleController,
                style: textStyle,
                onChanged: (val) {
                  //setState(() => updateTitle());
                  updateTitle();
                },
                decoration: InputDecoration(
                  labelText: "Title",
                  labelStyle: textStyle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
            ),

            //third element
            Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 15),
              child: TextField(
                controller: txtDetailsController,
                style: textStyle,
                onChanged: (val) {
                  //setState(() => updateDescription());
                  updateDescription();
                },
                decoration: InputDecoration(
                  labelText: "Description",
                  labelStyle: textStyle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      color: Theme.of(context).primaryColorDark,
                      textColor: Theme.of(context).primaryColorLight,
                      child: Text("Save", textScaleFactor: 1.5),
                      onPressed: () {
                        setState(() {
                          _save();
                        });
                      },
                    ),
                  ),
                  Container(width: 5.0),
                  Expanded(
                    child: RaisedButton(
                      color: Theme.of(context).primaryColorDark,
                      textColor: Theme.of(context).primaryColorLight,
                      child: Text("Delete", textScaleFactor: 1.5),
                      onPressed: () {
                        setState(() {
                          _delete();
                        });
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void updateTitle() {
    note.title = txtTitleController.text;
  }

  void updateDescription() {
    note.description = txtDetailsController.text;
  }

  void updatePriorityAsInt(String val) {
    switch (val) {
      case "High":
        note.priority = 1;
        break;
      case "Low":
        note.priority = 2;
        break;
    }
  }

  String getPriorityAsString(int value) {
    String priority;

    switch (value) {
      case 1:
        priority = _priorities[0];
        break;
      case 2:
        priority = _priorities[1];
        break;
    }
    return priority;
  }

  void _save() async {
    moveToLastScreen();
    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;

    debugPrint(note.toString());
    if (note.id != null) {
      result = await helper.updateNote(note);
    } else {
      result = await helper.insertNote(note);
    }

    if (result != 0) {
      _showAlertDialog("Status", "Note saved successfully!");
    } else {
      _showAlertDialog("Status", "Problem saving note!");
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

  void _delete() async {
    moveToLastScreen();
    if (note.id == null) {
      _showAlertDialog("Status", "Empty Note");
      return;
    }

    int result = await helper.deleteNote(note.id);

    if (result != 0) {
      _showAlertDialog("Status", "Delete Sucessfully!");
    } else {
      _showAlertDialog("Status", "Some error occurred!");
    }
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }
}
