import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sticky_headers/sticky_headers/widget.dart';

import 'form_last.dart';
import 'form.dart';
import 'log.dart';
import 'myworks.dart';
String doi_url = '';
String idf = '';
// Define the BibEntry model.
class BibEntry {
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
  final String username;
  final String number;
  final String issn;


  BibEntry({
    required this.id,
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
  });

  // Factory constructor for creating a new BibEntry instance from a map.
  factory BibEntry.fromJson(Map<String, dynamic> json) {
    return BibEntry(
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
    );
  }
}
class CheckboxButton extends StatefulWidget {
  final String label;
  final Function(bool?) onChanged;

  const CheckboxButton({
    Key? key,
    required this.label,
    required this.onChanged,
  }) : super(key: key);

  @override
  _CheckboxButtonState createState() => _CheckboxButtonState();
}

class _CheckboxButtonState extends State<CheckboxButton> {
  late Future<List<BibEntryuser>> futureBibEntries;

  bool _isChecked = false;

  void _toggleCheckbox() {
    setState(() {
      _isChecked = !_isChecked;
    });
    widget.onChanged(_isChecked);
  }


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _toggleCheckbox,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: _isChecked,
            onChanged: (bool? value) {
              _toggleCheckbox();
            },
          ),
          Text(widget.label),
        ],
      ),
    );
  }
}


// Function to fetch BibEntry data from the API.
Future<List<BibEntry>> fetchBibEntries() async {
  final response = await http.get(Uri.parse('http://127.0.0.1:8000/bibtex/unchecked/${username}/'));

  if (response.statusCode == 200) {
    final decodResponse = utf8.decode(response.bodyBytes);
    List<dynamic> jsonList = json.decode(decodResponse);
    return jsonList.map((json) => BibEntry.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load bib entries');
  }
}

// Widget that displays a list of BibEntries.
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
  int sortColumnIndex = 0; // Start sorting by the first column if needed


  @override
  void initState() {
    super.initState();
    futureBibEntries = fetchBibEntries();
    futureBibEntries.then((entries) {
      _allEntries = entries;
      _filteredEntries = List.from(_allEntries); // Initialize filtered entries
    });
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _filteredEntries = _searchController.text.isEmpty
          ? List.from(_allEntries)
          : _allEntries.where((entry) => entry.title.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[300],
      appBar : AppBar(title: const Text('Непроверенные работы',
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
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Myworks())),
          ),
        ],
      ),
      body: FutureBuilder<List<BibEntry>>(
        future: futureBibEntries,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text('No data available.'));
            }

            // Using DataTable to display the entries.
            return Expanded(
                flex: 2,
                child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          ),
          color: Colors.white,
          ),
          padding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
              child:  DataTable(

                  columns: [
                    //DataColumn(label: Text('id')),
                    DataColumn(label: Text('Проверить'),
                    ),
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

                  ],

                rows: snapshot.data!
                    .map(
                      (bibEntry) => DataRow(cells: [
                        //DataCell(Text(bibEntry.id.toString())),
                        DataCell(
                          TextButton(

                            onPressed: () {
                              // Define the behavior for this button.
                              print("Button clicked!");
                              doi_url = bibEntry.doi;
                              idf = bibEntry.id.toString();
                              print(bibEntry.id);
                              print(idf);
                              print(doi_url);
                              Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (context) => BibEntryEditPage1(entryId: doi_url, id_: idf,username: username,)));
                            },
                            child: Icon(
                              Icons.check_circle_outline_sharp, // Icon to indicate the action
                              color: Colors.green, // You can customize the color
                            ),
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(8)),
                              shape: MaterialStateProperty.all<OutlinedBorder>(CircleBorder()),
                              // Ensures no background color
                              overlayColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return Colors.green.withOpacity(0.5); // Custom color when the button is pressed
                                }
                                return Colors.transparent; // Default color in other states
                              }),// Optional: makes the button circular
                            ), // Provide meaningful text or another child.
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
                        DataCell(Text(bibEntry.number_of_affiliation.toString())),
                        DataCell(Text(bibEntry.number_of_theme)),
                  ]),
                )
                    .toList(),
              ),
          )))
            );
          } else {
            // Show a loading spinner while waiting for the data.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: BibEntryListPage()));
}