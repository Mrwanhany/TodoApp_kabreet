import 'package:flutter/foundation.dart';
import 'package:todo_app_kabreet/features/todo/data/model/todo_categories_model.dart';
import 'package:todo_app_kabreet/features/todo/data/model/todo_model.dart';
import 'package:todo_app_kabreet/features/todo/data/model/todo_periorty.dart';
import 'dart:async';

import 'package:todo_app_kabreet/features/todo/data/service/todo_services.dart';

class TodoProvider with ChangeNotifier {
  final TodoServices _todoServices = TodoServices();
  List<TodoItem> _todos = [];
  StreamSubscription<List<TodoItem>>? _todosSubscription;
  bool _isLoading = false;

  List<TodoItem> get todos => _todos;
  bool get isLoading => _isLoading;

  // Initialize real-time listener for todos
  void initializeTodosListener(String userId) {
    _todosSubscription?.cancel();
    _todosSubscription = _todoServices.getTodosStream(userId).listen(
      (todos) {
        print('Todos updated: $todos');
        _todos = todos;
        notifyListeners();
      },
      onError: (error) {
        print('Todos updated: $error');
        print('Error listening to todos: $error');
      },
    );
  }

  // Stop listening to todos (call when user signs out)
  void disposeTodosListener() {
    _todosSubscription?.cancel();
    _todos.clear();
    notifyListeners();
  }

  // Add a new todo
  Future<void> addTodo({
    required String title,
    required TodoCategory category,
    required DateTime dueDate,
    required Priority priority,
    required String userId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final todo = TodoItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        category: category,
        dueDate: dueDate,
        priority: priority,
        userId: userId,
        createdAt: now,
        updatedAt: now,
      );
      print('Adding todo: $todo');

      await _todoServices.addTodo(todo);
    } catch (e) {
      print('Error adding todo: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update a todo
  Future<void> updateTodo(TodoItem todo) async {
    try {
      await _todoServices.updateTodo(todo);
    } catch (e) {
      print('Error updating todo: $e');
      rethrow;
    }
  }

  // Delete a todo
  Future<void> deleteTodo(String todoId) async {
    try {
      await _todoServices.deleteTodo(todoId);
    } catch (e) {
      print('Error deleting todo: $e');
      rethrow;
    }
  }

  // Toggle todo completion
  Future<void> toggleTodoCompletion(String todoId, bool isCompleted) async {
    try {
      await _todoServices.toggleTodoCompletion(todoId, isCompleted);
    } catch (e) {
      print('Error toggling todo completion: $e');
      rethrow;
    }
  }

  // Filter todos by category
  List<TodoItem> getTodosByCategory(TodoCategory? category) {
    if (category == null) return _todos;
    return _todos.where((todo) => todo.category == category).toList();
  }

  // Get completed todos
  List<TodoItem> getCompletedTodos() {
    return _todos.where((todo) => todo.isCompleted).toList();
  }

  // Get pending todos
  List<TodoItem> getPendingTodos() {
    return _todos.where((todo) => !todo.isCompleted).toList();
  }

  // Get overdue todos
  List<TodoItem> getOverdueTodos() {
    final now = DateTime.now();
    return _todos.where((todo) {
      return !todo.isCompleted && todo.dueDate.isBefore(now);
    }).toList();
  }

  @override
  void dispose() {
    _todosSubscription?.cancel();
    super.dispose();
  }
}
