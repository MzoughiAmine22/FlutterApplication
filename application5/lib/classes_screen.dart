import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'user.dart';

class ClassesScreen extends StatefulWidget {
  final User user;
  const ClassesScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ClassesScreenState createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  final String baseUrl = "http://localhost:8081";
  List<dynamic> classes = [];

  final _nomController = TextEditingController();
  final _nbreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchClasses();
  }

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'x-role': widget.user.role,
  };

  Future<void> fetchClasses() async {
    final res = await http.get(Uri.parse('$baseUrl/classes'));
    if (res.statusCode == 200) {
      setState(() => classes = jsonDecode(res.body));
    }
  }

  void _clearFields() {
    _nomController.clear();
    _nbreController.clear();
  }

  void _showDialog({Map<String, dynamic>? cls}) {
    if (cls != null) {
      _nomController.text = cls['nomClass'];
      _nbreController.text = cls['nbreEtud'].toString();
    } else {
      _clearFields();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(cls == null ? 'New Class' : 'Edit Class'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nomController,
              decoration: const InputDecoration(hintText: 'Class name'),
            ),
            TextField(
              controller: _nbreController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Number of students'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final body = json.encode({
                'nomClass': _nomController.text,
                'nbreEtud': int.tryParse(_nbreController.text) ?? 0,
              });
              if (cls == null) {
                await http.post(Uri.parse('$baseUrl/classes'),
                    headers: headers, body: body);
              } else {
                await http.put(
                    Uri.parse('$baseUrl/classes/${cls['codClass']}'),
                    headers: headers,
                    body: body);
              }
              Navigator.pop(context);
              fetchClasses();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Classes'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: classes.isEmpty
          ? const Center(child: Text('No classes found.'))
          : ListView.builder(
        itemCount: classes.length,
        itemBuilder: (context, index) {
          final cls = classes[index];
          return Dismissible(
            key: Key(cls['codClass'].toString()),
            onDismissed: (_) async {
              await http.delete(
                Uri.parse('$baseUrl/classes/${cls['codClass']}'),
                headers: headers,
              );
              fetchClasses();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${cls['nomClass']} deleted')),
              );
            },
            background: Container(color: Colors.red),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.pinkAccent,
                child: Text(
                  cls['codClass'].toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(cls['nomClass']),
              subtitle: Text('Students: ${cls['nbreEtud']}'),
              trailing: widget.user.role == 'admin'
                  ? IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showDialog(cls: cls),
              )
                  : null,
            ),
          );
        },
      ),
      floatingActionButton: widget.user.role == 'admin'
          ? FloatingActionButton(
        backgroundColor: Colors.pink,
        onPressed: () => _showDialog(),
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}