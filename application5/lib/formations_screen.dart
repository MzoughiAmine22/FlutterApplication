import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'user.dart';

class FormationsScreen extends StatefulWidget {
  final User user;
  const FormationsScreen({Key? key, required this.user}) : super(key: key);

  @override
  _FormationsScreenState createState() => _FormationsScreenState();
}

class _FormationsScreenState extends State<FormationsScreen> {
  final String baseUrl = "http://localhost:8081";
  List<dynamic> formations = [];

  final _titreController = TextEditingController();
  final _descController = TextEditingController();
  final _dureeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchFormations();
  }

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'x-role': widget.user.role,
  };

  Future<void> fetchFormations() async {
    final res = await http.get(Uri.parse('$baseUrl/formations'));
    if (res.statusCode == 200) {
      setState(() => formations = jsonDecode(res.body));
    }
  }

  void _clearFields() {
    _titreController.clear();
    _descController.clear();
    _dureeController.clear();
  }

  void _showDialog({Map<String, dynamic>? formation}) {
    if (formation != null) {
      _titreController.text = formation['titre'];
      _descController.text = formation['description'] ?? '';
      _dureeController.text = formation['duree'].toString();
    } else {
      _clearFields();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(formation == null ? 'New Formation' : 'Edit Formation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titreController,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(hintText: 'Description'),
            ),
            TextField(
              controller: _dureeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Duration (hours)'),
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
                'titre': _titreController.text,
                'description': _descController.text,
                'duree': int.tryParse(_dureeController.text) ?? 0,
              });
              if (formation == null) {
                await http.post(Uri.parse('$baseUrl/formations'),
                    headers: headers, body: body);
              } else {
                await http.put(
                    Uri.parse('$baseUrl/formations/${formation['id']}'),
                    headers: headers,
                    body: body);
              }
              Navigator.pop(context);
              fetchFormations();
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
        title: const Text('Manage Formations'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: formations.isEmpty
          ? const Center(child: Text('No formations found.'))
          : ListView.builder(
        itemCount: formations.length,
        itemBuilder: (context, index) {
          final f = formations[index];
          return Dismissible(
            key: Key(f['id'].toString()),
            onDismissed: (_) async {
              await http.delete(
                Uri.parse('$baseUrl/formations/${f['id']}'),
                headers: headers,
              );
              fetchFormations();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${f['titre']} deleted')),
              );
            },
            background: Container(color: Colors.red),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.pinkAccent,
                child: Text(
                  f['id'].toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(f['titre']),
              subtitle: Text(
                  '${f['description'] ?? ''} - ${f['duree']}h'),
              trailing: widget.user.role == 'admin'
                  ? IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showDialog(formation: f),
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