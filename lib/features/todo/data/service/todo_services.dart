import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_app_kabreet/features/todo/data/model/todo_categories_model.dart';
import 'package:todo_app_kabreet/features/todo/data/model/todo_model.dart';

class TodoServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get todos stream for a specific user
  Stream<List<TodoItem>> getTodosStream(String userId) {
    return _firestore
        .collection('todos')
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TodoItem.fromMap(doc.data());
      }).toList();
    });
  }

  // Add a new todo
  Future<void> addTodo(TodoItem todo) async {
    try {
      await _firestore.collection('todos').doc(todo.id).set(todo.toMap());
    } catch (e) {
      print('Error adding todo: $e');
      throw e;
    }
  }

  // Update a todo
  Future<void> updateTodo(TodoItem todo) async {
    try {
      final updatedTodo = todo.copyWith(updatedAt: DateTime.now());
      await _firestore
          .collection('todos')
          .doc(todo.id)
          .update(updatedTodo.toMap());
    } catch (e) {
      print('Error updating todo: $e');
      throw e;
    }
  }

  // Delete a todo
  Future<void> deleteTodo(String todoId) async {
    try {
      await _firestore.collection('todos').doc(todoId).delete();
    } catch (e) {
      print('Error deleting todo: $e');
      throw e;
    }
  }

  // Toggle todo completion
  Future<void> toggleTodoCompletion(String todoId, bool isCompleted) async {
    try {
      await _firestore.collection('todos').doc(todoId).update({
        'isCompleted': isCompleted,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('Error toggling todo completion: $e');
      throw e;
    }
  }

  // Get todos by category
  Stream<List<TodoItem>> getTodosByCategory(
      String userId, TodoCategory category) {
    return _firestore
        .collection('todos')
        .where('userId', isEqualTo: userId)
        .where('category', isEqualTo: category.toString().split('.').last)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TodoItem.fromMap(doc.data());
      }).toList();
    });
  }

  // Batch operations for better performance
  Future<void> batchUpdateTodos(List<TodoItem> todos) async {
    final batch = _firestore.batch();

    for (final todo in todos) {
      final docRef = _firestore.collection('todos').doc(todo.id);
      batch.update(docRef, todo.toMap());
    }

    await batch.commit();
  }
}
