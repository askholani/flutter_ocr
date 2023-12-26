import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import './views/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyCbFizye9vMTM805BcHSw0Q1Q',
          appId: '1:936542307130:android:e8417793371bae0e6b0603',
          messagingSenderId: '936542307130',
          projectId: 'crud-3178f',
          storageBucket: 'crud-3178f.appspot.com'));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const NeumorphicApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      darkTheme: NeumorphicThemeData(
        baseColor: Color(0xFF3E3E3E),
        lightSource: LightSource.topLeft,
        depth: 6,
      ),
      home: HomePage(),
    );
  }
}
