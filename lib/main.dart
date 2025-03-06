import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_firebase_app/core/services/auth_service.dart';
import 'package:my_firebase_app/core/theme/theme_provider.dart';
import 'package:my_firebase_app/modules/auth/blocs/auth_bloc.dart';
import 'package:my_firebase_app/modules/auth/screens/auth_wrapper.dart';
import 'package:my_firebase_app/modules/todo/bloc/todo_bloc.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              AuthBloc(AuthService())..add(AuthCheckRequested()),
        ),
        BlocProvider(
          create: (context) => TodoBloc(firestore: FirebaseFirestore.instance),
        ),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return CupertinoApp(
            debugShowCheckedModeBanner: false,
            theme: CupertinoThemeData(
              brightness:
                  themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
            ),
            home: AuthWrapper(),
          );
        },
      ),
    );
  }
}
