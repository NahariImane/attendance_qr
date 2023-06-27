import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocode/geocode.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'header_widget.dart';
import 'login.dart';

class Student extends StatefulWidget {
  const Student({super.key});

  @override
  State<Student> createState() => _StudentState();
}

class _StudentState extends State<Student> {
  var height, width;
  String formattedTime = DateFormat('kk:mm').format(DateTime.now());
  String hour = DateFormat('a').format(DateTime.now());
  String date ="";
  late Timer _timer;

  var time = DateTime.now();
  var nom_prenom;

  LocationData? currentLocation;
  String address = "";
  String filiere = "";
  String niveau = "";
  String cne = "";

  //********************Location added*************************
  @override
  void initState() {
    super.initState();
    // Initialize French localization data
    _timer =
        Timer.periodic(const Duration(milliseconds: 500), (timer) => _update());

    _getLocation().then((value) {
      getStudentData();
      LocationData? location = value;
      _getAddress(location?.latitude, location?.longitude).then((value) {
        setState(() {
          currentLocation = location;
          address = value;
        });
      });
    });
    print(address);
  }

  Future<void> _update() async {
    if (mounted) {
      await initializeDateFormatting('fr', "");
      String formattedDate = DateFormat('EEEE d MMMM yyyy', 'fr').format(DateTime.now());

      setState(() {
        formattedTime = DateFormat('kk:mm').format(DateTime.now());
        hour = DateFormat('a').format(DateTime.now());
        date = formattedDate;
      });
    }
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
    return "${address.region},${address.city}, ${address.countryName}";
  }
  //*********************************************

  Future<void> getStudentData() async {
    final student = FirebaseAuth.instance.currentUser;
    final studentId = student?.uid;
    final emailStudent = student?.email;
    String nom = "";
    String prenom = "";

    var documentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(studentId)
        .get();
    if (documentSnapshot.exists) {
      if (documentSnapshot.get('email') == emailStudent) {
          nom = documentSnapshot.get('nom');
          prenom = documentSnapshot.get('prenom');
        setState(() {
          filiere = documentSnapshot.get('filiere');
          niveau = documentSnapshot.get('niveau');
          cne = documentSnapshot.get('cne');
        });
      }
    }
    nom = nom[0].toUpperCase() + nom.substring(1).toLowerCase();
    prenom = prenom[0].toUpperCase() + prenom.substring(1).toLowerCase();

    setState(() {
      nom_prenom = "$nom $prenom";
    });
  }

  @override
  Widget build(BuildContext context) {
    final student = FirebaseAuth.instance.currentUser;
    final emailStudent = student?.email;

    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            "Espace étudiant",
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
              height: 100,
              child: const HeaderWidget(100, false, Icons.house_rounded),
            ),
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.fromLTRB(25, 10, 25, 10),
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(width: 5, color: Colors.white),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 20,
                          offset: Offset(5, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    nom_prenom ?? "",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ), ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    "$date - $formattedTime",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500,color: Colors.grey.shade600),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: <Widget>[
                        Card(
                          child: Container(
                            alignment: Alignment.topLeft,
                            padding: EdgeInsets.all(15),
                            child: Column(
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    ...ListTile.divideTiles(
                                      color: Colors.grey.shade400,
                                      tiles: [
                                        ListTile(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 10),
                                          leading: Icon(Icons.my_location,color: Theme.of(context).primaryColor,),
                                          title: Text("Localisation",style: TextStyle(fontWeight: FontWeight.w600)),
                                          subtitle: Text(address != "Throttled! See geocode.xyz/pricing, null, Throttled! See geocode.xyz/pricing"?address:"Erreur! Essayer de vous reconnecter."),
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.email,color: Theme.of(context).primaryColor,),
                                          title: Text("Email",style: TextStyle(fontWeight: FontWeight.w600)),
                                          subtitle: Text(emailStudent ?? ' '),
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.grade,color: Theme.of(context).primaryColor,),
                                          title: Text("Niveau",style: TextStyle(fontWeight: FontWeight.w600)),
                                          subtitle: Text("$filiere $niveau"),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            const SizedBox(height: 25.0),
                            const Text(
                              'Veuillez scanner le code QR pour confirmer votre présence',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.05),
                            ),
                            const SizedBox(height: 25.0),
                            ElevatedButton(
                              onPressed: () {
                                print('Student Location ${address}');
                                CollectionReference col =
                                FirebaseFirestore.instance.collection('qrcode');
                                FlutterBarcodeScanner.scanBarcode(
                                    '#2A99CF', 'cancel', true, ScanMode.QR)
                                    .then((value) {
                                  col.doc(value).get().then((docSnapshot) {
                                    if (docSnapshot.exists) {
                                      List<dynamic> students =
                                          docSnapshot.get('students') ?? [];
                                      String teacherAddress =
                                          docSnapshot.get('location') ?? '';

                                      // Vérifier si le nom_prenom existe déjà dans le tableau students
                                      bool isExisting = students.contains(nom_prenom);

                                      if (!isExisting) {
                                        // if the teacher s address and student address are the same then the student presence is
                                        // approved (they are in the same class) so the student is added to the DB
                                        if (address == teacherAddress) {
                                          // Ajouter la nouvelle valeur au tableau students
                                          students.add(nom_prenom);
                                          col.doc(value).update({
                                            'students': students,
                                            'studentLocation': address,
                                          }).catchError((error) {
                                            print(
                                                'Erreur lors de la mise à jour du document Firestore: $error');
                                          });
                                        } else {
                                          print(
                                              'Le nom_prenom existe déjà dans le tableau students');
                                        }
                                      }
                                    }
                                  });
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                Theme.of(context).hintColor, // Text color
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(8), // Rounded corners
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16, // Text size
                                  fontWeight: FontWeight.w500, // Text weight
                                  letterSpacing: 1,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 14), // Button padding
                              ),
                              child: Text(('Scanner')),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    const CircularProgressIndicator();
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }
}
