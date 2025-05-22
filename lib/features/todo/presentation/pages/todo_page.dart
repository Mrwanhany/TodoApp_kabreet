// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app_kabreet/features/auth/presentation/manager/auth_provider.dart';
import 'package:todo_app_kabreet/features/todo/data/model/todo_categories_model.dart';
import 'package:todo_app_kabreet/features/todo/data/model/todo_model.dart';
import 'dart:math' as math;

import 'package:todo_app_kabreet/features/todo/data/model/todo_periorty.dart';
import 'package:todo_app_kabreet/features/todo/presentation/manager/todo_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fabAnimationController;
  late AnimationController _tabChangeController;
  late Animation<double> _tabChangeAnimation;

  final TextEditingController _todoController = TextEditingController();
  final ValueNotifier<DateTime> _selectedDate = ValueNotifier<DateTime>(
    DateTime.now(),
  );
  final ValueNotifier<bool> _isDatePickerVisible = ValueNotifier<bool>(false);
  final ValueNotifier<Priority> _selectedPriority = ValueNotifier<Priority>(
    Priority.medium,
  );

  int _previousTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);

    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _tabChangeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _tabChangeAnimation = CurvedAnimation(
      parent: _tabChangeController,
      curve: Curves.easeInOut,
    );
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      _previousTabIndex = _tabController.previousIndex;
      _tabChangeController.reset();
      _tabChangeController.forward();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _fabAnimationController.dispose();
    _tabChangeController.dispose();
    _todoController.dispose();
    _selectedDate.dispose();
    _isDatePickerVisible.dispose();
    _selectedPriority.dispose();
    super.dispose();
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<void> _addTodo() async {
    if (_todoController.text.isNotEmpty) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final todoProvider = Provider.of<TodoProvider>(context, listen: false);

      if (authProvider.user != null) {
        try {
          await todoProvider.addTodo(
            title: _todoController.text,
            category: _tabController.index == 0
                ? TodoCategory.personal
                : TodoCategory.values[_tabController.index - 1],
            dueDate: _selectedDate.value,
            priority: _selectedPriority.value,
            userId: authProvider.user!.uid,
          );

          _todoController.clear();
          _fabAnimationController.reverse();
          _isDatePickerVisible.value = false;

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 10),
                    Text("Task added successfully"),
                  ],
                ),
                backgroundColor: Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(8),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          print("Error adding task: $e");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Error adding task: $e"),
                backgroundColor: Colors.red.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(8),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      } else {
        print("User not authenticated");
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).primaryColor,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate.value) {
      _selectedDate.value = picked;
    }
  }

  void _toggleFab() {
    if (_fabAnimationController.isCompleted) {
      _fabAnimationController.reverse();
    } else {
      _fabAnimationController.forward();
    }
  }

  Widget _buildAddTodoSheet() {
    return AnimatedBuilder(
      animation: _fabAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _fabAnimationController.value) * 300),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                TextField(
                  controller: _todoController,
                  decoration: InputDecoration(
                    hintText: "What needs to be done?",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.task_alt),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                SizedBox(height: 16.h),
                ValueListenableBuilder<DateTime>(
                  valueListenable: _selectedDate,
                  builder: (context, date, child) {
                    return ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text("Due Date"),
                      subtitle: Text(
                        "${date.day}/${date.month}/${date.year}",
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _selectDate,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    );
                  },
                ),
                SizedBox(height: 16.h),
                ValueListenableBuilder<Priority>(
                  valueListenable: _selectedPriority,
                  builder: (context, priority, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Priority",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: Priority.values.map((p) {
                            final isSelected = p == priority;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => _selectedPriority.value = p,
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 4.h),
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? _getPriorityColor(p).withOpacity(0.2)
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? _getPriorityColor(p)
                                          : Colors.grey.shade300,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Text(
                                    p.name.toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isSelected
                                          ? _getPriorityColor(p)
                                          : Colors.grey.shade600,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _todoController.clear();
                          _fabAnimationController.reverse();
                        },
                        child: const Text("Cancel"),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _addTodo();
                        },
                        child: const Text("Add Task"),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Colors.green;
      case Priority.medium:
        return Colors.orange;
      case Priority.high:
        return Colors.red;
    }
  }

  Widget _buildTodoList(TodoCategory category) {
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        final todos = todoProvider.getTodosByCategory(category);

        if (todos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getCategoryIcon(category),
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 16.h),
                Text(
                  "No ${category.name} tasks yet",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Tap the + button to add your first task",
                  style: TextStyle(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return AnimatedBuilder(
          animation: _tabChangeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                (_tabController.index > _previousTabIndex ? 1 : -1) *
                    50 *
                    (1 - _tabChangeAnimation.value),
                0,
              ),
              child: Opacity(
                opacity: _tabChangeAnimation.value,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return _buildTodoCard(todo, index);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTodoCard(TodoItem todo, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: GestureDetector(
            onTap: () => _toggleTodoComplete(todo, todo.isCompleted),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: todo.isCompleted ? Colors.green : Colors.grey.shade400,
                  width: 2,
                ),
                color: todo.isCompleted ? Colors.green : Colors.transparent,
              ),
              child: todo.isCompleted
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
              color: todo.isCompleted ? Colors.grey.shade500 : null,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (todo.dueDate != null) ...[
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      "${todo.dueDate!.day}/${todo.dueDate!.month}/${todo.dueDate!.year}",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color: _getPriorityColor(todo.priority).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  todo.priority.name.toUpperCase(),
                  style: TextStyle(
                    color: _getPriorityColor(todo.priority),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _editTodo(todo);
                  break;
                case 'delete':
                  _deleteTodo(todo);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8.w),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8.w),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleTodoComplete(TodoItem todo, bool completed) {
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);
    todoProvider.toggleTodoCompletion(todo.id, completed);
  }

  void _editTodo(TodoItem todo) {
    // Implement edit functionality
    _todoController.text = todo.title;
    _selectedDate.value = todo.dueDate;
    _selectedPriority.value = todo.priority;
    _fabAnimationController.forward();
  }

  void _deleteTodo(TodoItem todo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final todoProvider =
                  Provider.of<TodoProvider>(context, listen: false);
              todoProvider.deleteTodo(todo.id);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(TodoCategory category) {
    switch (category) {
      case TodoCategory.personal:
        return Icons.person;
      case TodoCategory.work:
        return Icons.work;
      case TodoCategory.shopping:
        return Icons.shopping_cart;
      case TodoCategory.education:
        throw Icons.book;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Tasks'),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  // Implement search functionality
                },
              ),
              IconButton(
                icon: CircleAvatar(
                  radius: 16,
                  backgroundImage: authProvider.user?.photoURL != null
                      ? NetworkImage(authProvider.user!.photoURL!)
                      : null,
                  child: authProvider.user?.photoURL == null
                      ? Text(
                          authProvider.user?.displayName
                                  ?.substring(0, 1)
                                  .toUpperCase() ??
                              'U',
                          style: const TextStyle(fontSize: 14),
                        )
                      : null,
                ),
                onPressed: () {
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (context) => const ProfileScreen(),
                  //   ),
                  // );
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(
                  icon: Icon(_getCategoryIcon(TodoCategory.personal)),
                  text: 'Personal',
                ),
                Tab(
                  icon: Icon(_getCategoryIcon(TodoCategory.work)),
                  text: 'Work',
                ),
                Tab(
                  icon: Icon(_getCategoryIcon(TodoCategory.shopping)),
                  text: 'Shopping',
                ),
                // Tab(
                //   icon: Icon(_getCategoryIcon(TodoCategory.health)),
                //   text: 'Health',
                // ),
                const Tab(
                  icon: Icon(Icons.all_inclusive),
                  text: 'All',
                ),
              ],
            ),
          ),
          body: Stack(
            children: [
              TabBarView(
                controller: _tabController,
                children: [
                  _buildTodoList(TodoCategory.personal),
                  _buildTodoList(TodoCategory.work),
                  _buildTodoList(TodoCategory.shopping),
                  _buildTodoList(TodoCategory.shopping),
                  // _buildTodoList(TodoCategory.health),
                  // _buildAllTodosList(),
                ],
              ),
              if (_fabAnimationController.value > 0)
                GestureDetector(
                  onTap: () => _fabAnimationController.reverse(),
                  child: Container(
                    color: Colors.black.withOpacity(
                      0.3 * _fabAnimationController.value,
                    ),
                  ),
                ),
              if (_fabAnimationController.value > 0)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildAddTodoSheet(),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _toggleFab,
            child: AnimatedRotation(
              turns: _fabAnimationController.value * 0.125,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                _fabAnimationController.isCompleted ? Icons.close : Icons.add,
              ),
            ),
          ),
        );
      },
    );
  }
}
