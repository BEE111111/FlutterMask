import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'main.dart';
import 'menu.dart';

class Scientist {
  String username;
  String authorInRussian;
  String firstAuthor;
  String jobTitle;
  String relations;
  String scienceTitle;

  Scientist({
    required this.username,
    required this.authorInRussian,
    required this.firstAuthor,
    required this.jobTitle,
    required this.relations,
    required this.scienceTitle,
  });

  factory Scientist.fromJson(Map<String, dynamic> json) {
    return Scientist(
      username: json['username'],
      authorInRussian: json['author_in_russian'],
      firstAuthor: json['first_author'],
      jobTitle: json['job_title'],
      relations: json['relations'],
      scienceTitle: json['science_title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'author_in_russian': authorInRussian,
      'first_author': firstAuthor,
      'job_title': jobTitle,
      'relations': relations,
      'science_title': scienceTitle,
    };
  }
}

class ApiService {
  Future<Scientist?> getScientist(String username) async {
    final response = await http.get(
      Uri.parse('$baseUrl/scientist/$username/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'ngrok-skip-browser-warning': 'true'
      },
    );
    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      return Scientist.fromJson(json.decode(decodedResponse));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load scientist');
    }
  }

  Future<bool> registerScientist(Scientist scientist) async {
    final response = await http.post(
      Uri.parse('$baseUrl/scientist/register/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'ngrok-skip-browser-warning': 'true'
      },
      body: jsonEncode(scientist.toJson()),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> updateScientist(Scientist scientist) async {
    final response = await http.put(
      Uri.parse('$baseUrl/scientist/update/${scientist.username}/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'ngrok-skip-browser-warning': 'true'
      },
      body: jsonEncode(scientist.toJson()),
    );
    return response.statusCode == 200;
  }
}

class SettingsScreen extends StatefulWidget {
  final String username;

  SettingsScreen({required this.username});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _checkScientist();
  }

  void _checkScientist() async {
    try {
      Scientist? scientist = await _apiService.getScientist(widget.username);
      if (scientist == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ScientistRegistrationScreen(username: widget.username),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ScientistUpdateScreen(scientist: scientist),
          ),
        );
      }
    } catch (e) {
      print("Error fetching scientist: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки',
            style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontFamily: "Raleway",
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.brown[300],
        toolbarHeight: 100,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class ScientistUpdateScreen extends StatefulWidget {
  final Scientist scientist;

  ScientistUpdateScreen({required this.scientist});

  @override
  _ScientistUpdateScreenState createState() => _ScientistUpdateScreenState();
}

class _ScientistUpdateScreenState extends State<ScientistUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  late Scientist _scientist;

  @override
  void initState() {
    super.initState();
    _scientist = widget.scientist;
  }

  void _updateScientist() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      bool success = await _apiService.updateScientist(_scientist);
      if (success) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.brown[50],
              content: ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text(
                  'Вы успешно изменили данные.',
                ),
              ),
              title: Text('Данные изменены'),
              actions: <Widget>[
                MaterialButton(
                  color: Colors.brown,
                  child: Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Menu()));
                  },
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Colors.brown[50],
                title: Text('Ошибка'),
                content: ListTile(
                  leading: Icon(Icons.error, color: Colors.red),
                  title: Text('Заполните все поля'),
                ),
                actions: <Widget>[
                  MaterialButton(
                    color: Colors.brown,
                    child: Text('OK', style: TextStyle(color: Colors.white)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.brown[300],
        appBar: AppBar(
          title: const Text('Настройки',
              style: TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontFamily: "Raleway",
                  fontWeight: FontWeight.bold)),
          backgroundColor: Colors.brown[300],
          toolbarHeight: 100,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Column(children: [
          Expanded(
              child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: _scientist.authorInRussian,
                      decoration: InputDecoration(
                        labelText: 'ФИО на русском',
                        focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.brown, width: 1.5)),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      onSaved: (value) {
                        if (value != null) {
                          _scientist?.authorInRussian = value;
                        }
                      },
                    ),
                    TextFormField(
                      initialValue: _scientist.firstAuthor,
                      decoration: InputDecoration(
                        labelText: 'ФИО на английском',
                        focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.brown, width: 1.5)),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      onSaved: (value) {
                        if (value != null) {
                          _scientist?.firstAuthor = value;
                        }
                      },
                    ),
                    TextFormField(
                      initialValue: _scientist.jobTitle,
                      decoration: InputDecoration(
                        labelText: 'Должность',
                        focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.brown, width: 1.5)),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      onSaved: (value) {
                        if (value != null) {
                          _scientist?.jobTitle = value;
                        }
                      },
                    ),
                    TextFormField(
                      initialValue: _scientist.relations,
                      decoration: InputDecoration(
                        labelText: 'Тип трудовых отношений',
                        focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.brown, width: 1.5)),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      onSaved: (value) {
                        if (value != null) {
                          _scientist?.relations = value;
                        }
                      },
                    ),
                    TextFormField(
                      initialValue: _scientist.scienceTitle,
                      decoration: InputDecoration(
                        labelText: 'Научная степень',
                        focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.brown, width: 1.5)),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      onSaved: (value) {
                        if (value != null) {
                          _scientist?.scienceTitle = value;
                        }
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.brown,
                        onPrimary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _updateScientist,
                      child: Text('Сохранить'),
                    ),
                  ],
                ),
              ),
            ),
          ))
        ]));
  }
}

