import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'log.dart';
import 'main.dart';

double points = 0;

class BibEntryuser {
  final int id;
  final String doi;
  final String url;
  final int year;
  final String month;
  final String publisher;
  final int volume;
  final String pages;
  final String author;
  final String author_in_russian;
  final String first_author;
  final String organization;
  final String subdivision;
  final String relations;
  final String other_authors;
  final String number_of_authors;
  final String booktitle;
  final String quartile;
  final int number_of_affiliation;
  final String number_of_theme;
  final String gratitude;
  final String title;
  final String journal;
  final String number;
  final String issn;
  final double index;
  final String type;
  final String note;
  final String isbn;
  final String language;
  final double ball;

  BibEntryuser(
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
      //required this.username,
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
      required this.type,
      required this.index,
      required this.note,
      required this.isbn,
      required this.language,
      required this.ball});

  factory BibEntryuser.fromJson(Map<String, dynamic> json) {
    return BibEntryuser(
      author: json['author'] ?? '',
      id: json['id'] ?? 0,
      doi: json['doi'] ?? '',
      url: json['url'] ?? '',
      year: json['year'] ?? 0,
      month: json['month'] ?? '',
      publisher: json['publisher'] ?? '',
      volume: json['volume'] ?? 0,
      pages: json['pages'] ?? '',
      title: json['title'] ?? '',
      journal: json['journal'] ?? '',
      //username: json['username'] ?? '',
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
          : 0.0,
    );
  }
}

