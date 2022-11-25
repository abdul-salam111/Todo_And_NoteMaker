import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:notemaker/constants.dart';
import 'package:notemaker/database/Database.dart';
import 'package:notemaker/model/todoModel.dart';

import 'notification.dart';

class TodosScreen extends StatefulWidget {
  const TodosScreen({Key? key}) : super(key: key);

  @override
  State<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends State<TodosScreen> {
  final todoController = TextEditingController();
  NotesDataBase todoDataBase = NotesDataBase();
  late Future<List<TodoModel>> todosList;
  loadData() async {
    todosList = todoDataBase.getAllToDos();
  }

  DateTime? dateTime;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    todoController.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
    setState(() {});
  }

  bool ischecked = false;
  final searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    print("build");
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
                context: context,
                builder: ((context) => Padding(
                      padding: EdgeInsets.only(
                          top: 20,
                          right: 20,
                          left: 20,
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 8.0),
                          SizedBox(
                            height: 50,
                            child: TextField(
                              controller: todoController,
                              decoration: InputDecoration(
                                  hintText: 'Add a to-do item',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              autofocus: true,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                      shape: const StadiumBorder()),
                                  onPressed: () async {
                                    dateTime =
                                        await DatePicker.showDateTimePicker(
                                            context,
                                            showTitleActions: true,
                                            maxTime: DateTime(2030, 6, 7),
                                            onChanged: (date) {},
                                            onConfirm: (date) {},
                                            currentTime: DateTime.now(),
                                            locale: LocaleType.en);
                                  },
                                  icon: const Icon(Icons.alarm),
                                  label: const Text("Set Alarm")),
                              TextButton(
                                  onPressed: () {
                                    NotesDataBase()
                                        .insertToDo(
                                      TodoModel(
                                        todoName: todoController.text.trim(),
                                        dateTime: dateTime.toString(),
                                        taskStatus: "Incomplete",
                                      ),
                                    )
                                        .then((value) {
                                      setState(() {
                                        loadData();
                                      });
                                      Navigator.pop(context);

                                      NotificationServices().sendNotification(
                                        "To-dos",
                                        "To-dos:${todoController.text}",
                                        dateTime == null
                                            ? DateTime.now()
                                            : dateTime!,
                                      );
                                    });
                                  },
                                  child: const Text(
                                    "Save",
                                    style: TextStyle(fontSize: 17),
                                  ))
                            ],
                          )
                        ],
                      ),
                    )));
          },
          child: Icon(Icons.add),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 30,
            ),
            Text(
              "To-dos",
              style: Notes,
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 40,
              child: TextField(
                controller: searchController,
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
            Expanded(
              child: FutureBuilder(
                future: todosList,
                builder: ((context, AsyncSnapshot<List<TodoModel>> snapshot) {
                  return snapshot.data == null
                      ? const Center()
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
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
                                        NotesDataBase().deleteToDo(
                                            snapshot.data![index].id!);
                                        todosList = todoDataBase.getAllToDos();
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
                                      color: const Color.fromARGB(
                                          141, 238, 238, 238),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: GestureDetector(
                                      onTap: () {},
                                      child: ListTile(
                                        title: Row(
                                          children: [
                                            Text(
                                              snapshot.data![index].todoName
                                                  .toString(),
                                              style: titleStyle,
                                            ),
                                            snapshot.data![index].taskStatus ==
                                                    "Complete"
                                                ? Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      color: Colors.green,
                                                    ),
                                                    child: Icon(
                                                      Icons.done_outlined,
                                                      color: Colors.white,
                                                      size: 10,
                                                    ),
                                                  )
                                                : Center()
                                          ],
                                        ),
                                        subtitle: Row(
                                          children: [
                                            Icon(
                                              Icons.alarm,
                                              size: 12,
                                            ),
                                            Text(
                                              time(snapshot
                                                  .data![index].dateTime
                                                  .toString()),
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        trailing: Checkbox(
                                            value: snapshot.data![index]
                                                        .taskStatus ==
                                                    "Complete"
                                                ? true
                                                : false,
                                            onChanged: (val) {
                                              setState(() {});
                                              if (snapshot.data![index]
                                                      .taskStatus ==
                                                  "Complete") {
                                                setState(() {
                                                  NotesDataBase().updateToDos(
                                                      TodoModel(
                                                          id: snapshot
                                                              .data![index].id,
                                                          taskStatus:
                                                              "InComplete"));
                                                });
                                                loadData();
                                              } else {
                                                setState(() {
                                                  NotesDataBase().updateToDos(
                                                      TodoModel(
                                                          id: snapshot
                                                              .data![index].id,
                                                          taskStatus:
                                                              "Complete"));
                                                });
                                                loadData();
                                              }
                                            }),
                                      )),
                                ),
                              ),
                            );
                          }));
                }),
              ),
            ),
          ],
        ));
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
}