class ScientistRegistrationScreen extends StatefulWidget {
  final String username;

  ScientistRegistrationScreen({required this.username});

  @override
  _ScientistRegistrationScreenState createState() =>
      _ScientistRegistrationScreenState();
}

class _ScientistRegistrationScreenState
    extends State<ScientistRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  late Scientist _scientist;

  @override
  void initState() {
    super.initState();
    _scientist = Scientist(
      username: widget.username,
      authorInRussian: '',
      firstAuthor: '',
      jobTitle: '',
      relations: '',
      scienceTitle: '',
    );
  }

  void _registerScientist() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      bool success = await _apiService.registerScientist(_scientist);
      if (success) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.brown[50],
              content: ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text(
                  'Вы успешно изменили данные.',
                ),
              ),
              title: Text('Данные изменены'),
              actions: <Widget>[
                MaterialButton(
                  color: Colors.brown,
                  child: Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Menu()));
                  },
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Colors.brown[50],
                title: Text('Ошибка'),
                content: ListTile(
                  leading: Icon(Icons.error, color: Colors.red),
                  title: Text('Проверьте данные'),
                ),
                actions: <Widget>[
                  MaterialButton(
                    color: Colors.brown,
                    child: Text('OK', style: TextStyle(color: Colors.white)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Заполнить информацию о себе',
            style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontFamily: "Raleway",
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.brown[300],
        toolbarHeight: 100,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'ФИО на русском',
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.brown, width: 1.5)),
                  labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
                onSaved: (value) {
                  if (value != null) {
                    _scientist?.authorInRussian = value;
                  }
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'ФИО на английском',
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.brown, width: 1.5)),
                  labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
                onSaved: (value) {
                  if (value != null) {
                    _scientist?.firstAuthor = value;
                  }
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Должность',
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.brown, width: 1.5)),
                  labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
                onSaved: (value) {
                  if (value != null) {
                    _scientist?.jobTitle = value;
                  }
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Тип трудовых отношений',
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.brown, width: 1.5)),
                  labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
                onSaved: (value) {
                  if (value != null) {
                    _scientist?.relations = value;
                  }
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Научная степень',
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.brown, width: 1.5)),
                  labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
                onSaved: (value) {
                  if (value != null) {
                    _scientist?.scienceTitle = value;
                  }
                },
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.brown,
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _registerScientist,
                child: Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
