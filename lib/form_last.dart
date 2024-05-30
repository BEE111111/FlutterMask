import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:untitled/log.dart';

import 'main.dart';
import 'menu.dart';

class BibEntry {
  int id;
  String doi;
  String url;
  int year;
  String month;
  String publisher;
  int volume;
  String pages;
  String author;
  String title;
  String journal;
  String author_in_russian;
  String first_author;
  String organization;
  String subdivision;
  String relations;
  String other_authors;
  String number_of_authors;
  String booktitle;
  String quartile;
  int number_of_affiliation;
  String number_of_theme;
  String gratitude;
  String username;
  String number;
  String issn;
  double index;
  String type;
  String note;
  String isbn;
  String language;
  double ball;

  BibEntry(
      {required this.id,
      required this.doi,
      required this.url,
      required this.year,
      required this.month,
      required this.publisher,
      required this.volume,
      required this.pages,
      required this.author,
      required this.title,
      required this.journal,
      required this.username,
      required this.author_in_russian,
      required this.first_author,
      required this.organization,
      required this.subdivision,
      required this.relations,
      required this.other_authors,
      required this.number_of_authors,
      required this.booktitle,
      required this.quartile,
      required this.number_of_affiliation,
      required this.number_of_theme,
      required this.gratitude,
      required this.number,
      required this.issn,
      required this.index,
      required this.type,
      required this.note,
      required this.isbn,
      required this.language,
      required this.ball});

  factory BibEntry.fromJson(Map<String, dynamic> json) {
    return BibEntry(
        id: json['id'] ?? 0,
        doi: json['doi'] ?? '',
        url: json['url'] ?? '',
        year: json['year'] ?? 0,
        month: json['month'] ?? '',
        publisher: json['publisher'] ?? '',
        volume: json['volume'] ?? 0,
        pages: json['pages'] ?? '',
        author: json['author'] ?? '',
        title: json['title'] ?? '',
        journal: json['journal'] ?? '',
        username: json['username'] ?? '',
        author_in_russian: json['author_in_russian'] ?? '',
        first_author: json['first_author'] ?? '',
        organization: json['organization'] ?? '',
        subdivision: json['subdivision'] ?? '',
        relations: json['relations'] ?? '',
        other_authors: json['other_authors'] ?? '',
        number_of_authors: json['number_of_authors'] ?? '',
        booktitle: json['booktitle'] ?? '',
        quartile: json['quartile'] ?? '',
        number_of_affiliation: json['number_of_affiliation'] ?? 0,
        number_of_theme: json['number_of_theme'] ?? '',
        gratitude: json['gratitude'] ?? '',
        number: json['number'] ?? '',
        issn: json['issn'] ?? '',
        index: (json['index'] != null)
            ? double.tryParse(json['index'].toString()) ?? 0.0
            : 0.0,
        type: json['type'] ?? '',
        note: json['note'] ?? '',
        isbn: json['isbn'] ?? '',
        language: json['language'] ?? '',
        ball: (json['ball'] != null)
            ? double.tryParse(json['ball'].toString()) ?? 0.0
            : 0.0);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doi': doi,
      'url': url,
      'year': year,
      'month': month,
      'publisher': publisher,
      'volume': volume,
      'pages': pages,
      'author': author,
      'title': title,
      'journal': journal,
      'author_in_russian': author_in_russian,
      'first_author': first_author,
      'organization': organization,
      'subdivision': subdivision,
      'relations': relations,
      'other_authors': other_authors,
      'number_of_authors': number_of_authors,
      'booktitle': booktitle,
      'quartile': quartile,
      'number_of_affiliation': number_of_affiliation,
      'number_of_theme': number_of_theme,
      'gratitude': gratitude,
      'number': number,
      'issn': issn,
      'index': index,
      'type': type,
      'isbn': isbn,
      'note': note,
      'language': language,
      'ball': ball
    };
  }
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

Future<Scientist?> fetchScientist(String username) async {
  final url = Uri.parse('$baseUrl/scientist/$username/');
  final response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'ngrok-skip-browser-warning': 'true'
    },
  );

  if (response.statusCode == 200) {
    final decodedResponse = utf8.decode(response.bodyBytes);
    return Scientist.fromJson(json.decode(decodedResponse));
  } else {
    return null;
  }
}

