import 'dart:convert';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Work {
  int id;
  String title;
  int checked;

  Work({required this.id, required this.title, required this.checked});

  factory Work.fromJson(Map<String, dynamic> json) {
    return Work(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      checked: json['checked'] ?? 0,
    );
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

Future<List<Work>> fetchWorks(String endpoint) async {
  final url = Uri.parse(endpoint);
  final response = await http.get(url);

  if (response.statusCode == 200) {
    List<dynamic> jsonList = json.decode(response.body);
    return jsonList.map((json) => Work.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load works from $endpoint');
  }
}

Future<Scientist> fetchScientist(String username) async {
  final url = Uri.parse('http://127.0.0.1:8000/scientist/$username/');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    return Scientist.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load scientist');
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
  late Future<Scientist> futureScientist;
  int checkedCount = 0;
  int uncheckedCount = 0;
  double fin = 0;
  Scientist? scientist;

  @override
  void initState() {
    super.initState();
    futureCheckedWorks = fetchWorks('http://127.0.0.1:8000/bibtex/checked/f/');
    futureUncheckedWorks = fetchWorks('http://127.0.0.1:8000/bibtex/unchecked/f/');
    futureScientist = fetchScientist(widget.username);

    Future.wait([futureCheckedWorks, futureUncheckedWorks, futureScientist]).then((results) {
      final List<Work> checkedWorks = results[0] as List<Work>;
      final List<Work> uncheckedWorks = results[1] as List<Work>;
      final Scientist fetchedScientist = results[2] as Scientist;

      setState(() {
        checkedCount = checkedWorks.length;
        uncheckedCount = uncheckedWorks.length;
        scientist = fetchedScientist;

        // Ensure that we are not dividing by zero
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
        future: Future.wait([futureCheckedWorks, futureUncheckedWorks, futureScientist]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            if (snapshot.hasData) {
              final List<Work> checkedWorks = snapshot.data![0] as List<Work>;
              final List<Work> uncheckedWorks = snapshot.data![1] as List<Work>;
              final Scientist fetchedScientist = snapshot.data![2] as Scientist;

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
                            radius: 40, // Adjust the size as needed
                            backgroundColor: Colors.brown, // Specify the background color of the CircleAvatar
                            child: Icon(
                              Icons.person_outline_sharp,
                              size: 30, // Adjust the size of the icon as needed
                              color: Colors.white, // Choose an appropriate color for the icon
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: Text(
                                    '${widget.username}',
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    scientist?.job_title ?? '',
                                    style: TextStyle(
                                      color: Colors.blueGrey[400],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Container(
                                  child: Text(
                                    'Author in Russian: ${scientist?.author_in_russian ?? ''}',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    'First Author: ${scientist?.first_author ?? ''}',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    'Relations: ${scientist?.relations ?? ''}',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    'Science Title: ${scientist?.science_title ?? ''}',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          Row(
                            children: [
                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(width: 1, color: Colors.brown),
                                ),
                                child: Center(
                                  child: Icon(Icons.message, color: Colors.brown[400]),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
                                  '$checkedCount',
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                                ),
                              ),
                              Container(
                                child: Text(
                                  'Работ проверено',
                                  style: TextStyle(fontSize: 15, color: Colors.blueGrey),
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
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                                ),
                              ),
                              Container(
                                child: Text(
                                  'Работ ожидают проверки',
                                  style: TextStyle(fontSize: 15, color: Colors.blueGrey),
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
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                                ),
                              ),
                              Container(
                                child: Text(
                                  'Загруженных работ',
                                  style: TextStyle(fontSize: 15, color: Colors.blueGrey),
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
                            style: TextStyle(fontSize: 20, color: Colors.blueGrey, fontWeight: FontWeight.w900),
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
                                    width: 150, // Consider increasing this if more space is needed
                                    height: 250, // Increased height to accommodate internal content
                                    child: SingleChildScrollView( // Makes the column scrollable
                                      child: Column(
                                        children: [
                                          CircularPercentIndicator(
                                            radius: 100.0,
                                            lineWidth: 10.0,
                                            animation: true,
                                            percent: fin, // Example percent, ensure 'fin' is calculated correctly
                                            center: SizedBox(
                                              height: 150.0,
                                              width: 90.0,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.check_circle_sharp,
                                                    size: 30.0, // Reduced icon size
                                                    color: Colors.brown,
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    "${(fin * 100).toInt()}%",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Проверено",
                                                    style: TextStyle(fontSize: 12), // Ensure textStyle fits within the available space
                                                  ),
                                                ],
                                              ),
                                            ),
                                            backgroundColor: Colors.white,
                                            progressColor: Colors.brown,
                                            circularStrokeCap: CircularStrokeCap.round,
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