class NotesModel {
  int? id;
  String? title;
  String? description;
  late String? photoName;
  String? date_time;

  NotesModel({
    this.id,
    this.title,
    this.description,
    this.date_time,
    this.photoName,
  });
  factory NotesModel.fromMap(Map<String, dynamic> map) {
    return NotesModel(
      id: map["id"],
      title: map["title"],
      description: map["description"],
      date_time: map["date_time"],
      photoName: map["photoName"],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "photoName": photoName,
      "date_time": date_time,
    };
  }
}