Future<BibEntry> fetchBibEntry(String entryId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/bibtex/doi/${entryId}/user/$username/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'ngrok-skip-browser-warning': 'true'
    },
  );
  if (response.statusCode == 200) {
    final decodeResponse = utf8.decode(response.bodyBytes);
    Map<String, dynamic> jsonMap = json.decode(decodeResponse);
    return BibEntry.fromJson(jsonMap);
  } else {
    throw Exception(
        'Failed to load entry. Status code: ${response.statusCode}');
  }
}

Future<void> saveBibEntry(
    BuildContext context, BibEntry entry, String id_) async {
  final response = await http.patch(
    Uri.parse('$baseUrl/bibtex/check/${id_}/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'ngrok-skip-browser-warning': 'true'
    },
    body: json.encode(entry.toJson()),
  );

  if (response.statusCode == 200) {
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
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Menu()));
              },
            ),
          ],
        );
      },
    );
    print('Entry saved successfully');
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
    print('Failed to save entry with status: ${response.statusCode}');
    print('Response body: ${response.body}');
  }
}

int countAuthors(String author) {
  return author.split(' and ').length;
}

String getFirstAuthor(String author) {
  var authorsList = author.split(' and ');
  return authorsList.isNotEmpty ? authorsList.first : '';
}

String getOtherAuthor(String author, String firstAuthor) {
  var authorsList = author.split(' and ');
  authorsList.remove(firstAuthor);
  return authorsList.join(' and ');
}

double calculateBalls(double index, String language, String type, String note,
    String number_of_authors, String isbn, String pages) {
  double balls = 0;
  if (type.isNotEmpty) {
    if (type == 'journal') {
      if (index != 0) {
        double indexValue = index;
        if ((indexValue! >= 0.27 && language == 'Foreign') ||
            (indexValue >= 0.133 && language == 'Russian')) {
          if (language == 'Russian') {
            balls = (indexValue * 60);
          } else if (language == 'Foreign') {
            balls = (indexValue * 30);
          }
        } else if ((indexValue < 0.27 && language == 'Foreign') ||
            (indexValue < 0.133 && language == 'Russian')) {
          balls = 8;
        }
      } else {
        balls = 8;
      }
    } else if (type == 'preprint') {
      balls = 3;
    } else {
      balls = 0;
    }
    if (note == 'experiment') {
      balls = balls * 1.5;
    }
    if (number_of_authors.isNotEmpty) {
      int numAuthors = int.tryParse(number_of_authors) ?? 0;
      if (numAuthors >= 1 && numAuthors <= 5) {
        balls = (balls / numAuthors);
      } else if (numAuthors >= 6 && numAuthors <= 9) {
        balls = (balls * 0.2);
      } else if (numAuthors >= 10 && numAuthors <= 49) {
        balls = (balls * 0.1);
      } else if (numAuthors >= 50 && numAuthors <= 99) {
        balls = (balls * 0.075);
      } else if (numAuthors >= 100 && numAuthors <= 199) {
        balls = (balls * 0.06);
      } else if (numAuthors >= 200 && numAuthors <= 499) {
        balls = (balls * 0.04);
      } else if (numAuthors >= 500 && numAuthors <= 999) {
        balls = (balls * 0.02);
      } else if (numAuthors >= 1000 && numAuthors <= 1999) {
        balls = (balls * 0.01);
      } else if (numAuthors >= 2000) {
        balls = (balls * 0.007);
      }
    } else {
      balls = 0;
    }
    ;
    if ((type == 'monograph' && isbn.isNotEmpty) || (type == 'textbook')) {
      if (pages.isNotEmpty) {
        int page = int.tryParse(pages) ?? 0;
        int soauthors = int.tryParse(number_of_authors) ?? 0;
        balls = page * 2;
        if (soauthors != 0) {
          balls = balls / soauthors;
        }
      }
    }
  }
  balls = double.parse(balls.toStringAsFixed(3));
  return balls;
}

class BibEntryEditPage1 extends StatefulWidget {
  final String entryId;
  final String id_;
  final String username;

  const BibEntryEditPage1(
      {Key? key,
      required this.entryId,
      required this.id_,
      required this.username})
      : super(key: key);

  @override
  _BibEntryEditPageState createState() => _BibEntryEditPageState();
}

