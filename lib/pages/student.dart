import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login.dart';

class Student extends StatefulWidget {
  const Student({super.key});

  @override
  State<Student> createState() => _StudentState();
}

class _StudentState extends State<Student> {
  var qrstr = "";
  var height,width;

  var time = DateTime.now();


  @override
  Widget build(BuildContext context) {
    final student = FirebaseAuth.instance.currentUser;
    final studentId = student?.uid;
    final emailStudent = student?.email;

    
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        //title: Text("Student"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            onPressed: () {
              logout(context);
            },
            icon: Icon(
              Icons.logout,
            ),
          )
        ],
      ),



      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 250,
                width: double.infinity,
                color: Colors.teal,
                child:  Column(
                  children: [
                    SizedBox(height: 50.0),
                    const Text(
                      'Student',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        fontSize: 28.0,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20.0),
                    const Icon(
                      Icons.watch_later_outlined,
                      size: 60.0,
                      color: Colors.white,
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      '${time.hour} : ${time.minute}    -    ${time.day} / ${time.month} / ${time.year}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 25.0),

              const Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  'Veuillez scanner le code QR fournit par votre professeur pour confirmer votre présence ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),
              const SizedBox(height: 25.0),
              Container(
                width: 180,
                height: 40,
                child:
                ElevatedButton(
                    onPressed:(){ CollectionReference col = FirebaseFirestore.instance.collection('qrcode');
                    FlutterBarcodeScanner.scanBarcode('#2A99CF', 'cancel', true, ScanMode.QR).then((value){
                    setState(() {
                      col.add({
                        'student': emailStudent,
                  });
                  qrstr = 'présence enregistré';
                });
              });},
                    child:
                    Text(('Scanner')),
                    style: ElevatedButton.styleFrom(
                     foregroundColor: Colors.white,
                      backgroundColor: Colors.teal, // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Rounded corners
                    ),
                    textStyle: TextStyle(
                      fontSize: 20, // Text size
                      fontWeight: FontWeight.bold, // Text weight
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Button padding
                ),
                ),
              ),
            ],
          ),


        ],
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

  /*Future <void>scanQr()async{
    try{
      CollectionReference col = FirebaseFirestore.instance.collection('qrcode');
      FlutterBarcodeScanner.scanBarcode('#2A99CF', 'cancel', true, ScanMode.QR).then((value){
        setState(() {
          // Ajouter a la base de donnees id de l'etudiant , prof , seance , date...
          //autoriser l'application à utiliser l'heure et la date du device
          col.add({
            'student': emailStudent,
          });
          qrstr = 'présence enregistré';
        });
      });
    }catch(e){
      setState(() {
        qrstr='unable to read this';
      });
    }
  }*/
}