import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rider_app/src/app.dart';
import 'package:rider_app/src/blocs/auth/auth_bloc.dart';
import 'package:rider_app/src/repositories/auth_repository.dart';
import 'package:rider_app/src/repositories/ride_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final authRepository = AuthRepository();
  final rideRepository = RideRepository();
  
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: rideRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            )..add(AppStarted()),
          ),
        ],
        child: const TaxiApp(),
      ),
    ),
  );
}