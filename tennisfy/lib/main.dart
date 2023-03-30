import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tennisfy/helpers/widget_tree.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
 
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color.fromARGB(255, 41, 41, 41),
          secondary: const Color(0xff9ec891),
          tertiary: const Color.fromARGB(255, 255, 255, 255),
        ),
        textTheme: const TextTheme(
          //body medium
          bodyText1: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Color.fromARGB(255, 41, 41, 41),
              fontWeight: FontWeight.w600),
          //body bold
          bodyText2: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Color.fromARGB(255, 41, 41, 41),
              fontWeight: FontWeight.bold),
          //title big
          headline1: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 40,
              color: Color.fromARGB(255, 41, 41, 41),
              fontWeight: FontWeight.w900),
          //text for green big buttons
          button: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 28,
              color: Color.fromARGB(255, 255, 255, 255),
              fontWeight: FontWeight.w900),
        ),
      ),
      home: const WidgetTree(),
    );
  }
}
