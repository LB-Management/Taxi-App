import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rider_app/src/blocs/auth/auth_bloc.dart';
import 'package:rider_app/src/screens/auth_screen.dart';
import 'package:rider_app/src/screens/home_screen.dart';
import 'package:rider_app/src/screens/splash_screen.dart';

class TaxiApp extends StatelessWidget {
  const TaxiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yellow & Black Taxi',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        primaryColor: const Color(0xFFFFD700),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.yellow,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthInitial) {
            return const SplashScreen();
          }
          if (state is Authenticated) {
            return const HomeScreen();
          }
          if (state is Unauthenticated) {
            return const AuthScreen();
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}