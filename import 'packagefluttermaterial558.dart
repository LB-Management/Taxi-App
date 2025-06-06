import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admin_panel/src/app.dart';
import 'package:admin_panel/src/blocs/auth/auth_bloc.dart';
import 'package:admin_panel/src/repositories/admin_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final adminRepository = AdminRepository();
  
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: adminRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              adminRepository: context.read<AdminRepository>(),
            )..add(AppStarted()),
          ),
        ],
        child: const AdminApp(),
      ),
    ),
  );
}