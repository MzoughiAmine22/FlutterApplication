import 'package:flutter/material.dart';
import 'user.dart';
import 'students_screen.dart';
import 'classes_screen.dart';
import 'formations_screen.dart';

class Dashboard extends StatelessWidget {
  final User user;
  const Dashboard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.pinkAccent,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.pinkAccent),
              accountName: Text(user.role.toUpperCase()),
              accountEmail: Text(user.email),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.pinkAccent, size: 36),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Manage Students'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => StudentsScreen(user: user),
                ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.class_),
              title: const Text('Manage Classes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => ClassesScreen(user: user),
                ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Manage Formations'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => FormationsScreen(user: user),
                ));
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to the dashboard\nof your application!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.black45),
            ),
            const SizedBox(height: 30),
            Text('Logged in as: ${user.email}',
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            Text('Role: ${user.role}',
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}