import 'dart:convert';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'log.dart';
import 'myworks.dart';

import 'main.dart';

class Work {
  int id;
  String title;
  int checked;
  double ball;

  Work(
      {required this.id,
      required this.title,
      required this.checked,
      required this.ball});

  factory Work.fromJson(Map<String, dynamic> json) {
    return Work(
        id: json['id'] ?? 0,
        title: json['title'] ?? '',
        checked: json['checked'] ?? 0,
        ball: (json['ball'] != null)
            ? double.tryParse(json['ball'].toString()) ?? 0.0
            : 0.0);
  }

  bool get isActuallyChecked => checked == 1;
}

class Scientist {
  String author_in_russian;
  String first_author;
  String job_title;
  String relations;
  String science_title;

  Scientist({
    required this.author_in_russian,
    required this.first_author,
    required this.job_title,
    required this.relations,
    required this.science_title,
  });

  factory Scientist.fromJson(Map<String, dynamic> json) {
    return Scientist(
      author_in_russian: json['author_in_russian'] ?? '',
      first_author: json['first_author'] ?? '',
      job_title: json['job_title'] ?? '',
      relations: json['relations'] ?? '',
      science_title: json['science_title'] ?? '',
    );
  }
}

Future<List<BibEntryuser>> fetchBibEntries() async {
  final response = await http.get(
      Uri.parse('$baseUrl/bibtex/checked/${username}/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'ngrok-skip-browser-warning': 'true'
      });

  if (response.statusCode == 200) {
    final decoResponse = utf8.decode(response.bodyBytes);
    List<dynamic> jsonList = json.decode(decoResponse);
    return jsonList.map((json) => BibEntryuser.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load bib entries');
  }
}

double calculateTotalPoints(List<Work> works) {
  return works.fold(0, (total, work) => total + work.ball);
}

Future<List<Work>> fetchWorks(String endpoint) async {
  final url = Uri.parse(endpoint);
  final response = await http.get(url, headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    'ngrok-skip-browser-warning': 'true'
  },);

  if (response.statusCode == 200) {
    List<dynamic> jsonList = json.decode(response.body);
    return jsonList.map((json) => Work.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load works from $endpoint');
  }
}

Future<Scientist?> fetchScientist(String username) async {
  final url = Uri.parse('$baseUrl/scientist/$username/');
  final response = await http.get(url, headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    'ngrok-skip-browser-warning': 'true'
  },);

  if (response.statusCode == 200) {
    final decodedResponse = utf8.decode(response.bodyBytes);
    return Scientist.fromJson(json.decode(decodedResponse));
  } else {
    return null;
  }
}

class CountPagef extends StatefulWidget {
  final String username;

  CountPagef({required this.username});

  @override
  _CountPageState createState() => _CountPageState();
}

class _CountPageState extends State<CountPagef> {
  late Future<List<Work>> futureCheckedWorks;
  late Future<List<Work>> futureUncheckedWorks;
  late Future<Scientist?> futureScientist;

  int checkedCount = 0;
  int uncheckedCount = 0;
  double fin = 0;
  double ball = points;
  Scientist? scientist;

