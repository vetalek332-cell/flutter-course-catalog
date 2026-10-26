import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/repositories/auth_repository.dart';
import 'firebase_options.dart';
import 'logic/auth/auth_cubit.dart';
import 'logic/theme/theme_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final prefs = await SharedPreferences.getInstance();
  runApp(CatalogApp(prefs: prefs));
}

class CatalogApp extends StatelessWidget {
  const CatalogApp({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit(prefs)..load()),
        BlocProvider(create: (_) => AuthCubit(AuthRepository())..start()),
      ],
      child: const AppView(),
    );
  }
}
