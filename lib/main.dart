import 'package:shop_app_admin/screens/admin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(AdminApp());
}

class AdminApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //theme: FlexColorScheme.dark(scheme: FlexScheme.mandyRed).toTheme,
      debugShowCheckedModeBanner: false,
      home: Admin(),
    );
  }
}