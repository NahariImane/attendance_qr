import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:pfa_gestion_absence_qrcode/pages/student.dart';
import 'package:pfa_gestion_absence_qrcode/pages/teacher.dart';

import '../utils.dart';
import 'admin/accueil.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isObscure3 = true;

  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();



  final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    double baseWidth = 375;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      child: Image.asset('assets/images/circle.png'),
                    ),
                    Container(
                      child: Text(
                        'Bienvenue !',
                        textAlign: TextAlign.center,
                        style: SafeGoogleFont(
                          'Nunito',
                          fontSize: 22 * ffem,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2 * fem,
                          color: HexColor('#ff178ca4'),
                        ),
                      ),
                    ),
                    Container(
                      // margin: EdgeInsets.fromLTRB(
                      //     1 * fem, 0 * fem, 0 * fem, 2 * fem),
                      width: 226.65 * fem,
                      height: 250 * fem,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13 * fem),
                        child: Image.asset(
                          'assets/images/login.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.50,
              child: Center(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[200],
                            hintText: 'Email',
                            hintStyle: TextStyle(color: Colors.grey.shade600),
                            enabled: true,
                            contentPadding: const EdgeInsets.only(
                                left: 14.0, bottom: 8.0, top: 8.0),
                            focusedBorder: OutlineInputBorder(
                              borderSide: new BorderSide(color: Colors.white),
                              borderRadius: new BorderRadius.circular(10),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: new BorderSide(color: Colors.white),
                              borderRadius: new BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value!.length == 0) {
                              return "Saisir votre email";
                            }
                            if (!RegExp(
                                    "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                .hasMatch(value)) {
                              // return ("Entrez un email valide!");
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: AwesomeSnackbarContent(
                                    title: "Alert",
                                    message: "Entrez un email valide!",
                                    contentType: ContentType.warning,
                                  ),
                                  backgroundColor: Colors.transparent, // Set the background color here
                                ),
                              );
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) {
                            emailController.text = value!;
                          },
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          controller: passwordController,
                          obscureText: _isObscure3,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                                icon: Icon(_isObscure3
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                onPressed: () {
                                  setState(() {
                                    _isObscure3 = !_isObscure3;
                                  });
                                }),
                            filled: true,
                            fillColor: Colors.grey[200],
                            hintText: 'Mot de passe',
                            enabled: true,
                            hintStyle: TextStyle(color: Colors.grey.shade600),
                            contentPadding: const EdgeInsets.only(
                                left: 14.0, bottom: 8.0, top: 15.0),
                            focusedBorder: OutlineInputBorder(
                              borderSide: new BorderSide(color: Colors.white),
                              borderRadius: new BorderRadius.circular(10),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: new BorderSide(color: Colors.white),
                              borderRadius: new BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            RegExp regex = new RegExp(r'^.{6,}$');
                            if (value!.isEmpty) {
                              return "Saisir le mot de passe!";
                            }
                            if (!regex.hasMatch(value)) {
                              // return ("Minimum 6 caracteres.");
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: AwesomeSnackbarContent(
                                    title: "Alert",
                                    message: "Minimum 6 caracteres.",
                                    contentType: ContentType.warning,
                                  ),
                                    backgroundColor: Colors.transparent, // Set the background color here
                                ),
                              );
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) {
                            passwordController.text = value!;
                          },
                          keyboardType: TextInputType.emailAddress,
                        ),

                        SizedBox(
                          height: 20,
                        ),
                        TextButton(
                          // buttonCFu (4:168)
                          onPressed: () {
                            signIn(
                                emailController.text, passwordController.text);
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                          ),
                          child: Container(
                            // width: 200*fem,
                            // height: 60*fem,
                            width: 200,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Color(0xff178ca4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Center(
                                child: Text(
                                  'Connexion',
                                  textAlign: TextAlign.center,
                                  style: SafeGoogleFont(
                                    'Work Sans',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.08 * fem,
                                    color: Color(0xffffffff),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void route() {
    User? user = FirebaseAuth.instance.currentUser;
    var kk = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        if (documentSnapshot.get('role') == "teacher") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Teacher(),
            ),
          );
        } else if (documentSnapshot.get('role') == "admin") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Accueil(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => Student(),
            ),
          );
        }
      } else {
        print('Document does not exist on the database');
      }
    });
  }

  void signIn(String email, String password) async {
    if (_formkey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        route();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AwesomeSnackbarContent(
                title: "Erreur",
                message: "Utilisateur introuvable",
                contentType: ContentType.failure,
              ),
              backgroundColor: Colors.transparent,  // Set the background color here
            ),
          );
          print('No user found for that email.');
          print(e.code);
        } else if (e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AwesomeSnackbarContent(
                title: "Erreur",
                message: "Mot de passe incorrecte",
                contentType: ContentType.failure,
              ),
                backgroundColor: Colors.transparent, // Set the background color here
            ),
          );
          print('Wrong password provided for that user.');
        }

      }
    }
  }
}