class _BibEntryEditPageState extends State<BibEntryEditPage1> {
  String? _selectedQuartile;
  final List<String> _quartiles = ['Q1', 'Q2', 'Q3', 'Q4'];
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _authorController;
  late TextEditingController _monthController;
  late TextEditingController _doiController;
  late TextEditingController _urlController;
  late TextEditingController _publisherController;
  late TextEditingController _titleController;
  late TextEditingController _journalController;
  late TextEditingController _pagesController;
  late TextEditingController _yearController;
  late TextEditingController _volumeController;
  late TextEditingController _authorinrussianController;
  late TextEditingController _first_authorController;
  late TextEditingController _organisationController;
  late TextEditingController _subdivisionController;
  late TextEditingController _relationsController;
  late TextEditingController _other_authorsController;
  late TextEditingController _number_of_authorsController;
  late TextEditingController _booktitleController;
  late TextEditingController _quartileController;
  late TextEditingController _number_of_affiliationsController;
  late TextEditingController _number_of_themeController;
  late TextEditingController _gratitudeController;
  late TextEditingController _numberController;
  late TextEditingController _issnController;
  late TextEditingController _indexController;
  late TextEditingController _typeController;
  late TextEditingController _isbnController;
  late TextEditingController _languageController;
  late TextEditingController _noteController;
  late TextEditingController _ballController;

  late BibEntry _currentEntry;
  Scientist? scientist;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _authorController = TextEditingController();
    _monthController = TextEditingController();
    _doiController = TextEditingController();
    _urlController = TextEditingController();
    _publisherController = TextEditingController();
    _titleController = TextEditingController();
    _journalController = TextEditingController();
    _pagesController = TextEditingController();
    _yearController = TextEditingController();
    _volumeController = TextEditingController();
    _authorinrussianController = TextEditingController();
    _first_authorController = TextEditingController();
    _organisationController = TextEditingController();
    _subdivisionController = TextEditingController();
    _relationsController = TextEditingController();
    _other_authorsController = TextEditingController();
    _number_of_authorsController = TextEditingController();
    _booktitleController = TextEditingController();
    _quartileController = TextEditingController();
    _number_of_affiliationsController = TextEditingController();
    _number_of_themeController = TextEditingController();
    _gratitudeController = TextEditingController();
    _numberController = TextEditingController();
    _issnController = TextEditingController();
    _indexController = TextEditingController();
    _typeController = TextEditingController();
    _isbnController = TextEditingController();
    _noteController = TextEditingController();
    _languageController = TextEditingController();
    _ballController = TextEditingController();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final bibEntryFuture = fetchBibEntry(widget.entryId);
      final scientistFuture = fetchScientist(widget.username);

      final results = await Future.wait([bibEntryFuture, scientistFuture]);
      final BibEntry entry = results[0] as BibEntry;
      final Scientist? scientist = results[1] as Scientist?;

