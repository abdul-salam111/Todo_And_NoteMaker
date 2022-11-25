import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notemaker/constants.dart';
import 'package:notemaker/createNotes.dart';
import 'package:notemaker/database/Database.dart';
import 'package:notemaker/model/notesModel.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  NotesDataBase notesDataBase = NotesDataBase();
  late Future<List<NotesModel>> noteslist;
  loadData() async {
    noteslist = notesDataBase.getAllNotes();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  time(String dateTime) {
    var NowDateTime = DateTime.now();
    var postingTime = dateTime;
    final Duration duration =
        NowDateTime.difference(DateTime.parse(postingTime));
    if (duration.inMinutes == 0 && duration.inHours == 0) {
      return "now";
    } else {
      return "${DateFormat.jm().format(DateTime.parse(dateTime))}  ${DateFormat.yMMMEd().format(DateTime.parse(dateTime))}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (builder) => CreateNote(
                        isUpdate: false,
                      )));
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 30,
          ),
          Text(
            "Notes",
            style: Notes,
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 40,
            child: TextField(
              cursorColor: Colors.black,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  fillColor: const Color.fromARGB(141, 238, 238, 238),
                  filled: true,
                  prefixIconColor: Colors.black,
                  prefixStyle: const TextStyle(color: Colors.black),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none),
                  border: InputBorder.none,
                  label: const Text("Search notes")),
            ),
          ),
          FutureBuilder(
            future: noteslist,
            builder: ((context, AsyncSnapshot<List<NotesModel>> snapshot) {
              return snapshot.data == null
                  ? const Center()
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      itemCount: snapshot.data?.length,
                      itemBuilder: ((context, int index) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Dismissible(
                            onDismissed: (direction) {
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.error,
                                animType: AnimType.rightSlide,
                                title: 'Delete the notes?',
                                desc:
                                    'Are you sure you want to delete the note?',
                                btnCancelOnPress: () {
                                  setState(() {});
                                },
                                btnOkOnPress: () {
                                  setState(() {
                                    notesDataBase
                                        .deleteNotes(snapshot.data![index].id!);
                                    noteslist = notesDataBase.getAllNotes();
                                    //for removing the index from list
                                    snapshot.data!
                                        .remove(snapshot.data![index]);
                                  });
                                },
                              ).show();
                            },
                            direction: DismissDirection.endToStart,
                            background: Container(),
                            secondaryBackground: Container(
                              color: Colors.red,
                              child: const Center(
                                child: Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            key: UniqueKey(),
                            child: Container(
                              decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(141, 238, 238, 238),
                                  borderRadius: BorderRadius.circular(10)),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (builder) => CreateNote(
                                                id: snapshot.data![index].id,
                                                title:
                                                    snapshot.data![index].title,
                                                description: snapshot
                                                    .data![index].description,
                                                isUpdate: true,
                                                updateImage: snapshot
                                                    .data![index].photoName,
                                              )));
                                },
                                child: ListTile(
                                  title: Text(
                                    snapshot.data![index].title.toString(),
                                    style: titleStyle,
                                  ),
                                  isThreeLine: true,
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        snapshot.data![index].description
                                            .toString(),
                                        style: const TextStyle(fontSize: 15),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        time(snapshot.data![index].date_time
                                            .toString()),
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  trailing: Container(
                                    width: 100,
                                    height: 100,
                                    child: snapshot.data![index].photoName ==
                                            null
                                        ? Center()
                                        : imageFromBase64String(
                                            snapshot.data![index].photoName!),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }));
            }),
          )
        ],
      ),
    );
  }

  static Image imageFromBase64String(String base64String) {
    return Image.memory(
      base64Decode(base64String),
      fit: BoxFit.cover,
    );
  }
}
