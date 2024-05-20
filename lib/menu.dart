import 'dart:html';

import 'package:flutter/material.dart';

import 'package:proj/main.dart';
import 'package:proj/myworks.dart';
import 'package:proj/settings.dart';
import 'package:proj/token.dart';
import 'package:proj/upload.dart';
import 'package:proj/usercab.dart';
import 'allworks.dart';
import 'form.dart';
import 'log.dart';

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Личный кабинет',
            style: TextStyle(fontSize: 32, color: Colors.white, fontFamily: "Raleway", fontWeight: FontWeight.bold)),
        backgroundColor: Colors.brown[300],
        toolbarHeight: 100,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState!.openDrawer();
            },
          ),
          actions:[ IconButton(
            icon: Icon(Icons.update_sharp),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Menu())),
          ),
        ],
      ),
      body: Center(
        child: CountPagef(username: username,),
      ),
      drawer: NavDrawer(),
    );
  }
}

class NavDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'Меню',
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontFamily: "Raleway",
                  fontWeight: FontWeight.bold,
                ),
            ),
            decoration: BoxDecoration(
                color: Colors.brown[300],
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/images/cover.jpg'))),
          ),
          ListTile(
            leading: Icon(Icons.list_alt_sharp),
            title: Text('Список заданий',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),),
            onTap: () => {Navigator.push(context,
                MaterialPageRoute(
                    builder: (context) => BibEntryListPage()))},
          ),
          ListTile(
            leading: Icon(Icons.upload_file_sharp),
            title: Text('Загрузка', style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),),
            onTap: () => {Navigator.push(context,
                MaterialPageRoute(
                    builder: (context) => Upload()))},
          ),
          ListTile(
            leading: Icon(Icons.settings_sharp),
            title: Text('Настройки', style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),),
            onTap: () => {Navigator.push(context,
            MaterialPageRoute(
            builder: (context) => SettingsScreen(username: '${username}',)))},
          ),
          ListTile(
            leading: Icon(Icons.border_color_sharp),
            title: Text('Мои работы',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),),
            onTap: () => {Navigator.push(context,
                MaterialPageRoute(
                    builder: (context) => Myworks()))},
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app_sharp),
            title: Text('Выход',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),),
            onTap: () => {Navigator.push(context,
                MaterialPageRoute(
                    builder: (context) => RegisterLoginPage()))},
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Menu(),
  ));
}
