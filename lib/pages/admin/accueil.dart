import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pfa_gestion_absence_qrcode/pages/admin/ajouterMatiere.dart';
import 'package:slide_to_confirm/slide_to_confirm.dart';
import '../header_widget.dart';
import '../login.dart';
import 'ajouterEtudiant.dart';
import 'ajouterFiliere.dart';
import 'ajouterProfesseur.dart';


class Accueil extends StatefulWidget {
  const Accueil({Key? key}) : super(key: key);

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  @override
  Widget build(BuildContext context) {

    debugShowCheckedModeBanner: false;
    bool isFinished = false;
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            "Espace administrateur",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false, // Remove the back button
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Theme.of(context).primaryColor,
                    Theme.of(context).hintColor.withOpacity(0.8),
                  ])),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: IconButton(
              onPressed: () {
                logout(context);
              },
              icon: const Icon(
                Icons.logout,
              ),
              color: Colors.white,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: 150,
              child: HeaderWidget(150, false, Icons.person_add_alt_1_rounded),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(25, 50, 25, 10),
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        child: Stack(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                    width: 5, color: Colors.white),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 20,
                                    offset: const Offset(5, 5),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.person,
                                color: Colors.grey.shade300,
                                size: 80.0,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(80, 80, 0, 0),
                              child: Icon(
                                Icons.add_circle,
                                color: Colors.grey.shade700,
                                size: 25.0,
                              ),
                            ),
                          ],
                        ),
                      ),
//*************************************************************************************************
                      SizedBox(height: 70,),
                      ConfirmationSlider(
                        height: 55,
                        width: 300,
                        backgroundColor: Color(0xFFF5F5F5),
                        foregroundColor: Color(0XFF136D7F),
                        iconColor: Color(0xff136D7F),
                        text: ' Ajouter filière',
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                        onConfirmation: () => Navigator.push(context, MaterialPageRoute(builder: (context) =>Filiere(),),),
                      ),
                      SizedBox(height: 15,),
                      ConfirmationSlider(
                        height: 55,
                        width: 300,
                        backgroundColor: Color(0xFFF5F5F5),
                        foregroundColor: Color(0XFF136D7F),
                        iconColor: Color(0xff136D7F),
                        text: ' Ajouter matière',
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                        onConfirmation: () => Navigator.push(context, MaterialPageRoute(builder: (context) =>Matiere(),),),
                      ),
                      SizedBox(height: 15,),
                      ConfirmationSlider(
                        height: 55,
                        width: 300,
                        backgroundColor: Color(0xFFF5F5F5),
                        foregroundColor: Color(0XFF136D7F),
                        iconColor: Color(0xff136D7F),
                        text: ' Ajouter étudiant',
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                        onConfirmation: () => Navigator.push(context, MaterialPageRoute(builder: (context) =>Etudiant(),),),
                      ),
                      SizedBox(height: 15,),
                      ConfirmationSlider(
                        height: 55,
                        width: 300,
                        backgroundColor: Color(0xFFF5F5F5),
                        foregroundColor: Color(0XFF136D7F),
                        iconColor: Color(0xff136D7F),
                        text: ' Ajouter professeur',
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                        onConfirmation: () => Navigator.push(context, MaterialPageRoute(builder: (context) =>Professeur(),),),
                      )

//=================================================================================================
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> logout(BuildContext context) async {
    CircularProgressIndicator();
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }
}
