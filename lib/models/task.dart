class Task {
  final int id;
  final String title;
  final String description;
  final String location;
  Task({this.id, this.title, this.description, this.location});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location
    };
  }
}