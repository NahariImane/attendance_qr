import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import 'package:pfa_gestion_absence_qrcode/pages/admin/ajouterEtudiant.dart';
import 'package:pfa_gestion_absence_qrcode/pages/admin/ajouterFiliere.dart';
import 'package:pfa_gestion_absence_qrcode/pages/admin/ajouterMatiere.dart';
import 'package:pfa_gestion_absence_qrcode/pages/admin/ajouterProfesseur.dart';
import 'package:pfa_gestion_absence_qrcode/pages/home.dart';
import 'package:pfa_gestion_absence_qrcode/pages/rapport.dart';
import 'package:pfa_gestion_absence_qrcode/pages/scanqr.dart';
import 'package:pfa_gestion_absence_qrcode/pages/teacher.dart';


Future<void> main() async {
 // configureUrl();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyCJq0OkP4XibUfH6ufzSqgmINdAXiL2Pbw",
        appId: "1:614026879471:android:4d5d5f8ec1a94818b9561a",
        messagingSenderId: "614026879471",
        projectId: "absence-qr",)
  );
    runApp(MyApp());

}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color _primaryColor = HexColor('#136D7F');
  Color _hintColor = HexColor('#178CA4');
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: _primaryColor,
        hintColor: _hintColor,
        scaffoldBackgroundColor: Colors.grey.shade100,
        primarySwatch: Colors.grey,
      ),
      home: home(),
      routes: {
        '/scanPage': (context) => CreateScreen(),
        '/Teacher': (context) => const Teacher(),
        '/filiere': (context) => const Filiere(),
        '/matiere': (context) => const Matiere(),
        '/etudiant': (context) => Etudiant(),
        '/professeur': (context) => const Professeur(),
        '/rapport': (context) => const Rapport(),
      },
    );
  }
}
