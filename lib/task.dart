class Task {
  final String title;
  final String description;
  final String priority;
  final DateTime dueDate;
  bool isCompleted;
  final DateTime createdDate;

  Task({
    required this.title,
    this.description = '',
    this.priority = 'Low',
    required this.dueDate,
    this.isCompleted = false,
    required this.createdDate,
  });

  static Task fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      description: json['description'] ?? '',
      priority: json['priority'] ?? 'Low',
      dueDate: DateTime.parse(json['dueDate']),
      isCompleted: json['isCompleted'] ?? false,
      createdDate: DateTime.parse(json['createdDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'priority': priority,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'createdDate': createdDate.toIso8601String(),
    };
  }
}