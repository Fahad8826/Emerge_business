import 'package:emerge_business/Authentication/authservice.dart';
import 'package:emerge_business/Authentication/signin.dart';
import 'package:emerge_business/Authentication/signup.dart';
import 'package:emerge_business/admin.dart';
import 'package:emerge_business/home.dart';
import 'package:emerge_business/profile.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => AuthWrapper(),
        '/signup': (context) => SignupPage(),
        '/login': (context) => LoginPage(),
        '/user': (context) => Home(),
        '/admin': (context) => AdminDashboard(),
        '/profile': (context) => ProfilePage(),
      },

      debugShowCheckedModeBanner: false,
    );
  }
}
