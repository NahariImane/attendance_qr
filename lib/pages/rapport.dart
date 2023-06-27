import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocode/geocode.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'access_phone_storage.dart';
import 'header_widget.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'login.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class Rapport extends StatefulWidget {
  const Rapport({Key? key}) : super(key: key);

  @override
  State<Rapport> createState() => _RapportState();
}

class _RapportState extends State<Rapport> {
  List<String> items_filiere = [];
  List<String> items_niveau = [];
  List<String> items_matiere = [];
  final Stream<QuerySnapshot> stream =
      FirebaseFirestore.instance.collection('filiere').snapshots();
  final Stream<QuerySnapshot> stream_niveau =
      FirebaseFirestore.instance.collection('niveau').snapshots();
  final Stream<QuerySnapshot> stream_matiere =
      FirebaseFirestore.instance.collection('matiere').snapshots();

  User? user;
  String? emailprof;
  String teacherName = "";

  String? value_filiere;
  String? value_niveau;
  String? value_matiere;
  String? selectedFiliere;
  String? selectedNiveau;
  String? selectedMatiere;
  DateTime? selectedDate;
  String? formattedDate;
  String? selectedDateShort;
  String formattedTime = DateFormat('kk:mm').format(DateTime.now());
  String hour = DateFormat('a').format(DateTime.now());
  String date = "";
  String? generatedQRCode;

  late CollectionReference col;

  Timer? _timer;

