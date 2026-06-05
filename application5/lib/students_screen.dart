import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'user.dart';

class StudentsScreen extends StatefulWidget {
  final User user;
  const StudentsScreen({Key? key, required this.user}) : super(key: key);

  @override
  _StudentsScreenState createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final String baseUrl = "http://localhost:8081";

  List<dynamic> students = [];
  List<dynamic> classes = [];
  int? selectedClassCode; // null = All

  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _datNaisController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchClasses();
    fetchStudents();
  }

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'x-role': widget.user.role,
  };

  Future<void> fetchClasses() async {
    final res = await http.get(Uri.parse('$baseUrl/classes'));
    if (res.statusCode == 200) {
      setState(() {
        classes = jsonDecode(res.body);
      });
    }
  }

  Future<void> fetchStudents() async {
    String url = '$baseUrl/etudiants';
    if (selectedClassCode != null) {
      url += '?codClass=$selectedClassCode';
    }
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      setState(() {
        students = jsonDecode(res.body);
      });
    }
  }

  void _clearFields() {
    _nomController.clear();
    _prenomController.clear();
    _datNaisController.clear();
  }

  void _showDialog({Map<String, dynamic>? student}) {
    if (student != null) {
      _nomController.text = student['nom'];
      _prenomController.text = student['prenom'];
      _datNaisController.text = student['datNais'];
    } else {
      _clearFields();
    }

    int? dialogClassCode = selectedClassCode ?? (classes.isNotEmpty ? classes[0]['codClass'] : null);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(student == null ? 'New Student' : 'Edit Student'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Class selector inside dialog
                DropdownButton<int>(
                  isExpanded: true,
                  value: dialogClassCode,
                  items: classes.map<DropdownMenuItem<int>>((cls) {
                    return DropdownMenuItem<int>(
                      value: cls['codClass'] as int,
                      child: Text(cls['nomClass']),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setDialogState(() => dialogClassCode = val);
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nomController,
                  decoration: const InputDecoration(hintText: 'Last name'),
                ),
                TextField(
                  controller: _prenomController,
                  decoration: const InputDecoration(hintText: 'First name'),
                ),
                TextField(
                  controller: _datNaisController,
                  decoration: const InputDecoration(hintText: 'Date of birth (dd-MM-yyyy)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (student == null) {
                  await http.post(
                    Uri.parse('$baseUrl/etudiants'),
                    headers: headers,
                    body: json.encode({
                      'codClass': dialogClassCode,
                      'nom': _nomController.text,
                      'prenom': _prenomController.text,
                      'datNais': _datNaisController.text,
                    }),
                  );
                } else {
                  await http.put(
                    Uri.parse('$baseUrl/etudiants/${student['id']}'),
                    headers: headers,
                    body: json.encode({
                      'nom': _nomController.text,
                      'prenom': _prenomController.text,
                      'datNais': _datNaisController.text,
                    }),
                  );
                }
                Navigator.pop(context);
                fetchStudents();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Students'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Column(
        children: [
          // DropDownButton to filter by class
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Text('Selected class: ',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<int?>(
                    isExpanded: true,
                    value: selectedClassCode,
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('All'),
                      ),
                      ...classes.map<DropdownMenuItem<int?>>((cls) {
                        return DropdownMenuItem<int?>(
                          value: cls['codClass'] as int,
                          child: Text(cls['nomClass']),
                        );
                      }).toList(),
                    ],
                    onChanged: (val) {
                      setState(() => selectedClassCode = val);
                      fetchStudents();
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Student list
          Expanded(
            child: students.isEmpty
                ? const Center(child: Text('No students found.'))
                : ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final s = students[index];
                return Dismissible(
                  key: Key(s['id'].toString()),
                  onDismissed: (_) async {
                    await http.delete(
                      Uri.parse('$baseUrl/etudiants/${s['id']}'),
                      headers: headers,
                    );
                    fetchStudents();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${s['nom']} deleted')),
                    );
                  },
                  background: Container(color: Colors.red),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.pinkAccent,
                      child: Text(
                        s['nom'][0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text('${s['nom']} ${s['prenom']}'),
                    subtitle: Text('Birthday: ${s['datNais']}'),
                    trailing: widget.user.role == 'admin'
                        ? IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showDialog(student: s),
                    )
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
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