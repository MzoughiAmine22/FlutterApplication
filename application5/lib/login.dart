import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'user.dart';
import 'dashboard.dart';
import 'register.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  String url = "http://localhost:8081/login";

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<User> save(String email, String password) async {
    var res = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );
    if (kDebugMode) print(res.body);
    if (res.statusCode == 200) {
      return User.fromMap(jsonDecode(res.body));
    } else {
      throw Exception('Failed to login.');
    }
  }

  handleSignIn() async {
    if (_formKey.currentState == null) return;
    if (_formKey.currentState!.validate()) {
      try {
        User u = await save(_emailController.text, _passwordController.text);
        if (kDebugMode) print(u.email);
        return Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Dashboard(user: u)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not log in with these credentials!',
                style: TextStyle(fontSize: 16.0)),
            duration: Duration(seconds: 5),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('W5 : data persistence'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Container(
                  height: 520.0,
                  width: 340.0,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Text(
                          'Login',
                          style: GoogleFonts.oswald(
                            fontWeight: FontWeight.w700,
                            fontSize: 50,
                            color: Colors.black45,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value!.isEmpty) return 'Email is empty';
                              return null;
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'User Name',
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                          child: TextFormField(
                            obscureText: true,
                            controller: _passwordController,
                            validator: (value) {
                              if (value!.isEmpty) return 'Password is empty';
                              return null;
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Password',
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          height: 90,
                          width: 90,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Color.fromRGBO(233, 65, 82, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                handleSignIn();
                              }
                            },
                            child: const Icon(Icons.arrow_forward,
                                color: Colors.white, size: 30),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Register()),
                              );
                            },
                            child: RichText(
                              text: const TextSpan(
                                text: 'Does not have account? ',
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 14),
                                children: [
                                  TextSpan(
                                    text: 'Sign Up',
                                    style: TextStyle(
                                      color: Colors.pinkAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}