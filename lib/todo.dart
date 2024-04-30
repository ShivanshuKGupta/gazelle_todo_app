class Todo {
  /// The unique identifier of the todo, this identifier will be used to uniquely identify the todo
  String id;

  /// The title of the todo
  String title;

  /// The description of the todo
  String description;

  /// The date and time when the todo was created
  DateTime createdAt;

  /// The date and time when the todo was completed
  /// If this value is null, it means the todo is not yet completed
  DateTime? completedAt;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.completedAt,
  });

  /// A factory constructor that creates a Todo instance from a JSON object
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdAt:
          DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now(),
      completedAt: DateTime.tryParse(json['completedAt'].toString()),
    );
  }

  /// A method that converts a Todo instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  /// A method that creates a copy of the current Todo instance with the provided values
  /// like of a Copy Constructor,
  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? completed,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
