import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app_kabreet/features/auth/presentation/manager/auth_provider.dart';
import 'package:todo_app_kabreet/features/auth/presentation/pages/auth_page.dart';
import 'package:todo_app_kabreet/features/todo/presentation/manager/todo_provider.dart';
import 'package:todo_app_kabreet/features/todo/presentation/pages/todo_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading while checking auth state
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If user is authenticated, show home screen
        // If user is authenticated, initialize todo provider and show home screen
        if (authProvider.isAuthenticated && authProvider.user != null) {
          // Initialize todos listener with user ID
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<TodoProvider>(context, listen: false)
                .initializeTodosListener(authProvider.user!.uid);
          });

          return const HomeScreen();
        }

        // If not authenticated, show login screen
        return const LoginScreen();
      },
    );
  }
}
