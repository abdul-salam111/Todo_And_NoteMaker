import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:notemaker/database/Database.dart';
import 'package:notemaker/model/todoModel.dart';
import 'package:notemaker/notification.dart';
import 'package:notemaker/provider/provider.dart';
import 'package:notemaker/todoScreen.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'constants.dart';
import 'createNotes.dart';
import 'notesScreen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  NotesDataBase? notesDataBase;
  static const List<Widget> _pages = <Widget>[
    NotesScreen(),
    TodosScreen(),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notesDataBase = NotesDataBase();
    notesDataBase!.initializeDatabase();
    tz.initializeTimeZones();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: 'Do you want to close App?',
          btnCancelOnPress: () {
            setState(() {});
          },
          btnOkOnPress: () {
            SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          },
        ).show();
        return true;
      },
      child: Scaffold(
        bottomNavigationBar: Consumer<PageProvider>(
          builder: ((context, value, child) {
            return BottomNavigationBar(
              currentIndex: value.indexno,
              selectedIconTheme: const IconThemeData(color: Colors.green),
              unselectedIconTheme: const IconThemeData(color: Colors.grey),
              selectedLabelStyle: const TextStyle(fontSize: 12),
              iconSize: 20,
              onTap: (val) {
                value.nextPage(val);
              },
              items: const [
                BottomNavigationBarItem(
                    label: "Notes", icon: Icon(Icons.note_rounded)),
                BottomNavigationBarItem(
                    label: "To-dos",
                    icon: Icon(
                      Icons.pending_actions_outlined,
                    ))
              ],
            );
          }),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Consumer<PageProvider>(
              builder: (context, value, child) {
                return _pages.elementAt(value.indexno);
              },
            ),
          ),
        ),
      ),
    );
  }
}
