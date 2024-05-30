import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'log.dart';
import 'dart:convert';
import 'main.dart';
import 'menu.dart';

void main() => runApp(const Upload());

class Upload extends StatelessWidget {
  const Upload({super.key});

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Форма загрузки';
      return Scaffold(
        backgroundColor: Colors.brown[300],
        body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Column(
              children: [
                Row(children: [
                  IconButton(
                    color: Colors.white,
                    icon: const Icon(Icons.arrow_back_sharp),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Menu()),
                      );
                    },
                  ),
                  Spacer(),
                  Spacer(),
                  Expanded(
                  child:
                  Padding(
                    padding: EdgeInsets.only(top: 50, left: 10),
                    child: TweenAnimationBuilder(
                      child: Text(
                        textAlign: TextAlign.center,
                        appTitle,
                        style: TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontFamily: "Raleway",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: Duration(milliseconds: 500),
                      builder: (BuildContext context, double _value, child) {
                        return Opacity(
                          opacity: _value,
                          child: child,
                        );
                      },
                    ),
                  ),
                ),
            Spacer(),
            Opacity(
              opacity: 0.0,
              child: IconButton(
                icon: Icon(Icons.arrow_back_sharp),
                onPressed: null,
              )),Spacer(),],),
                const SizedBox(height: 20),
                Expanded(
                flex: 2,
                child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                ),
                color: Colors.white,
                ),
                padding: EdgeInsets.all(20),
                child: SingleChildScrollView(
                child: Column(
                children: [
                Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [ MyCustomForm()
                          ],
                        ),]
          ),))
        )])));
  }
}

class MyCustomForm extends StatefulWidget {



  @override
  MyCustomFormState createState() => MyCustomFormState();
}

class MyCustomFormState extends State<MyCustomForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _bibtextController = TextEditingController();

  Future<void> uploadBibText(String bibtex, String username) async {
    final url = Uri.parse('$baseUrl/bibtex/upload/');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'bibtex': bibtex,
          'username': username,
        }),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning':'true'
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201 ) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.brown[50],
              content: ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text('Вы успешно загрузили данные.',
                ),
              ),
              title: Text('Данные загружены'),
              actions: <Widget>[
                MaterialButton(
                  color: Colors.brown,
                  child: Text('OK', style: TextStyle(color: Colors.white),),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(
                            builder: (context) => Menu()));
                  },
                ),
              ],
            );
          },
        );
        print('Data uploaded successfully');
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.brown[50],
              content: ListTile(
                leading: Icon(Icons.error, color: Colors.redAccent),
                title: Text('Проверьте данные',
                ),
              ),
              title: Text('Ошибка'),
              actions: <Widget>[
                MaterialButton(
                  color: Colors.brown,
                  child: Text('OK', style: TextStyle(color: Colors.white),),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(
                            builder: (context) => Upload()));
                  },
                ),
              ],
            );
          },
        );
        print('Failed to upload data');
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.brown[50],
            content: ListTile(
              leading: Icon(Icons.error, color: Colors.redAccent),
              title: Text('Проверьте данные',
              ),
            ),
            title: Text('Ошибка'),
            actions: <Widget>[
              MaterialButton(
                color: Colors.brown,
                child: Text('OK', style: TextStyle(color: Colors.white),),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(
                          builder: (context) => Upload()));
                },
              ),
            ],
          );
        },
      );
      print('Caught error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 300,
            width: 310,
            child: TextField(
              controller: _bibtextController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              readOnly: false,
              showCursor: true,
              cursorColor: Colors.black,
              decoration: InputDecoration(
                labelText: "Введите bib текст",
                alignLabelWithHint: true,
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 10,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey.shade200,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                floatingLabelStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.brown,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: 310,
            child: Container(
              width: 310,
              child: MaterialButton(
                height: 45,

                onPressed: () {

                  String bibtexText = _bibtextController.text;

                  uploadBibText(bibtexText, username);
                },
                padding: EdgeInsets.symmetric(
                    vertical: 10, horizontal: 120),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.brown,
                child: Text(
                  'Парсинг',
                  style: TextStyle(color: Colors.white),
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
    _bibtextController.dispose();
    super.dispose();
  }
}
