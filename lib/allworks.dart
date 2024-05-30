import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'form_last.dart';
import 'log.dart';
import 'main.dart';



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
  String title;
  String journal;
  String number;
  String issn;
  double index;
  String type;
  String note;
  String isbn;
  String language;

  BibEntry({
    required this.id,
    required this.url,
    required this.doi,
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
  });

  factory BibEntry.fromJson(Map<String, dynamic> json) {
    return BibEntry(
      id: json['id'],
      doi: json['doi'],
      url: json['url'] ,
      year: json['year'] ,
      month: json['month'] ,
      publisher: json['publisher'] ,
      volume: json['volume'] ,
      pages: json['pages'] ,
      title: json['title'] ,
      journal: json['journal'] ,
      //username: json['username'] ?? '',
      author_in_russian: json['author_in_russian'] ,
      first_author: json['first_author'] ,
      organization: json['organization'] ,
      subdivision: json['subdivision'] ,
      relations: json['relations'] ,
      other_authors: json['other_authors'] ,
      number_of_authors: json['number_of_authors'] ,
      booktitle: json['booktitle'] ,
      quartile: json['quartile'] ,
      number_of_affiliation: json['number_of_affiliation'] ,
      number_of_theme: json['number_of_theme'],
      gratitude: json['gratitude'] ,
      number: json['number'] ,
      issn: json['issn'] ,
      index: (json['index'] != null)
          ? double.tryParse(json['index'].toString()) ?? 0.0
          : 0.0,
      type: json['type'] ,
      note: json['note'] ,
      isbn: json['isbn'] ,
      language: json['language'] ,
      author: json['author'],
    );
  }
}

Future<List<BibEntry>> fetchBibEntries() async {
  final response = await http.get(
    Uri.parse('$baseUrl/bibtex/unchecked/$username/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'ngrok-skip-browser-warning': 'true'
    },
  );

  if (response.statusCode == 200) {
    final decodedResponse = utf8.decode(response.bodyBytes);
    List<dynamic> jsonList = json.decode(decodedResponse);
    return jsonList.map((json) => BibEntry.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load bib entries');
  }
}

class BibEntryListPage extends StatefulWidget {
  @override
  _BibEntryListPageState createState() => _BibEntryListPageState();
}

class _BibEntryListPageState extends State<BibEntryListPage> {
  late Future<List<BibEntry>> futureBibEntries;
  late List<BibEntry> _allEntries;
  List<BibEntry> _filteredEntries = [];
  TextEditingController _searchController = TextEditingController();
  bool sortAscending = true;
  int sortColumnIndex = 0;
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[300],
      appBar: AppBar(
        title: const Text(
          'Непроверенные работы',
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
                context, MaterialPageRoute(builder: (context) => BibEntryListPage())),
          ),
        ],
      ),
      body: Container(
    width: double.infinity,
    decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    color: Colors.white,
    ),
    child: FutureBuilder<List<BibEntry>>(
        future: futureBibEntries,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text('No data available.'));
            }

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
          child: ConstrainedBox(
          constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
          minHeight: MediaQuery.of(context).size.height,
          ),
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Проверить')),
                    DataColumn(label: Text('Авторы')),
                    DataColumn(label: Text('ФИО первого автора на английском')),
                    DataColumn(label: Text('ФИО первого автора на русском')),
                    DataColumn(label: Text('DOI'),),
                    DataColumn(label: Text('URL')),
                    DataColumn(label: Text('Организации')),
                    DataColumn(label: Text('Подразделение')),
                    DataColumn(label: Text('Тип трудовых отношений')),
                    DataColumn(label: Text('Соавторы статьи')),
                    DataColumn(label: Text('Количество соавторов')),
                    DataColumn(label: Text('Название статьи')),
                    DataColumn(label: Text('Издательство')),
                    DataColumn(label: Text('Наименование журнала')),
                    DataColumn(label: Text('Наименование книги')),
                    DataColumn(label: Text('Квартиль')),
                    DataColumn(label: Text('Том')),
                    DataColumn(label: Text('Номер выхода журнала')),
                    DataColumn(label: Text('Страницы статьи')),
                    DataColumn(label: Text('Год')),
                    DataColumn(label: Text('Месяц')),
                    DataColumn(label: Text('ISSN')),
                    DataColumn(label: Text('Благодарности')),
                    DataColumn(label: Text('Количество аффиляций автора статьи')),
                    DataColumn(label: Text('Номер темы ГЗ')),
                    DataColumn(label: Text('Тип')),
                    DataColumn(
                        label: Text('Зарубежный/российский журнал')),
                    DataColumn(label: Text('Особенности')),
                    DataColumn(label: Text('Индекс')),
                    DataColumn(label: Text('ISBN')),
                  ],
                  rows: snapshot.data!.map((bibEntry) {
                    return DataRow(cells: [
                      DataCell(
                        TextButton(
                          onPressed: () {
                            print("Button clicked!");
                            String doiUrl = bibEntry.doi;
                            String idf = bibEntry.id.toString();
                            print(bibEntry.id);
                            print(idf);
                            print(doiUrl);
                            idf = bibEntry.id.toString();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        BibEntryEditPage1(
                                          entryId: doiUrl,
                                          id_: idf,
                                          username: username,
                                        )));
                          },
                          child: Icon(
                            Icons.check_circle_outline_sharp,
                            color: Colors.green,
                          ),
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(8)),
                            shape: MaterialStateProperty.all<OutlinedBorder>(CircleBorder()),
                            overlayColor: MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return Colors.green.withOpacity(0.5);
                                }
                                return Colors.transparent;
                              },
                            ),
                          ),
                        ),
                      ),
                      DataCell(Text(bibEntry.author)),
                      DataCell(Text(bibEntry.first_author)),
                      DataCell(Text(bibEntry.author_in_russian)),
                      DataCell(Text(bibEntry.doi)),
                      DataCell(Text(bibEntry.url)),
                      DataCell(Text(bibEntry.organization)),
                      DataCell(Text(bibEntry.subdivision)),
                      DataCell(Text(bibEntry.relations)),
                      DataCell(Text(bibEntry.other_authors)),
                      DataCell(Text(bibEntry.number_of_authors)),
                      DataCell(Text(bibEntry.title)),
                      DataCell(Text(bibEntry.publisher)),
                      DataCell(Text(bibEntry.journal)),
                      DataCell(Text(bibEntry.booktitle)),
                      DataCell(Text(bibEntry.quartile)),
                      DataCell(Text(bibEntry.volume.toString())),
                      DataCell(Text(bibEntry.number)),
                      DataCell(Text(bibEntry.pages)),
                      DataCell(Text(bibEntry.year.toString())),
                      DataCell(Text(bibEntry.month)),
                      DataCell(Text(bibEntry.issn)),
                      DataCell(Text(bibEntry.gratitude)),
                      DataCell(Text(bibEntry.number_of_affiliation
                          .toString())),
                      DataCell(Text(bibEntry.number_of_theme)),
                      DataCell(Text(bibEntry.type)),
                      DataCell(Text(bibEntry.language)),
                      DataCell(Text(bibEntry.note)),
                      DataCell(Text(bibEntry.index.toString())),
                      DataCell(Text(bibEntry.isbn)),

                    ]);
                  }).toList(),
                ))))),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),)
    );
  }
}

void main() {
  runApp(MaterialApp(home: BibEntryListPage()));
}