  @override
  void initState() {
    super.initState();
    futureCheckedWorks = fetchWorks('$baseUrl/bibtex/checked/${username}/');
    futureUncheckedWorks = fetchWorks('$baseUrl/bibtex/unchecked/${username}/');
    futureScientist = fetchScientist(widget.username);

    Future.wait([futureCheckedWorks, futureUncheckedWorks, futureScientist])
        .then((results) {
      final List<Work> checkedWorks = results[0] as List<Work>;
      final List<Work> uncheckedWorks = results[1] as List<Work>;
      final Scientist? fetchedScientist = results[2] as Scientist?;

      setState(() {
        checkedCount = checkedWorks.length;
        uncheckedCount = uncheckedWorks.length;
        scientist = fetchedScientist;
        ball = calculateTotalPoints(checkedWorks);
        ball = double.parse(ball.toStringAsFixed(3));

        if (checkedCount + uncheckedCount > 0) {
          fin = (checkedCount / (checkedCount + uncheckedCount));
          print("Percentage of Unchecked Works: $fin%");
        } else {
          print("No works to calculate percentage.");
        }
      });
    }).catchError((error) {
      print("Error fetching data: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: Future.wait(
            [futureCheckedWorks, futureUncheckedWorks, futureScientist]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            if (snapshot.hasData) {
              final List<Work> checkedWorks = snapshot.data![0] as List<Work>;
              final List<Work> uncheckedWorks = snapshot.data![1] as List<Work>;
              final Scientist? fetchedScientist =
                  snapshot.data![2] as Scientist?;

              checkedCount = checkedWorks.length;
              uncheckedCount = uncheckedWorks.length;
              scientist = fetchedScientist;

              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.brown,
                            child: Icon(
                              Icons.person_outline_sharp,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                        padding: EdgeInsets.all(10),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (scientist != null)
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (scientist!
                                          .author_in_russian.isNotEmpty)
                                        Container(
                                          child: Text(
                                            ' ${scientist!.author_in_russian}',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 25,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      Row(
                                        children: [
                                          if (scientist!.job_title.isNotEmpty)
                                            Container(
                                                child: Row(children: [
                                              Text(
                                                scientist!.job_title,
                                                style: TextStyle(
                                                  color: Colors.blueGrey[400],
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ])),
                                          if (scientist!.relations.isNotEmpty)
                                            Container(
                                                child: Row(children: [
                                              Text(
                                                ', ${scientist!.relations}',
                                                style: TextStyle(
                                                  color: Colors.blueGrey[400],
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ])),
                                          if (scientist!
                                              .science_title.isNotEmpty)
                                            Container(
                                                child: Row(children: [
                                              Text(
                                                ', ${scientist!.science_title}',
                                                style: TextStyle(
                                                  color: Colors.blueGrey[400],
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ])),
                                        ],
                                      ),
                                    ]),
                            ])),
                    Container(
                      padding: EdgeInsets.only(top: 20),
                      child: Divider(
                        thickness: 1,
                        color: Colors.blueGrey[200],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          padding: EdgeInsets.only(top: 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                child: Text(
                                  '$ball',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20),
                                ),
                              ),
                              Container(
                                child: Text(
                                  'Начисленный балл',
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.blueGrey),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                child: Text(
                                  '$checkedCount',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20),
                                ),
                              ),
                              Container(
                                child: Text(
                                  'Работ проверено',
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.blueGrey),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                child: Text(
                                  '$uncheckedCount',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20),
                                ),
                              ),
                              Container(
                                child: Text(
                                  'Работ ожидают проверки',
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.blueGrey),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                child: Text(
                                  '${(checkedCount + uncheckedCount)}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20),
                                ),
                              ),
                              Container(
                                child: Text(
                                  'Загруженных работ',
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.blueGrey),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 20),
                      child: Divider(
                        thickness: 1,
                        color: Colors.blueGrey[200],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(top: 30),
                          child: Text(
                            'Прогресс',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.w900),
                          ),
                        ),
                        Container(
                          // padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    width: 150,
                                    height: 250,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          CircularPercentIndicator(
                                            radius: 100.0,
                                            lineWidth: 10.0,
                                            animation: true,
                                            percent: fin,
                                            center: SizedBox(
                                              height: 150.0,
                                              width: 90.0,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.check_circle_sharp,
                                                    size: 30.0,
                                                    color: Colors.brown,
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    "${(fin * 100).toInt()}%",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Проверено",
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            backgroundColor: Colors.white,
                                            progressColor: Colors.brown,
                                            circularStrokeCap:
                                                CircularStrokeCap.round,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            } else {
              return Center(child: Text("No data available"));
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