  List<String> etudiantsPresent = [];



  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    emailprof = user!.email!;
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        _update();
      }
    });
    col = FirebaseFirestore.instance.collection('qrcode');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  //***************
  Future<void> _update() async {
    await initializeDateFormatting('fr', "");
    DateTime now = DateTime.now();
    String formattedDateTime =
        DateFormat('EEEE d MMMM yyyy - HH:mm', 'fr').format(now);
    setState(() {
      date = formattedDateTime;
    });
  }

  //***************

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
    return "${address.city}, ${address.countryName}, ${address.postal}";
  }
  //***************

  @override
  Widget build(BuildContext context) {
    selectedFiliere = value_filiere ?? '';
    selectedNiveau = value_niveau ?? '';
    selectedMatiere = value_matiere ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            "Rapport",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                Theme.of(context).primaryColorDark,
                Theme.of(context).hintColor,
              ])),
        ),
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
              margin: const EdgeInsets.fromLTRB(25, 100, 25, 10),
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Column(
                children: [
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    "$date",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 25.0),
                  Text("Selectionnez la date:"),
                  const SizedBox(height: 18.0),
                  Container(
                    height: 40,
                    width: 130,
                    child: TextFormField(
                      readOnly: true,
                      onTap: () {
                        _selectDate(context);
                      },
                      decoration: InputDecoration(
                        hintText: 'Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      validator: (value) {
                        if (selectedDate == null) {
                          return 'Veuillez sélectionner une date';
                        }
                        return null;
                      },
                      controller: TextEditingController(
                        text: selectedDate != null
                            ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                            : '',
                      ),
                    ),
                  ),
                  const SizedBox(height: 25.0),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          height: 40,
                          width: 130,
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('filiere')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                List<DropdownMenuItem<String>>
                                    filiereItemsString = [];
                                if (!snapshot.hasData) {
                                  CircularProgressIndicator();
                                } else {
                                  final filieres =
                                      snapshot.data?.docs.reversed.toList();
                                  for (var filiere in filieres!) {
                                    filiereItemsString.add(
                                        DropdownMenuItem<String>(
                                            value: filiere['name'],
                                            child: Text(filiere['name'])));
                                  }
                                }
                                return DropdownButton<String>(
                                    items: filiereItemsString,
                                    hint: const Text('Filière'),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    value: value_filiere,
                                    underline: Container(),
                                    onChanged: (value) {
                                      setState(() => value_filiere = value);
                                    });
                              }),
                        ),
                      ]),
                  SizedBox(height: 10.0),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          height: 40,
                          width: 130,
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.grey,
                                width: 1,
                              )),
                          child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('niveau')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                List<DropdownMenuItem<String>>
                                    niveauItemsString = [];
                                if (!snapshot.hasData) {
                                  CircularProgressIndicator();
                                } else {
                                  final niveaux =
                                      snapshot.data?.docs.reversed.toList();
                                  for (var niveau in niveaux!) {
                                    niveauItemsString.add(
                                        DropdownMenuItem<String>(
                                            value: niveau['name'],
                                            child: Text(niveau['name'])));
                                  }
                                }
                                return DropdownButton<String>(
                                    items: niveauItemsString,
                                    hint: const Text('Niveau'),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    value: value_niveau,
                                    underline: Container(),
                                    onChanged: (value) {
                                      setState(() => value_niveau = value);
                                    });
                              }),
                        ),
                      ]),
                  SizedBox(height: 10.0),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          height: 40,
                          width: 130,
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('matiere')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                List<DropdownMenuItem<String>>
                                    matiereItemsString = [];
                                if (!snapshot.hasData) {
                                  CircularProgressIndicator();
                                } else {
                                  final matieres =
                                      snapshot.data?.docs.reversed.toList();
                                  for (var matiere in matieres!) {
                                    matiereItemsString.add(
                                        DropdownMenuItem<String>(
                                            value: matiere['name'],
                                            child: Text(matiere['name'])));
                                  }
                                }
                                return DropdownButton<String>(
                                    items: matiereItemsString,
                                    hint: const Text('Matière'),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    value: value_matiere,
                                    underline: Container(),
                                    onChanged: (value) {
                                      setState(() => value_matiere = value);
                                    });
                              }),
                        ),
                      ]),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                  onPressed: recupererRapport,
                                  child: Text('Afficher liste')),
                              ElevatedButton(
                                  onPressed: createPdf,
                                      //() async {
                                    // // Create a PDF document
                                    // final pdf = pw.Document();
                                    // // Create a page
                                    // pdf.addPage(
                                    //   pw.MultiPage(
                                    //     build: (pw.Context context) => [
                                    //       pw.Container(
                                    //         child: pw.Column(
                                    //           crossAxisAlignment:
                                    //               pw.CrossAxisAlignment.start,
                                    //           mainAxisAlignment:
                                    //               pw.MainAxisAlignment.start,
                                    //           children: [
                                    //             pw.Center(
                                    //               child: pw.Text(
                                    //                 "Rapport d'absence",
                                    //                 style: pw.TextStyle(
                                    //                   color: PdfColors.blue200,
                                    //                   fontSize: 22,
                                    //                   fontWeight:
                                    //                       pw.FontWeight.bold,
                                    //                 ),
                                    //               ),
                                    //             ),
                                    //             pw.SizedBox(height: 40),
                                    //             // pw.Text(
                                    //             //   "Date: ${formattedDate}\nProfesseur: ${emailprof}\nFiliere: ${selectedFiliere} ${selectedNiveau}\nMatiere: ${selectedMatiere}",
                                    //             //   style: pw.TextStyle(
                                    //             //     fontSize: 14,
                                    //             //     fontStyle:
                                    //             //         pw.FontStyle.italic,
                                    //             //     lineSpacing: 10,
                                    //             //   ),
                                    //             // ),
                                    //             pw.RichText(
                                    //               text: pw.TextSpan(
                                    //                 style: const pw.TextStyle(
                                    //                   fontSize: 14,
                                    //                   lineSpacing: 10,
                                    //                 ),
                                    //                 children: [
                                    //                   pw.TextSpan(
                                    //                     text: "Date: ",
                                    //                     style: pw.TextStyle(
                                    //                         fontWeight: pw
                                    //                             .FontWeight
                                    //                             .bold),
                                    //                   ),
                                    //                   pw.TextSpan(
                                    //                       text: formattedDate),
                                    //                   pw.TextSpan(
                                    //                       text:
                                    //                           "\nProfesseur: ",
                                    //                       style: pw.TextStyle(
                                    //                           fontWeight: pw
                                    //                               .FontWeight
                                    //                               .bold)),
                                    //                   pw.TextSpan(
                                    //                       text: emailprof),
                                    //                   pw.TextSpan(
                                    //                       text: "\nFilière: ",
                                    //                       style: pw.TextStyle(
                                    //                           fontWeight: pw
                                    //                               .FontWeight
                                    //                               .bold)),
                                    //                   pw.TextSpan(
                                    //                       text:
                                    //                           "$selectedFiliere $selectedNiveau"),
                                    //                   pw.TextSpan(
                                    //                       text: "\nMatière: ",
                                    //                       style: pw.TextStyle(
                                    //                           fontWeight: pw
                                    //                               .FontWeight
                                    //                               .bold)),
                                    //                   pw.TextSpan(
                                    //                       text:
                                    //                           selectedMatiere),
                                    //                 ],
                                    //               ),
                                    //             ),
                                    //             pw.SizedBox(height: 40),
                                    //             pw.Table.fromTextArray(
                                    //               headerStyle: pw.TextStyle(
                                    //                 color: PdfColors.white,
                                    //                 fontSize: 16,
                                    //                 fontWeight:
                                    //                     pw.FontWeight.bold,
                                    //               ),
                                    //               cellStyle: const pw.TextStyle(
                                    //                 fontSize: 14,
                                    //               ),
                                    //               headerDecoration:
                                    //                   const pw.BoxDecoration(
                                    //                 color: PdfColors.black,
                                    //               ),
                                    //               border: pw.TableBorder.all(
                                    //                 color: PdfColors.black,
                                    //                 width: 1,
                                    //               ),
                                    //               headers: [
                                    //                 'Etudiants présents'
                                    //               ],
                                    //               data: [
                                    //                 for (var i = 0;
                                    //                     i <
                                    //                         etudiantsPresent
                                    //                             .length;
                                    //                     i++)
                                    //                   [etudiantsPresent[i]],
                                    //               ],
                                    //             ),
                                    //           ],
                                    //         ),
                                    //       )
                                    //     ],
                                    //   ),
                                    // );
                                    //
                                    // // Save the PDF document
                                    // final pdfBytes = await pdf.save();
                                    // bool isOk = await AccessPhoneStorage
                                    //     .instance
                                    //     .saveIntoStorage(
                                    //         fileName:
                                    //             "$selectedDateShort-$selectedFiliere-$selectedNiveau.pdf",
                                    //         data: pdfBytes);
                                    //
                                    // if (isOk) {
                                    //   debugPrint(
                                    //       'File successfully created.');
                                    // }
                                  //},
                                  child: const Text('Télécharger JSON')),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });

      selectedDateShort = DateFormat('ddMMyyyy').format(selectedDate!);
      print(selectedDateShort);

      // Format the selected date as a string
      DateFormat dateFormatter = DateFormat('dd/M/yyyy');
      formattedDate = dateFormatter.format(selectedDate!);
    }
  }

  Future<void> recupererRapport() async {
    if (selectedFiliere != null &&
        selectedNiveau != null &&
        selectedMatiere != null &&
        selectedDate != null) {
      FirebaseFirestore.instance
          .collection('qrcode')
          .where('date', isEqualTo: formattedDate)
          .where('filiere', isEqualTo: selectedFiliere)
          .where('niveau', isEqualTo: selectedNiveau)
          .where('matiere', isEqualTo: selectedMatiere)
          .where('prof', isEqualTo: emailprof)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          List<String> students =
              List<String>.from(doc['students']); // Initialize the map

          List<String> etudiants = [];

          querySnapshot.docs.forEach((doc) {
            List<String> students = List<String>.from(doc['students']);
            etudiants.addAll(students);
          });

          etudiants.sort(
              (a, b) => b.compareTo(a)); // Sort the list in descending order

          setState(() {
            etudiantsPresent = etudiants;
          });

          // // Add all elements from 'students' list to 'etudiants'
          // etudiants.addAll(students);
          //
          // // Convert 'etudiants' list to a Map<String, dynamic>
          // etudiantsMap = Map.fromIterable(
          //   etudiants,
          //   key: (index) => etudiants.indexOf(index).toString(),
          //   value: (student) => student,
          // );

          // Printing the resulting map
          print(
              "$selectedFiliere $selectedNiveau ${formattedDate} \n *******${etudiantsPresent}*****************");
        }

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Liste des étudiants'),
              content: Container(
                width: double.maxFinite,
                // child: ListView.builder(
                //   itemCount: etudiantsMap.length,
                //   itemBuilder: (BuildContext context, int index) {
                //     var key = etudiantsMap.keys.elementAt(index);
                //     var value = etudiantsMap[key];
                //     return Text('$key: $value');
                //   },
                // ),
                child: ListView.builder(
                  itemCount: etudiantsPresent.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Text(etudiantsPresent[index]);
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Fermer'),
                ),
              ],
            );
          },
        );
      }).catchError((error) {
        print('Erreur lors de la récupération des QR codes : $error');
      });
    }
  }

  Future<void> createPdf() async {
    // Create a PDF document
    final pdf = pw.Document();
    // Create a page
    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Container(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    "Rapport d'absence",
                    style: pw.TextStyle(
                      color: PdfColors.blue200,
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 40),
                // pw.Text(
                //   "Date: ${formattedDate}\nProfesseur: ${emailprof}\nFiliere: ${selectedFiliere} ${selectedNiveau}\nMatiere: ${selectedMatiere}",
                //   style: pw.TextStyle(
                //     fontSize: 14,
                //     fontStyle:
                //         pw.FontStyle.italic,
                //     lineSpacing: 10,
                //   ),
                // ),
                pw.RichText(
                  text: pw.TextSpan(
                    style: const pw.TextStyle(
                      fontSize: 14,
                      lineSpacing: 10,
                    ),
                    children: [
                      pw.TextSpan(
                        text: "Date: ",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.TextSpan(text: formattedDate),
                      pw.TextSpan(
                          text: "\nProfesseur: ",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.TextSpan(text: emailprof),
                      pw.TextSpan(
                          text: "\nFilière: ",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.TextSpan(text: "$selectedFiliere $selectedNiveau"),
                      pw.TextSpan(
                          text: "\nMatière: ",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.TextSpan(text: selectedMatiere),
                    ],
                  ),
                ),
                pw.SizedBox(height: 40),
                pw.Table.fromTextArray(
                  headerStyle: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  cellStyle: const pw.TextStyle(
                    fontSize: 14,
                  ),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.black,
                  ),
                  border: pw.TableBorder.all(
                    color: PdfColors.black,
                    width: 1,
                  ),
                  headers: ['Etudiants présents'],
                  data: [
                    for (var i = 0; i < etudiantsPresent.length; i++)
                      [etudiantsPresent[i]],
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );

    // Save the PDF document
    final pdfBytes = await pdf.save();
    bool isOk = await AccessPhoneStorage.instance.saveIntoStorage(
        fileName: "$selectedDateShort-$selectedFiliere-$selectedNiveau.pdf",
        data: pdfBytes);

    if (isOk) {
      debugPrint('File successfully created.');
    }
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
