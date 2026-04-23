import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/workout_provider.dart';
import 'screens/main_navigation_screen.dart';

void main() {
  runApp(const NewSpartansApp());
}

class NewSpartansApp extends StatelessWidget {
  const NewSpartansApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WorkoutProvider(),
      child: MaterialApp(
        title: 'New Spartans',
        theme: AppTheme.darkTheme,
        home: const MainNavigationScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
