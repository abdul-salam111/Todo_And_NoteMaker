import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notemaker/HomeScreen.dart';
import 'package:notemaker/database/Database.dart';
import 'package:notemaker/model/notesModel.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class CreateNote extends StatefulWidget {
  String? title;
  String? description;
  bool? isUpdate = false;
  String? updateImage;
  int? id;
  CreateNote(
      {this.description, this.title, this.isUpdate, this.id, this.updateImage});

  @override
  State<CreateNote> createState() => _CreateNoteState();
}

class _CreateNoteState extends State<CreateNote> {
  final ImagePicker _picker = ImagePicker();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  NotesDataBase? notesDataBase = NotesDataBase();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.isUpdate == true) {
      titleController.text = widget.title!;
      descriptionController.text = widget.description!;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
  }

  var bytes;
  String? imageFile;
  File? image;
  takeAPicture() async {
    final PickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (PickedFile != null) {
      setState(() {
        image = File(PickedFile.path);
      });
      bytes = File(PickedFile.path).readAsBytesSync();
      imageFile = base64Encode(bytes);
      print(PickedFile.path);
    }
  }

  chooseFromGallery() async {
    final PickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (PickedFile != null) {
      setState(() {
        image = File(PickedFile.path);
      });
      bytes = File(PickedFile.path).readAsBytesSync();
      imageFile = base64Encode(bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: ((context) {
                return AlertDialog(
                  title: const Text("Albums"),
                  content: SizedBox(
                    height: 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton(
                            onPressed: () {
                              takeAPicture();
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Take a picture",
                              style: const TextStyle(color: Colors.black),
                            )),
                        TextButton(
                            onPressed: () {
                              chooseFromGallery();
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Choose from album",
                              style: TextStyle(color: Colors.black),
                            ))
                      ],
                    ),
                  ),
                );
              }));
        },
        child: const Icon(Icons.photo),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
        title: const Text("Notes"),
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () async {
                if (widget.isUpdate == false) {
                  print(imageFile);
                  await NotesDataBase()
                      .insertNote(NotesModel(
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim(),
                    date_time: DateTime.now().toString(),
                    photoName: imageFile,
                  ))
                      .then((value) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (builder) => HomeScreen()));
                  });
                } else {
                  await NotesDataBase()
                      .updateNote(NotesModel(
                          id: widget.id,
                          title: titleController.text.trim(),
                          description: descriptionController.text.trim(),
                          date_time: DateTime.now().toString(),
                          photoName: imageFile))
                      .then((value) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (builder) => HomeScreen()));
                  });
                }
              },
              icon: const Icon(
                Icons.done,
                color: Colors.black,
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DateFormat.jm().format(DateTime.now()).toString()),
              const SizedBox(
                height: 10,
              ),
              TextField(
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                controller: titleController,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w500),
                decoration: const InputDecoration(
                    hintText: "Title",
                    hintStyle: const TextStyle(color: Colors.black),
                    border: InputBorder.none),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                controller: descriptionController,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w400),
                decoration: const InputDecoration(
                    hintText: "Note something down",
                    hintStyle: TextStyle(color: Colors.black),
                    border: InputBorder.none),
              ),
              const SizedBox(
                height: 10,
              ),
              image == null
                  ? widget.isUpdate == true
                      ? widget.updateImage == null
                          ? Center()
                          : imageFromBase64String(widget.updateImage!)
                      : const Center()
                  : Container(
                      child: Image(image: FileImage(image!)),
                    )
            ],
          ),
        ),
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
