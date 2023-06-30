import 'dart:async';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocode/geocode.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'access_phone_storage.dart';
import 'header_widget.dart';
import 'login.dart';

class Teacher extends StatefulWidget {
  const Teacher({Key? key}) : super(key: key);

  @override
  State<Teacher> createState() => _TeacherState();
}

class _TeacherState extends State<Teacher> {
  late Timer _timer;
  String date = "";
  bool qrExist = false;

  // int _counter = 0;

  List<String> List_etudiants = [];
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
  String? emailTeacher;
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
  // String formattedTime = DateFormat('kk:mm').format(DateTime.now());
  // String hour = DateFormat('a').format(DateTime.now());

  String? generatedQRCode;

  List<String> etudiantsPresent = [];
  List<String> etudiants = [];
  List<String> etudiantsAbsents = [];

  LocationData? currentLocation;
  String address = "";

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    emailTeacher = user!.email!;
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        _update();
      }
    });

    _getLocation().then((value) {
      getTeacherData();
      LocationData? location = value;
      _getAddress(location?.latitude, location?.longitude).then((value) {
        setState(() {
          currentLocation = location;
          address = value;
        });
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _update() async {
    await initializeDateFormatting('fr', "");
    DateTime now = DateTime.now();
    String formattedDateTime =
        DateFormat('EEEE d MMMM yyyy - HH:mm', 'fr').format(now);
    setState(() {
      date = formattedDateTime;
    });
  }

  // Location added to guarante security
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

  // Retrieve teacher information from DB
  Future<void> getTeacherData() async {
    final teacher = FirebaseAuth.instance.currentUser;
    final teacherId = teacher?.uid;

    String nom = "";
    String prenom = "";
    var documentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(teacherId)
        .get();
    if (documentSnapshot.exists) {
      if (documentSnapshot.get('email') == emailTeacher) {
        nom = documentSnapshot.get('nom');
        prenom = documentSnapshot.get('prenom');
      }
    }

    nom = nom[0].toUpperCase() + nom.substring(1).toLowerCase();
    prenom = prenom[0].toUpperCase() + prenom.substring(1).toLowerCase();

    setState(() {
      teacherName = "$nom $prenom";
    });
  }

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
            "Espace professeur",
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
                    teacherName ?? "",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    "$date",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600),
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
                                          leading: Icon(
                                            Icons.my_location,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          title: const Text(
                                            "Localisation",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600),
                                          ),
                                          subtitle: Text(address !=
                                                  "Throttled! See geocode.xyz/pricing, null, Throttled! See geocode.xyz/pricing"
                                              ? address
                                              : "Erreur! Essayer de vous reconnecter"),
                                        ),
                                        ListTile(
                                          leading: Icon(
                                            Icons.email,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          title: const Text(
                                            "Email",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600),
                                          ),
                                          subtitle: Text(emailTeacher ?? ' '),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22.0),
                  const Text(
                    // 'Veuillez spécifier les informations suivantes puis générez le code QR:',
                    "Générer le codeQR de la séance:",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.05),
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: 40,
                        width: 130,
                        padding: EdgeInsets.only(left: 15),
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
                            List<DropdownMenuItem<String>> filiereItemsString =
                                [];
                            if (!snapshot.hasData) {
                              return CircularProgressIndicator();
                            } else {
                              final filieres =
                                  snapshot.data?.docs.reversed.toList();
                              for (var filiere in filieres!) {
                                filiereItemsString.add(DropdownMenuItem<String>(
                                    value: filiere['name'],
                                    child: Text(filiere['name'])));
                              }
                            }
                            return DropdownButton<String>(
                                items: filiereItemsString,
                                hint: const Text(
                                  'Filière\t\t\t\t\t',
                                  style: TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                ),
                                value: value_filiere,
                                underline: Container(),
                                onChanged: (value) {
                                  setState(() => value_filiere = value);
                                });
                          },
                        ),
                      ),
                      SizedBox(width: 15.0),
                      Container(
                        height: 40,
                        width: 130,
                        padding: EdgeInsets.only(left: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('niveau')
                              .snapshots(),
                          builder: (context, snapshot) {
                            List<DropdownMenuItem<String>> niveauItemsString =
                                [];
                            if (!snapshot.hasData) {
                              return CircularProgressIndicator();
                            } else {
                              final niveaux =
                                  snapshot.data?.docs.reversed.toList();
                              for (var niveau in niveaux!) {
                                niveauItemsString.add(DropdownMenuItem<String>(
                                    value: niveau['name'],
                                    child: Text(niveau['name'])));
                              }
                            }
                            return DropdownButton<String>(
                                items: niveauItemsString,
                                hint: const Text(
                                  'Niveau\t\t\t\t\t',
                                  style: TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                ),
                                value: value_niveau,
                                underline: Container(),
                                onChanged: (value) {
                                  setState(() => value_niveau = value);
                                });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.0),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          height: 40,
                          width: 130,
                          padding: EdgeInsets.only(left: 15),
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
                                    hint: const Text(
                                      'Matière\t\t\t\t\t',
                                      style: TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
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
                  const SizedBox(height: 22.0),
                  ElevatedButton(
                    onPressed: generateQRCode,
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
                    child: Text(
                      'Générer',
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Divider(
                    color: Colors.grey.shade400,
                    thickness: 1.0,
                  ),
                  SizedBox(height: 20.0),
                  const Text(
                    // 'Veuillez spécifier la date et les champs précédents pour obtenir le rapport:',
                    "Récupérer le rapport de la séance désirée:",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.05),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
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
                        hintStyle: TextStyle(color: Colors.black45),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        contentPadding: EdgeInsets.only(left: 15),
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
                  SizedBox(
                    height: 22.0,
                  ),
                  ElevatedButton(
                      onPressed: recupererRapport,
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
                      child: Text('Récupérer')),
                  SizedBox(
                    height: 35,
                  )
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

  // function to generate the qr code and move to it page
  void generateQRCode() {
    Navigator.pushNamed(
      context,
      '/scanPage',
      arguments: {
        'selectedFiliere': selectedFiliere,
        'selectedNiveau': selectedNiveau,
        'selectedMatiere': selectedMatiere,
        'currentLocation': currentLocation,
        'address': address,
      },
    ).then((result) {
      if (result != null) {
        setState(() {
          generatedQRCode = result as String;
        });
      }
    });
  }

  // date picker function
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

  // function to generate the rapport of students with their state (present or absent)
  Future<void> recupererRapport() async {
    etudiantsPresent = [];
    etudiants = [];
    etudiantsAbsents = [];
    List_etudiants = [];
    qrExist = false;

    if (selectedFiliere != null &&
        selectedNiveau != null &&
        selectedMatiere != null &&
        selectedDate != null) {
      FirebaseFirestore.instance
          .collection('users')
          .where('filiere', isEqualTo: selectedFiliere)
          .where('niveau', isEqualTo: selectedNiveau)
          .get()
          .then((QuerySnapshot snapshot) {
        List<String> names = [];
        snapshot.docs.forEach((DocumentSnapshot document) {
          Map<String, dynamic> userData =
              document.data() as Map<String, dynamic>;
          String name = userData['nom'] as String;
          String prenom = userData['prenom'] as String;
          name = name[0].toUpperCase() + name.substring(1).toLowerCase();
          prenom = prenom[0].toUpperCase() + prenom.substring(1).toLowerCase();
          String name_prenom = '$name $prenom';
          names.add(name_prenom);
        });
        setState(() {
          List_etudiants = names;
        });
      }).catchError((error) {
        print('Erreur lors de la récupération des utilisateurs : $error');
      });
    }

    // retrieving the present students list from the qrCode collection
    FirebaseFirestore.instance
        .collection('qrcode')
        .where('date', isEqualTo: formattedDate)
        .where('filiere', isEqualTo: selectedFiliere)
        .where('niveau', isEqualTo: selectedNiveau)
        .where('matiere', isEqualTo: selectedMatiere)
        .where('prof', isEqualTo: emailTeacher)
        .get()
        .then((querySnapshot) async {
      querySnapshot.docs.forEach((doc) {
        List<String> students = List<String>.from(doc['students']);
        etudiantsPresent.addAll(students);
        qrExist = true;
      });

      // checking for the absent students by comparing the present list and the whole class list
      etudiantsAbsents = List_etudiants.where(
          (etudiant) => !etudiantsPresent.contains(etudiant)).toList();

      // Remplacer List_etudiants par etudiants
      etudiants = etudiantsPresent + etudiantsAbsents;
      etudiants
          .sort((a, b) => b.compareTo(a)); // Sort the list in descending order
      if (qrExist) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Liste des étudiants'),
              content: Container(
                width: double.maxFinite,
                child: ListView.builder(
                    itemCount: etudiants.length,
                    itemBuilder: (BuildContext context, int index) {
                      String etudiant = etudiants[index];
                      bool estPresent = etudiantsPresent.contains(etudiant);

                      return ListTile(
                        title: Text(etudiant),
                        trailing: Text(
                          estPresent ? 'Présent' : 'Absent',
                          style: TextStyle(
                            color: estPresent ? Colors.green : Colors.red,
                          ),
                        ),
                      );
                    }),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Fermer'),
                ),
                TextButton(onPressed: createPdf, child: Text('Télécharger'))
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AwesomeSnackbarContent(
              title: "Alert",
              message: "Liste introuvable, vérifiez les informations entrées.",
              contentType: ContentType.warning,
            ),
            backgroundColor:
                Colors.transparent, // Set the background color here
          ),
        );
      }
    }).catchError((error) {
      print('Erreur lors de la récupération des QR codes : $error');
    });
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
                    "Rapport des absences",
                    style: pw.TextStyle(
                      color: PdfColors.black,
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 40),
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
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.TextSpan(text: teacherName),
                      pw.TextSpan(
                        text: "\nFilière: ",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.TextSpan(text: "$selectedFiliere $selectedNiveau"),
                      pw.TextSpan(
                        text: "\nMatière: ",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.TextSpan(text: selectedMatiere),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),
                pw.Table(
                  border: pw.TableBorder.all(),
                  defaultColumnWidth: pw.IntrinsicColumnWidth(),
                  columnWidths: {
                    0: pw.FlexColumnWidth(),
                    1: pw.FlexColumnWidth(),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Container(
                          color: PdfColors.black,
                          alignment: pw.Alignment.center,
                          child: pw.Padding(
                            padding: pw.EdgeInsets.all(10),
                            child: pw.Text(
                              'Nom',
                              style: pw.TextStyle(
                                fontSize: 15,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                          ),
                        ),
                        pw.Container(
                          color: PdfColors.black,
                          alignment: pw.Alignment.center,
                          child: pw.Padding(
                            padding: pw.EdgeInsets.all(10),
                            child: pw.Text(
                              'Présence',
                              style: pw.TextStyle(
                                fontSize: 15,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    for (var etudiant in etudiants)
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            child: pw.Text(etudiant),
                            padding: pw.EdgeInsets.all(10),
                          ),
                          pw.Padding(
                            child: pw.Text(
                              etudiantsPresent.contains(etudiant)
                                  ? 'Présent'
                                  : 'Absent',
                              style: pw.TextStyle(
                                color: etudiantsPresent.contains(etudiant)
                                    ? PdfColors.green
                                    : PdfColors.red,
                              ),
                            ),
                            padding: pw.EdgeInsets.all(10),
                          ),
                        ],
                      ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );

    // Save the PDF document
    final pdfBytes = await pdf.save();

    bool isOk = await AccessPhoneStorage.instance.saveIntoStorage(
        fileName: "$selectedDateShort-$selectedFiliere-$selectedNiveau.pdf",
        data: pdfBytes);
    if (isOk) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
            title: "Succès",
            message: "PDF téléchargé avec succès.",
            contentType: ContentType.success,
          ),
          backgroundColor: Colors.transparent, // Set the background color here
        ),
      );
    }
    Navigator.pop(context);
  }
}
