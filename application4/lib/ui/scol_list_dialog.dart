import 'package:flutter/material.dart';
import '../util/dbuse.dart';
import '../models/scol_list.dart';

class ScolListDialog {
  final txtNomClass = TextEditingController();
  final txtNbreEtud = TextEditingController();

  Widget buildDialog(BuildContext context, ScolList list, bool isNew) {
    dbuse helper = dbuse();
    if (!isNew) {
      txtNomClass.text = list.nomClass;
      txtNbreEtud.text = list.nbreEtud.toString();
    }

    return AlertDialog(
      title: Text((isNew) ? 'Class list' : 'Edit class list'),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0)),
      content: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            TextField(
              controller: txtNomClass,
              decoration: InputDecoration(hintText: 'Class List Name'),
            ),
            TextField(
              controller: txtNbreEtud,
              keyboardType: TextInputType.number,
              decoration:
              InputDecoration(hintText: 'Class List number of students'),
            ),
            ElevatedButton(
              child: Text('Save Class List'),
              onPressed: () async {
                await helper.openDb();
                list.nomClass = txtNomClass.text;
                list.nbreEtud = int.parse(txtNbreEtud.text);
                helper.insertClass(list);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}