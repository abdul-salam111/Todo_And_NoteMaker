class TodoModel {
  int? id;
  String? todoName;
  String? dateTime;
  String? taskStatus;
  TodoModel({this.id, this.todoName, this.dateTime, this.taskStatus});
  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
        id: map["id"],
        todoName: map["todoName"],
        dateTime: map["dateTime"],
        taskStatus: map["taskStatus"]);
  }
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "todoName": todoName,
      "dateTime": dateTime,
      "taskStatus": taskStatus
    };
  }
}
