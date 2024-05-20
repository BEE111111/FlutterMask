import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:proj/upload.dart';

import 'menu.dart';
String username = "";
class RegisterLoginPage extends StatefulWidget {
  @override
  _RegisterLoginPageState createState() => _RegisterLoginPageState();
}

class _RegisterLoginPageState extends State<RegisterLoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool playAreas = false; // False for Register, True for Login

  Future<void> _submit() async {
    username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();
    final String url = playAreas
        ? 'http://127.0.0.1:8000/login/'
        : 'http://127.0.0.1:8000/register/';

    try {
      final http.Response response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (playAreas && response.statusCode == 200) {
        print('User logged in successfully');
        // Handle successful login, e.g., navigate to another screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyCustomForm(),
          ),
        );

        Navigator.push(context,
            MaterialPageRoute(
                builder: (context) => Menu()));
      } else if (!playAreas && response.statusCode == 201) {
        print('User registered successfully');
        _usernameController.clear();
        _passwordController.clear();
        // Handle successful registration, e.g., show success message
      } else {
        showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                    playAreas ? 'Ошибка входа.' : 'Ошибка регистрации.',
                    style: TextStyle(
                      color: Colors.brown, // Set the color of title text to brown
                    ),
                  ),
                  content: SingleChildScrollView( // Use SingleChildScrollView for larger content
                    child: ListBody(
                      children: <Widget>[
                        Text(
                          'Не удалось ${playAreas ? 'войти' : 'зарегистрироваться'}.',
                          style: TextStyle(
                            color: Colors.brown, // Set the color of content text to brown
                          ),
                        ),
                        // Add more Widgets here if you want to increase the content
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('OK', style: TextStyle(color: Colors.brown)), // Set the color of button text to brown
                    ),
                  ],
                  backgroundColor: Colors.brown[50], // Set the background color of the dialog
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)), // Rounded corners for the dialog
                  ),
                );
              }
            );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An unexpected error occurred. Please try again later.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      print('Exception occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[300],

      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Column(
          children: [
            Expanded(
              child:
              Padding(
                padding: EdgeInsets.only(top: 50, left: 10),
                child: TweenAnimationBuilder(
                  child: Text(
                    playAreas ? "Добро пожаловать!" : "Регистрация",
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
                        children: [
                          Container(
                            height: 50,
                            width: 310,
                            child: TextField(
                              controller: _usernameController,
                              readOnly: false,
                              showCursor: true,
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                labelText: "Email",
                                hintText: "Username or E-mail",
                                hintStyle: TextStyle(
                                    color: Colors.grey, fontSize: 15),
                                labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400),
                                prefixIcon: Icon(
                                  Icons.perm_identity_sharp,
                                  color: Colors.black,
                                  size: 25,
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade200,
                                        width: 2),
                                    borderRadius:
                                    BorderRadius.circular(10)),
                                floatingLabelStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.brown,
                                      width: 1.5),
                                  borderRadius:
                                  BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      //TextField(
                        //controller: _usernameController,
                        //decoration: InputDecoration(
                          //labelText: "Username or Email",
                          //prefixIcon: Icon(Icons.person),
                          //border: OutlineInputBorder(),
                        //),
                      //),
                      SizedBox(height: 10),
                      Container(
                        height: 50,
                        width: 310,
                        child: TextField(
                          controller: _passwordController,
                          readOnly: false,
                          showCursor: true,
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            labelText: "Password",
                            hintStyle: TextStyle(
                                color: Colors.grey, fontSize: 15),
                            hintText: "Password",
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                            prefixIcon: Icon(
                              Icons.vpn_key_outlined,
                              color: Colors.black,
                              size: 20,
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey.shade200,
                                    width: 2),
                                borderRadius:
                                BorderRadius.circular(10)),
                            floatingLabelStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.brown,
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: 310,
                      child: MaterialButton(
                        height: 45,
                          onPressed: _submit,
                          padding: EdgeInsets.symmetric(
                          vertical: 10, horizontal: 120),
                          shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          ),
                          color: Colors.brown,
                          child: Text(
                            playAreas ? 'Войти' : 'Регистрация',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                          Container(
                            width: 270,
                            height: 45,
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    playAreas = !playAreas;
                                  });
                                },
                                child: Text(
                                  playAreas ? 'Нет аккаунта? Зарегистрироваться.' : 'Есть аккаунт? Войти.',
                                  style: TextStyle(
                                    color: Colors.brown[300],
                                      fontSize: 15,
                                    fontWeight: FontWeight.w600),
                                ),
                              ),
                          )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