Future<List<BibEntryuser>> fetchBibEntries() async {
  final response = await http.get(
    Uri.parse('$baseUrl/bibtex/checked/$username/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'ngrok-skip-browser-warning': 'true'
    },
  );

  if (response.statusCode == 200) {
    final decoResponse = utf8.decode(response.bodyBytes);
    List<dynamic> jsonList = json.decode(decoResponse);
    return jsonList.map((json) => BibEntryuser.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load bib entries');
  }
}

class Myworks extends StatefulWidget {
  @override
  _MyworksState createState() => _MyworksState();
}

class _MyworksState extends State<Myworks> {
  late Future<List<BibEntryuser>> futureBibEntries;
  late List<BibEntryuser> _allEntries;
  List<BibEntryuser> _filteredEntries = [];
  TextEditingController _searchController = TextEditingController();
  bool sortAscending = true;
  int sortColumnIndex = 0;
  int ball = 0;
  final ScrollController _horizontal = ScrollController();
  final ScrollController _vertical = ScrollController();


  @override
  void initState() {
    super.initState();
    futureBibEntries = fetchBibEntries();
    futureBibEntries.then((entries) {
      _allEntries = entries;
      _filteredEntries = List.from(_allEntries);
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _filteredEntries = _searchController.text.isEmpty
          ? List.from(_allEntries)
          : _allEntries.where((entry) {
              String searchText = _searchController.text.toLowerCase();
              return entry.title.toLowerCase().contains(searchText) ||
                  entry.author.toLowerCase().contains(searchText) ||
                  entry.journal.toLowerCase().contains(searchText) ||
                  entry.year.toString().contains(searchText) ||
                  entry.booktitle.toLowerCase().contains(searchText) ||
                  entry.author_in_russian.toLowerCase().contains(searchText) ||
                  entry.first_author.toLowerCase().contains(searchText) ||
                  entry.publisher.toLowerCase().contains(searchText);
            }).toList();
    });
  }

  void onSortColum(int columnIndex, bool ascending) {
    setState(() {
      sortColumnIndex = columnIndex;
      sortAscending = ascending;
      switch (columnIndex) {
        case 0:
          _filteredEntries.sort((a, b) =>
              ascending ? a.doi.compareTo(b.doi) : b.doi.compareTo(a.doi));
          break;
        case 1:
          _filteredEntries.sort((a, b) =>
              ascending ? a.url.compareTo(b.url) : b.url.compareTo(a.url));
          break;
        case 2:
          _filteredEntries.sort((a, b) {
            int numA = a.year;
            int numB = b.year;
            return ascending ? numA.compareTo(numB) : numB.compareTo(numA);
          });
          //_filteredEntries.sort((a, b) => ascending ? a.year.compareTo(b.year) : b.year.compareTo(a.year));
          break;
        case 3:
          _filteredEntries.sort((a, b) {
            return ascending
                ? a.month.toLowerCase().compareTo(b.month.toLowerCase())
                : b.month.toLowerCase().compareTo(a.month.toLowerCase());
          });
          //_filteredEntries.sort((a, b) => ascending ? a.month.compareTo(b.month) : b.month.compareTo(a.month));
          break;
        case 4:
          _filteredEntries.sort((a, b) {
            return ascending
                ? a.publisher.toLowerCase().compareTo(b.publisher.toLowerCase())
                : b.publisher
                    .toLowerCase()
                    .compareTo(a.publisher.toLowerCase());
          });
          //_filteredEntries.sort((a, b) => ascending ? a.publisher.compareTo(b.publisher) : b.publisher.compareTo(a.publisher));
          break;
        case 5:
          _filteredEntries.sort((a, b) {
            int numA = a.volume;
            int numB = b.volume;
            return ascending ? numA.compareTo(numB) : numB.compareTo(numA);
          });
          //_filteredEntries.sort((a, b) => ascending ? a.volume.compareTo(b.volume) : b.volume.compareTo(a.volume));
          break;
        case 6:
          _filteredEntries.sort((a, b) => ascending
              ? a.pages.compareTo(b.pages)
              : b.pages.compareTo(a.pages));
          break;
        case 7:
          _filteredEntries.sort((a, b) {
            return ascending
                ? a.author.toLowerCase().compareTo(b.author.toLowerCase())
                : b.author.toLowerCase().compareTo(a.author.toLowerCase());
          });
          //_filteredEntries.sort((a, b) => ascending ? a.author.compareTo(b.author) : b.author.compareTo(a.author));
          break;
        case 8:
          _filteredEntries.sort((a, b) {
            return ascending
                ? a.title.toLowerCase().compareTo(b.title.toLowerCase())
                : b.title.toLowerCase().compareTo(a.title.toLowerCase());
          });
          //_filteredEntries.sort((a, b) => ascending ? a.title.compareTo(b.title) : b.title.compareTo(a.title));
          break;
        case 9:
          _filteredEntries.sort((a, b) {
            return ascending
                ? a.journal.toLowerCase().compareTo(b.journal.toLowerCase())
                : b.journal.toLowerCase().compareTo(a.journal.toLowerCase());
          });
          //_filteredEntries.sort((a, b) => ascending ? a.journal.compareTo(b.journal) : b.journal.compareTo(a.journal));
          break;
        case 10:
          _filteredEntries.sort((a, b) {
            return ascending
                ? a.first_author
                    .toLowerCase()
                    .compareTo(b.first_author.toLowerCase())
                : b.first_author
                    .toLowerCase()
                    .compareTo(a.first_author.toLowerCase());
          });
          //_filteredEntries.sort((a, b) => ascending ? a.first_author.compareTo(b.first_author) : b.first_author.compareTo(a.first_author));
          break;
        case 11:
          _filteredEntries.sort((a, b) {
            return ascending
                ? a.author_in_russian
                    .toLowerCase()
                    .compareTo(b.author_in_russian.toLowerCase())
                : b.author_in_russian
                    .toLowerCase()
                    .compareTo(a.author_in_russian.toLowerCase());
          });
          //_filteredEntries.sort((a, b) => ascending ? a.author_in_russian.compareTo(b.author_in_russian) : b.author_in_russian.compareTo(a.author_in_russian));
          break;
        case 12:
          _filteredEntries.sort((a, b) {
            return ascending
                ? a.organization
                    .toLowerCase()
                    .compareTo(b.organization.toLowerCase())
                : b.organization
                    .toLowerCase()
                    .compareTo(a.organization.toLowerCase());
          });
          //_filteredEntries.sort((a, b) => ascending ? a.organization.compareTo(b.organization) : b.organization.compareTo(a.organization));
          break;
        case 13:
          _filteredEntries.sort((a, b) {
            return ascending
                ? a.subdivision
                    .toLowerCase()
                    .compareTo(b.subdivision.toLowerCase())
                : b.subdivision
                    .toLowerCase()
                    .compareTo(a.subdivision.toLowerCase());
          });
          //_filteredEntries.sort((a, b) => ascending ? a.subdivision.compareTo(b.subdivision) : b.subdivision.compareTo(a.subdivision));
          break;
        case 14:
          _filteredEntries.sort((a, b) {
            return ascending
                ? a.relations.toLowerCase().compareTo(b.relations.toLowerCase())
                : b.relations
                    .toLowerCase()
                    .compareTo(a.relations.toLowerCase());
          });
          //_filteredEntries.sort((a, b) => ascending ? a.relations.compareTo(b.relations) : b.relations.compareTo(a.relations));
          break;
        case 15:
          _filteredEntries.sort((a, b) {
            return ascending
                ? a.other_authors
                    .toLowerCase()
                    .compareTo(b.other_authors.toLowerCase())
                : b.other_authors
                    .toLowerCase()
                    .compareTo(a.other_authors.toLowerCase());
          });
          //_filteredEntries.sort((a, b) => ascending ? a.other_authors.compareTo(b.other_authors) : b.other_authors.compareTo(a.other_authors));
          break;
        case 16:
          _filteredEntries.sort((a, b) {
            int numA = int.tryParse(a.number_of_authors) ?? 0;
            int numB = int.tryParse(b.number_of_authors) ?? 0;
            return ascending ? numA.compareTo(numB) : numB.compareTo(numA);
          });
          //_filteredEntries.sort((a, b) => ascending ? a.number_of_authors.compareTo(b.number_of_authors) : b.number_of_authors.compareTo(a.number_of_authors));
          break;
        case 17:
          _filteredEntries.sort((a, b) {
            return ascending
                ? a.booktitle.toLowerCase().compareTo(b.booktitle.toLowerCase())
                : b.booktitle
                    .toLowerCase()
                    .compareTo(a.booktitle.toLowerCase());
          });
          //_filteredEntries.sort((a, b) => ascending ? a.booktitle.compareTo(b.booktitle) : b.booktitle.compareTo(a.booktitle));
          break;
        case 18:
          _filteredEntries.sort((a, b) => ascending
              ? a.quartile.compareTo(b.quartile)
              : b.quartile.compareTo(a.quartile));
          break;
        case 19:
          _filteredEntries.sort((a, b) =>
              ascending ? a.issn.compareTo(b.issn) : b.issn.compareTo(a.issn));
          break;
        case 20:
          _filteredEntries.sort((a, b) =>
          ascending ? a.isbn.compareTo(b.isbn) : b.isbn.compareTo(a.isbn));
          break;
        case 21:
          //_filteredEntries.sort((a, b) => ascending ? a.number.compareTo(b.number) : b.number.compareTo(a.number));
          _filteredEntries.sort((a, b) {
            int numA = int.tryParse(a.number) ?? 0;
            int numB = int.tryParse(b.number) ?? 0;
            return ascending ? numA.compareTo(numB) : numB.compareTo(numA);
          });
          break;
        case 22:
          _filteredEntries.sort((a, b) =>
          ascending ? a.type.toLowerCase().compareTo(b.type.toLowerCase()) : b.type.toLowerCase().compareTo(a.type.toLowerCase()));
          break;
        case 23:
          _filteredEntries.sort((a, b) =>
          ascending ? a.language.toLowerCase().compareTo(b.language.toLowerCase()) : b.language.toLowerCase().compareTo(a.language.toLowerCase()));
          break;
        case 24:
          _filteredEntries.sort((a, b) =>
          ascending ? a.note.toLowerCase().compareTo(b.note.toLowerCase()) : b.note.toLowerCase().compareTo(a.note.toLowerCase()));
          break;
        case 25:
          _filteredEntries.sort((a, b) {
            double numA = double.tryParse(a.index.toString()) ?? 0;
            double numB = double.tryParse(b.index.toString() ) ?? 0;
            return ascending ? numA.compareTo(numB) : numB.compareTo(numA);
          });
          break;
        case 26:
          _filteredEntries.sort((a, b) {
            return ascending
                ? a.gratitude.toLowerCase().compareTo(b.gratitude.toLowerCase())
                : b.gratitude
                    .toLowerCase()
                    .compareTo(a.gratitude.toLowerCase());
          });
          break;
        case 27:
          _filteredEntries.sort((a, b) {
            int numA = a.number_of_affiliation;
            int numB = b.number_of_affiliation;
            return ascending ? numA.compareTo(numB) : numB.compareTo(numA);
          });
          //_filteredEntries.sort((a, b) => ascending ? a.number_of_affiliation.compareTo(b.number_of_affiliation) : b.number_of_affiliation.compareTo(a.number_of_affiliation));
          break;
        case 28:
          _filteredEntries.sort((a, b) {
            int numA = int.tryParse(a.number_of_theme) ?? 0;
            int numB = int.tryParse(b.number_of_theme) ?? 0;
            return ascending ? numA.compareTo(numB) : numB.compareTo(numA);
          });
          //_filteredEntries.sort((a, b) => ascending ? a.number_of_theme.compareTo(b.number_of_theme) : b.number_of_theme.compareTo(a.number_of_theme));
          break;
        case 29:
          _filteredEntries.sort((a, b) {
            double numA = double.tryParse(a.ball.toString() ) ?? 0;
            double numB = double.tryParse(b.ball.toString() ) ?? 0;
            return ascending ? numA.compareTo(numB) : numB.compareTo(numA);
          });
          //_filteredEntries.sort((a, b) => ascending ? a.number_of_theme.compareTo(b.number_of_theme) : b.number_of_theme.compareTo(a.number_of_theme));
          break;
        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.brown[300],
        appBar: AppBar(
          title: const Text(
            'Проверенные работы',
            style: TextStyle(
              fontSize: 32,
              color: Colors.white,
              fontFamily: "Raleway",
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.brown[300],
          toolbarHeight: 100,
          iconTheme: IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: Icon(Icons.update_sharp),
              onPressed: () => Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => Myworks())),
            ),
          ],
        ),
        body:
        Column(children: [
         Container(
         child: Padding(
         padding: const EdgeInsets.all(100.0),
         child: TextField(
           controller: _searchController,
           decoration: InputDecoration(
             fillColor: Colors.white,
             filled: true,
             labelText: "Поиск ",
             hintText:
             "Введите название, автора, год или издательство",
             hintStyle:
             TextStyle(color: Colors.grey, fontSize: 15),
             labelStyle: TextStyle(
                 color: Colors.black,
                 fontSize: 16,
                 fontWeight: FontWeight.w400),
             prefixIcon: Icon(
               Icons.search_sharp,
               color: Colors.black,
               size: 25,
             ),
             enabledBorder: OutlineInputBorder(
                 borderSide: BorderSide(
                     color: Colors.grey.shade200, width: 2),
                 borderRadius: BorderRadius.circular(10)),
             floatingLabelStyle: TextStyle(
               color: Colors.black,
               fontSize: 18,
             ),
             focusedBorder: OutlineInputBorder(
               borderSide:
               BorderSide(color: Colors.brown, width: 1.5),
               borderRadius: BorderRadius.circular(10),
             ),
           ),
         ),
       )),
    Container(
    width: double.infinity,
    decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    color: Colors.white,
    ), child: FutureBuilder<List<BibEntryuser>>(
                        future: futureBibEntries,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              snapshot.hasData) {
                            _allEntries = snapshot.data!;

                            return SizedBox(
                                height: MediaQuery.of(context).size.height * 0.5,
                                child: Scrollbar(
                                    controller: _vertical,
                                    thumbVisibility: true,
                                    trackVisibility: true,
                                    child: SingleChildScrollView(
                                        controller: _vertical,
                                        child: Scrollbar(
                                          controller: _horizontal,
                                          thumbVisibility: true,
                                          trackVisibility: true,
                                          notificationPredicate: (notif) => notif.depth == 1,
                                          child: SingleChildScrollView(
                                              controller: _horizontal,
                                              scrollDirection: Axis.horizontal,
                                              //child: ConstrainedBox(
                                                //constraints: BoxConstraints(
                                                  //minWidth: MediaQuery.of(context).size.width,
                                                  //minHeight: MediaQuery.of(context).size.height,
                                                //),
                                    child:  DataTable(
                                  sortColumnIndex: sortColumnIndex,
                                  sortAscending: sortAscending,
                                  columns:  <DataColumn>[
                                    DataColumn(
                                      label: Text('DOI'),
                                      //onSort: (columnIndex, ascending) => onSortColum(columnIndex, ascending),
                                    ),
                                    DataColumn(
                                      label: Text('URL'),
                                      //onSort: (columnIndex, ascending) => onSortColum(columnIndex, ascending),
                                    ),
                                    DataColumn(
                                      label: Text('Год'),
                                      onSort: (columnIndex, ascending) =>
                                          onSortColum(columnIndex, ascending),
                                    ),
                                    DataColumn(
                                      label: Text('Месяц'),
                                      onSort: (columnIndex, ascending) =>
                                          onSortColum(columnIndex, ascending),
                                    ),
                                    DataColumn(
                                      label: Text('Издательство'),
                                      onSort: (columnIndex, ascending) =>
                                          onSortColum(columnIndex, ascending),
                                    ),
                                    DataColumn(
                                      label: Text('Том'),
                                      onSort: (columnIndex, ascending) =>
                                          onSortColum(columnIndex, ascending),
                                    ),
                                    DataColumn(
                                      label: Text('Страницы статьи'),
                                      //onSort: (columnIndex, ascending) => onSortColum(columnIndex, ascending),
                                    ),
                                    DataColumn(
                                      label: Text('Авторы'),
                                      onSort: (columnIndex, ascending) => onSortColum(columnIndex, ascending),
                                    ),
                                    DataColumn(
                                      label: Text('Название статьи'),
                                      onSort: (columnIndex, ascending) =>
                                          onSortColum(columnIndex, ascending),
                                    ),
                                    DataColumn(
                                      label: Text('Наименование журнала'),
                                      onSort: (columnIndex, ascending) =>
                                          onSortColum(columnIndex, ascending),
                                    ),
                                    DataColumn(
                                      label: Text(
                                          'ФИО первого автора на английском'),
                                      onSort: (columnIndex, ascending) =>
                                          onSortColum(columnIndex, ascending),
                                    ),
                                    DataColumn(
                                      label:
                                          Text('ФИО первого автора на русском'),
                                      onSort: (columnIndex, ascending) =>
                                          onSortColum(columnIndex, ascending),
                                    ),
                                    DataColumn(
                                      label: Text('Организации'),
                                      onSort: (columnIndex, ascending) =>
                                          onSortColum(columnIndex, ascending),
                                    ),
                                    DataColumn(
                                      label: Text('Подразделение'),
                                      onSort: (columnIndex, ascending) =>
                                          onSortColum(columnIndex, ascending),
                                    ),
                                    DataColumn(
                                      label: Text('Тип трудовых отношений'),
                                      onSort: (columnIndex, ascending) =>
                                          onSortColum(columnIndex, ascending),
                                    ),
                                    DataColumn(
                                      label: Text('Соавторы статьи'),
                                      onSort: (columnIndex, ascending) =>
                                          onSortColum(columnIndex, ascending),
                                    ),
                                    DataColumn(
                                      label: Text('Количество соавторов'),
                                      onSort: (columnIndex, ascending) =>
                                          onSortColum(columnIndex, ascending),
                                    ),
                                    DataColumn(
                                      label: Text('Наименование книги'),
                                      onSort: (columnIndex, ascending) =>
                                          onSortColum(columnIndex, ascending),
                                    ),
                                    DataColumn(
                                      label: Text('Квартиль'),
                                      onSort: (columnIndex, ascending) =>
                                          onSortColum(columnIndex, ascending),
                                    ),
                                    DataColumn(
                                      label: Text('ISSN'),
                                      onSort: (columnIndex, ascending) => onSortColum(columnIndex, ascending),
                                    ),
                                    DataColumn(
                                      label: Text('ISBN'),
                                      onSort: (columnIndex, ascending) => onSortColum(columnIndex, ascending),
                                    ),
                                    DataColumn(
                                      label: Text('Номер выхода журнала'),
                                      onSort: (columnIndex, ascending) =>
                                          onSortColum(columnIndex, ascending),
                                    ),
                                    DataColumn(label: Text('Тип'),
                                      onSort: (columnIndex, ascending) =>
                                          onSortColum(columnIndex, ascending),
                                    ),
                                    DataColumn(
                                        label: Text(
                                            'Зарубежный/российский журнал'),
                                      onSort: (columnIndex, ascending) =>
                                          onSortColum(columnIndex, ascending),),
                                    DataColumn(label: Text('Особенности'),onSort: (columnIndex, ascending) =>
                                        onSortColum(columnIndex, ascending),),
                                    DataColumn(label: Text('Индекс'),onSort: (columnIndex, ascending) =>
                                        onSortColum(columnIndex, ascending),),
                                    DataColumn(
                                      label: Text('Благодарности'),
                                      onSort: (columnIndex, ascending) =>
                                          onSortColum(columnIndex, ascending),
                                    ),
                                    DataColumn(
                                      label: Text(
                                          'Количество аффиляций автора статьи'),
                                      onSort: (columnIndex, ascending) =>
                                          onSortColum(columnIndex, ascending),
                                    ),
                                    DataColumn(
                                      label: Text('Номер темы ГЗ'),
                                      onSort: (columnIndex, ascending) =>
                                          onSortColum(columnIndex, ascending),
                                    ),
                                    DataColumn(label: Text('Балл за работу'),
                                      onSort: (columnIndex, ascending) =>
                                          onSortColum(columnIndex, ascending),
                                    ),
                                  ],
                                  rows: _filteredEntries
                                      .map((bibEntry) => DataRow(cells: [
                                            DataCell(Text(bibEntry.doi)),
                                            DataCell(Text(bibEntry.url)),
                                            DataCell(
                                                Text(bibEntry.year.toString())),
                                            DataCell(Text(bibEntry.month)),
                                            DataCell(Text(bibEntry.publisher)),
                                            DataCell(Text(
                                                bibEntry.volume.toString())),
                                            DataCell(Text(
                                                bibEntry.pages.toString())),
                                            DataCell(Text(bibEntry.author)),
                                            DataCell(Text(bibEntry.title)),
                                            DataCell(Text(bibEntry.journal)),
                                            DataCell(
                                                Text(bibEntry.first_author)),
                                            DataCell(Text(
                                                bibEntry.author_in_russian)),
                                            DataCell(
                                                Text(bibEntry.organization)),
                                            DataCell(
                                                Text(bibEntry.subdivision)),
                                            DataCell(Text(bibEntry.relations)),
                                            DataCell(
                                                Text(bibEntry.other_authors)),
                                            DataCell(Text(
                                                bibEntry.number_of_authors)),
                                            DataCell(Text(bibEntry.booktitle)),
                                            DataCell(Text(bibEntry.quartile)),
                                            DataCell(Text(bibEntry.issn)),
                                            DataCell(Text(bibEntry.isbn)),
                                            DataCell(Text(bibEntry.number)),
                                            DataCell(Text(bibEntry.type)),
                                            DataCell(Text(bibEntry.language)),
                                            DataCell(Text(bibEntry.note)),
                                            DataCell(Text(
                                                bibEntry.index.toString())),
                                            DataCell(Text(bibEntry.gratitude)),
                                            DataCell(Text(bibEntry
                                                .number_of_affiliation
                                                .toString())),
                                            DataCell(
                                                Text(bibEntry.number_of_theme)),
                                            DataCell(
                                                Text(bibEntry.ball.toString())),
                                          ]))
                                      .toList(),
                                ),)
                              ),
                            )));
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        },
        ),)
    ]));
  }
}
