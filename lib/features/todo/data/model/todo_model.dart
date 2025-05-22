// lib/models/todo_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_app_kabreet/features/todo/data/model/todo_categories_model.dart';
import 'package:todo_app_kabreet/features/todo/data/model/todo_periorty.dart';

class TodoItem {
  final String id;
  final String title;
  final TodoCategory category;
  final DateTime dueDate;
  final Priority priority;
  final bool isCompleted;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  TodoItem({
    required this.id,
    required this.title,
    required this.category,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category.toString().split('.').last,
      'dueDate': Timestamp.fromDate(dueDate),
      'priority': priority.toString().split('.').last,
      'isCompleted': isCompleted,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory TodoItem.fromMap(Map<String, dynamic> map) {
    return TodoItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      category: TodoCategory.values.firstWhere(
        (e) => e.toString().split('.').last == map['category'],
        orElse: () => TodoCategory.personal,
      ),
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      priority: Priority.values.firstWhere(
        (e) => e.toString().split('.').last == map['priority'],
        orElse: () => Priority.medium,
      ),
      isCompleted: map['isCompleted'] ?? false,
      userId: map['userId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  TodoItem copyWith({
    String? id,
    String? title,
    TodoCategory? category,
    DateTime? dueDate,
    Priority? priority,
    bool? isCompleted,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
