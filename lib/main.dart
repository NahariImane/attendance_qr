import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pfa_gestion_absence_qrcode/pages/admin/accueil.dart';
import 'package:pfa_gestion_absence_qrcode/pages/admin/ajouterEtudiant.dart';
import 'package:pfa_gestion_absence_qrcode/pages/admin/ajouterFiliere.dart';
import 'package:pfa_gestion_absence_qrcode/pages/admin/ajouterMatiere.dart';
import 'package:pfa_gestion_absence_qrcode/pages/admin/ajouterProfesseur.dart';
import 'package:pfa_gestion_absence_qrcode/pages/home.dart';
import 'package:pfa_gestion_absence_qrcode/pages/scanqr.dart';


//import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:pfa_gestion_absence_qrcode/pages/login.dart';
import 'package:pfa_gestion_absence_qrcode/pages/prof/accueilProf.dart';
import 'package:pfa_gestion_absence_qrcode/pages/student.dart';
import 'package:pfa_gestion_absence_qrcode/pages/teacher.dart';

/*import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'utiles/nonweb_url_strategy.dart'
if (dart.library.html) 'utils/web_url_strategy.dart';*/


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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue[900],
      ),
      home: home(),
      routes: {
        '/scanPage': (context) => CreateScreen(),
        '/Teacher': (context) => const Teacher(),
        '/filiere': (context) => const Filiere(),
        '/matiere': (context) => const Matiere(),
        '/etudiant': (context) => const Etudiant(),
        '/professeur': (context) => const Professeur(),
      },
    );
  }
/*
//partie Ouissal
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyCJq0OkP4XibUfH6ufzSqgmINdAXiL2Pbw",
          appId: "1:614026879471:android:4d5d5f8ec1a94818b9561a",
          messagingSenderId: "614026879471",
          projectId: "absence-qr"
      )
  );

  runApp(MaterialApp(
    initialRoute: '/',
    routes:{
      '/': (context) => LoginPage(),
      '/accueilProf': (context) => const AccueilProf(),
      '/filiere': (context) =>const Filiere(),
      '/matiere': (context) =>const Matiere(),
      '/etudiant': (context) =>const Etudiant(),
      '/professeur': (context) =>const Professeur(),
    },
  ));
}*/
}
