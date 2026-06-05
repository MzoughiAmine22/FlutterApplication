import 'package:application4/ui/scol_list_dialog.dart';
import 'package:application4/ui/students_screen.dart';
import 'package:application4/util/dbuse.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'models/list_etudiants.dart';
import 'models/scol_list.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Classes List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ShList(),
    );
  }
}

class ShList extends StatefulWidget {
  @override
  _ShListState createState() => _ShListState();
}

class _ShListState extends State<ShList> {
  List<ScolList>? scolList;
  dbuse helper = dbuse();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScolListDialog dialog = ScolListDialog();
    showData();
    return Scaffold(
      appBar: AppBar(
        title: Text(' Class list'),
      ),
      body: ListView.builder(
        itemCount: (scolList != null) ? scolList!.length : 0,
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
            key: Key(scolList![index].nomClass),
            onDismissed: (direction) {
              String strName = scolList![index].nomClass;
              helper.deleteList(scolList![index]);
              setState(() {
                scolList!.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("$strName deleted")));
            },
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentsScreen(scolList![index]),
                  ),
                );
              },
              title: Text(scolList![index].nomClass),
              leading: CircleAvatar(
                child: Text(scolList![index].codClass.toString()),
              ),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        dialog.buildDialog(context, scolList![index], false),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) =>
                dialog.buildDialog(context, ScolList(0, '', 0), true),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
      ),
    );
  }

  Future showData() async {
    await helper.openDb();

    String dateStart = '29-04-2026';
    DateFormat inputFormat = DateFormat('dd-MM-yyyy');
    DateTime input = inputFormat.parse(dateStart);
    String datee = DateFormat('dd-MM-yyyy').format(input);

    ScolList list1 = ScolList(11, "IngTA2-A", 30);
    int ClassId1 = await helper.insertClass(list1);
    ScolList list2 = ScolList(12, "IngTA2-B", 26);
    int ClassId2 = await helper.insertClass(list2);
    ScolList list3 = ScolList(13, "IngTA2-C", 28);
    int ClassId3 = await helper.insertClass(list3);

    ListEtudiants etud =
    ListEtudiants(1, ClassId1, "Ali", "Ben Mohamed", datee);
    int etudId1 = await helper.insertEtudiants(etud);
    print('classe Id: ' + ClassId1.toString());
    print('etudiant Id: ' + etudId1.toString());

    etud = ListEtudiants(2, ClassId2, "Salah", "Ben Salah", datee);
    await helper.insertEtudiants(etud);
    etud = ListEtudiants(3, ClassId2, "Slim", "Ben Slim", datee);
    await helper.insertEtudiants(etud);
    etud = ListEtudiants(4, ClassId3, "Foulen", "Ben Foulen", datee);
    await helper.insertEtudiants(etud);

    scolList = await helper.getClasses();
    setState(() {
      scolList = scolList;
    });
  }
}