import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocode/geocode.dart';
import 'package:location/location.dart';

import 'login.dart';

class Student extends StatefulWidget {
  const Student({super.key});

  @override
  State<Student> createState() => _StudentState();
}

class _StudentState extends State<Student> {
  var height,width;

  var time = DateTime.now();
  var nom_prenom;

  LocationData? currentLocation;
  String address = "";

  //********************Location added*************************
  @override
  void initState() {
    super.initState();
    getStudentName();
    _getLocation().then((value) {
      LocationData? location = value;
      _getAddress(location?.latitude, location?.longitude)
          .then((value) {
        setState(() {
          currentLocation = location;
          address = value;
        });
      });
    });
  }

  Future<LocationData?> _getLocation() async {
    Location location = Location();
    LocationData _locationData;

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    _locationData = await location.getLocation();
    return _locationData;
  }

  Future<String> _getAddress(double? lat, double? lang) async {
    if (lat == null || lang == null) return "";
    GeoCode geoCode = GeoCode();
    Address address =
    await geoCode.reverseGeocoding(latitude: lat, longitude: lang);
    return "${address.streetAddress}, ${address.city}, ${address.countryName}, ${address.postal}";
  }
  //*********************************************

  Future<void> getStudentName() async {
    final student = FirebaseAuth.instance.currentUser;
    final studentId = student?.uid;
    final emailStudent = student?.email;
    String nom="";
    String prenom="";
    var documentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(studentId)
        .get();
    if (documentSnapshot.exists) {
      if (documentSnapshot.get('email') == emailStudent) {
        nom = documentSnapshot.get('nom');
        prenom = documentSnapshot.get('prenom');
      }
    }
    setState(() {
      nom_prenom= nom+" "+ prenom;
    });

  }



  @override
  Widget build(BuildContext context) {
    final student = FirebaseAuth.instance.currentUser;
    final studentId = student?.uid;
    final emailStudent = student?.email;
    //final nom_prenom = student?.displayName;
    getStudentName();



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
                  onPressed: () {
                    CollectionReference col = FirebaseFirestore.instance.collection('qrcode');
                    FlutterBarcodeScanner.scanBarcode('#2A99CF', 'cancel', true, ScanMode.QR).then((value) {
                      col.doc(value).get().then((docSnapshot) {
                        if (docSnapshot.exists) {
                          List<dynamic> students = docSnapshot.get('students') ?? [];
                          String teacherAddress = docSnapshot.get('address') ?? '';

                          // Vérifier si le nom_prenom existe déjà dans le tableau students
                          bool isExisting = students.contains(nom_prenom);

                          if (!isExisting) {
                            // if the teacher s address and student address are the same then the student presence is
                            // approved (they are in the same class) so the student is added to the DB
                            if(address == teacherAddress) {
                                // Ajouter la nouvelle valeur au tableau students
                                students.add(nom_prenom);

                                col.doc(value).update({
                                  'students': students,
                                }).catchError((error) {
                                  print('Erreur lors de la mise à jour du document Firestore: $error');
                                });
                              } else {
                                print('Le nom_prenom existe déjà dans le tableau students');
                              }
                          }
                        }
                      });
                    });
                  },
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
              )
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
        ),);}
}