      if (mounted) {
        setState(() {
          _currentEntry = entry;
          this.scientist = scientist;
          _authorController.text = _currentEntry.author;
          _monthController.text = _currentEntry.month;
          _doiController.text = _currentEntry.doi;
          _urlController.text = _currentEntry.url;
          _publisherController.text = _currentEntry.publisher;
          _titleController.text = _currentEntry.title;
          _journalController.text = _currentEntry.journal;
          _yearController.text = _currentEntry.year.toString();
          _volumeController.text = _currentEntry.volume.toString();
          _pagesController.text = _currentEntry.pages.toString();
          _authorinrussianController.text =
              scientist?.author_in_russian ?? _currentEntry.author_in_russian;
          _first_authorController.text =
              scientist?.first_author ?? getFirstAuthor(_authorController.text);
          _organisationController.text = _currentEntry.organization;
          _subdivisionController.text = _currentEntry.subdivision;
          _relationsController.text =
              scientist?.relations ?? _currentEntry.relations;
          print("Scientist relations: ${scientist?.relations}");
          print("Current entry relations: ${_currentEntry.relations}");
          _other_authorsController.text = getOtherAuthor(
              _authorController.text, _first_authorController.text);
          _number_of_authorsController.text =
              countAuthors(_authorController.text).toString();
          _booktitleController.text = _currentEntry.booktitle;
          _quartileController.text = _currentEntry.quartile;
          _number_of_affiliationsController.text =
              _currentEntry.number_of_affiliation.toString();
          _number_of_themeController.text = _currentEntry.number_of_theme;
          _gratitudeController.text = _currentEntry.gratitude;
          _numberController.text = _currentEntry.number;
          _issnController.text = _currentEntry.issn;
          _indexController.text = _currentEntry.index.toString();
          _typeController.text = _currentEntry.type;
          _noteController.text = _currentEntry.note;
          _languageController.text = _currentEntry.language;
          _isbnController.text = _currentEntry.isbn;
          _ballController.text = _currentEntry.ball.toString();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading entry: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Форма проверки',
            style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontFamily: "Raleway",
                fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.brown[300],
          toolbarHeight: 100,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.brown[300],
      appBar: AppBar(
        title: const Text(
          'Форма проверки',
          style: TextStyle(
              fontSize: 32,
              color: Colors.white,
              fontFamily: "Raleway",
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.brown[300],
        toolbarHeight: 100,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
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
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.all(8.0),
                  children: [
                    TextFormField(
                      controller: _authorController,
                      decoration: InputDecoration(
                        labelText: 'Авторы',
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.brown, width: 1.5),
                        ),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      validator: (value) {
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _first_authorController,
                      decoration: InputDecoration(
                        labelText: 'ФИО первого автора на английском',
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.brown, width: 1.5),
                        ),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      validator: (value) {
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _authorinrussianController,
                      decoration: InputDecoration(
                        labelText: 'ФИО первого автора на русском',
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.brown, width: 1.5),
                        ),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      validator: (value) {
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _doiController,
                      decoration: InputDecoration(
                        labelText: 'DOI',
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.brown, width: 1.5),
                        ),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter the doi';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        labelText: 'URL',
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.brown, width: 1.5),
                        ),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter the url';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _organisationController,
                      decoration: InputDecoration(
                        labelText: 'Организации',
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.brown, width: 1.5),
                        ),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      validator: (value) {
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _subdivisionController,
                      decoration: InputDecoration(
                        labelText: 'Подразделение',
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.brown, width: 1.5),
                        ),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      validator: (value) {
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _relationsController,
                      decoration: InputDecoration(
                        labelText: 'Тип трудовых отношений',
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.brown, width: 1.5),
                        ),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      validator: (value) {
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _other_authorsController,
                      decoration: InputDecoration(
                        labelText: 'Соавторы статьи',
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.brown, width: 1.5),
                        ),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      validator: (value) {
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _number_of_authorsController,
                      decoration: InputDecoration(
                        labelText: 'Количество соавторов',
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.brown, width: 1.5),
                        ),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      validator: (value) {
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Название статьи',
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.brown, width: 1.5),
                        ),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      validator: (value) {
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _publisherController,
                      decoration: InputDecoration(
                        labelText: 'Издательство',
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.brown, width: 1.5),
                        ),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      validator: (value) {
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _journalController,
                      decoration: InputDecoration(
                        labelText: 'Наименование журнала',
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.brown, width: 1.5),
                        ),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      validator: (value) {
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _booktitleController,
                      decoration: InputDecoration(
                        labelText: 'Наименование книги',
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.brown, width: 1.5),
                        ),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      validator: (value) {
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _issnController,
                      decoration: InputDecoration(
                        labelText: 'ISSN',
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.brown, width: 1.5),
                        ),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      validator: (value) {
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _isbnController,
                      decoration: InputDecoration(
                        labelText: 'ISBN',
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.brown, width: 1.5),
                        ),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      validator: (value) {
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _indexController,
                      decoration: InputDecoration(
                        labelText: 'Индекс',
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.brown, width: 1.5),
                        ),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      validator: (value) {
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _typeController,
                      decoration: InputDecoration(
                        labelText: 'Тип',
                        hintText:
                            '(Указать тип journal/textbook/preprint/monograph для подсчета баллов)',
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.brown, width: 1.5),
                        ),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                        hintStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      validator: (value) {
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _volumeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Том',
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.brown, width: 1.5),
                        ),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      validator: (value) {
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _numberController,
                      decoration: InputDecoration(
                        labelText: 'Номер выхода журнала',
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.brown, width: 1.5),
                        ),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      validator: (value) {
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _pagesController,
                      decoration: InputDecoration(
                        labelText: 'Страницы статьи',
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.brown, width: 1.5),
                        ),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      validator: (value) {
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Год',
                        focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.brown, width: 1.5)),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      validator: (value) {
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _monthController,
                      decoration: InputDecoration(
                        labelText: 'Месяц',
                        focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.brown, width: 1.5)),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      validator: (value) {
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _gratitudeController,
                      decoration: InputDecoration(
                        labelText: 'Благодарности',
                        focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.brown, width: 1.5)),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      validator: (value) {
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _languageController,
                      decoration: InputDecoration(
                        labelText: 'Российский/зарубежный журнал',
                        hintText: '(Указать Russian/Foreign)',
                        focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.brown, width: 1.5)),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                        hintStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      validator: (value) {
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        labelText:
                            'Для работ, в которых опубликованы результаты экспериментов, выполненных в России',
                        hintText: 'Указать experiment',
                        focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.brown, width: 1.5)),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                        hintStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      validator: (value) {
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _number_of_affiliationsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Количество аффиляций автора статьи',
                        focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.brown, width: 1.5)),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      validator: (value) {
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _number_of_themeController,
                      decoration: InputDecoration(
                        labelText: 'Номер темы ГЗ',
                        focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.brown, width: 1.5)),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      validator: (value) {
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedQuartile,
                      decoration: InputDecoration(
                        labelText: 'Квартиль',
                        focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.brown, width: 1.5)),
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedQuartile = newValue;
                        });
                      },
                      validator: (String? value) {
                        return null;
                      },
                      items: _quartiles
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 40),
                    Container(
                      width: 50,
                      child: Container(
                        width: 50,
                        child: MaterialButton(
                          height: 45,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          color: Colors.brown,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _currentEntry.author = _authorController.text;
                              _currentEntry.month = _monthController.text;
                              _currentEntry.doi = _doiController.text;
                              _currentEntry.url = _urlController.text;
                              _currentEntry.publisher =
                                  _publisherController.text;
                              _currentEntry.title = _titleController.text;
                              _currentEntry.journal = _journalController.text;
                              _currentEntry.pages = _pagesController.text;
                              _currentEntry.volume =
                                  int.tryParse(_volumeController.text) ?? 0;
                              _currentEntry.year =
                                  int.tryParse(_yearController.text) ?? 0;
                              _currentEntry.author_in_russian =
                                  _authorinrussianController.text;
                              _currentEntry.first_author =
                                  _first_authorController.text;
                              _currentEntry.organization =
                                  _organisationController.text;
                              _currentEntry.subdivision =
                                  _subdivisionController.text;
                              _currentEntry.relations =
                                  _relationsController.text;
                              _currentEntry.other_authors =
                                  _other_authorsController.text;
                              _currentEntry.number_of_authors =
                                  _number_of_authorsController.text;
                              _currentEntry.booktitle =
                                  _booktitleController.text;
                              _currentEntry.quartile = _selectedQuartile ?? '';
                              _currentEntry.issn = _issnController.text;
                              _currentEntry
                                  .number_of_affiliation = int.tryParse(
                                      _number_of_affiliationsController.text) ??
                                  0;
                              _currentEntry.number_of_theme =
                                  _number_of_themeController.text;
                              _currentEntry.gratitude =
                                  _gratitudeController.text;
                              _currentEntry.number = _numberController.text;
                              _currentEntry.index =
                                  double.tryParse(_indexController.text) ?? 0;
                              _currentEntry.type = _typeController.text;
                              _currentEntry.language = _languageController.text;
                              _currentEntry.isbn = _isbnController.text;
                              _currentEntry.note = _noteController.text;
                              double p = calculateBalls(
                                  _currentEntry.index,
                                  _currentEntry.language,
                                  _currentEntry.type,
                                  _currentEntry.note,
                                  _currentEntry.number_of_authors,
                                  _currentEntry.isbn,
                                  _currentEntry.pages);
                              _currentEntry.ball = p;
                              try {
                                await saveBibEntry(
                                    context, _currentEntry, widget.id_);
                              } catch (e) {
                                print(e);
                              }
                            }
                          },
                          child: Text(
                            'Сохранить',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _authorController.dispose();
    _monthController.dispose();
    _doiController.dispose();
    _urlController.dispose();
    _publisherController.dispose();
    _titleController.dispose();
    _journalController.dispose();
    _pagesController.dispose();
    _yearController.dispose();
    _volumeController.dispose();
    _authorinrussianController.dispose();
    _first_authorController.dispose();
    _organisationController.dispose();
    _subdivisionController.dispose();
    _relationsController.dispose();
    _other_authorsController.dispose();
    _number_of_authorsController.dispose();
    _booktitleController.dispose();
    _quartileController.dispose();
    _number_of_affiliationsController.dispose();
    _number_of_themeController.dispose();
    _gratitudeController.dispose();
    _numberController.dispose();
    _issnController.dispose();
    _indexController.dispose();
    _typeController.dispose();
    _noteController.dispose();
    _languageController.dispose();
    _isbnController.dispose();
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(
      home: BibEntryEditPage1(
    entryId: 'some_entry_id',
    id_: 'some_id',
    username: username,
  )));
}
