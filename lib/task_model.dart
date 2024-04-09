import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final String priority;

  @HiveField(3)
  final DateTime dueDate;

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  final DateTime createdDate;

  Task({
    required this.title,
    this.description = '',
    this.priority = 'Low',
    required this.dueDate,
    this.isCompleted = false,
    required this.createdDate,
  });
}
