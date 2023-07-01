import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

class CreateScreen extends StatefulWidget {
  @override
  _CreateScreenState createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  var time = DateTime.now();
  var date, heure;

  late CollectionReference col;
  String documentId = '';
  String selectedFiliere = '';
  String selectedNiveau = '';
  String selectedMatiere = '';
  String emailprof = '';

  LocationData? currentLocation;
  String address = "";
  List<String> students = [];

  @override
  void initState() {
    super.initState();
    date = '${time.day}/${time.month}/${time.year}';
    DateFormat dateFormatter = DateFormat('dd/MM/yyyy');
    date= dateFormatter.format(time);
    col = FirebaseFirestore.instance.collection('qrcode');
  }


  // The generateDocument method is only called if the documentId is empty.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (documentId.isEmpty) {
      generateDocument();
    }
  }


  Future<String> addDocument() async {
    DocumentReference docRef = await col.add({
      'date': date,
      'filiere': selectedFiliere,
      'niveau': selectedNiveau,
      'matiere': selectedMatiere,
      'prof': emailprof,
      'location': address,
      'students': students,
    });
    return docRef.id;
  }

  void generateDocument() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;
    emailprof = user!.email!; // Assign the value to the class variable

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    selectedFiliere = args?['selectedFiliere'] ?? ''; // Assign the value to the class variable
    selectedNiveau = args?['selectedNiveau'] ?? ''; 
    selectedMatiere = args?['selectedMatiere'] ?? '';
    currentLocation =  args?['currentLocation'] ?? LocationData;
    address = args?['address']?? '';

    documentId = await addDocument(); // Appeler addDocument pour récupérer le documentId
    setState(() {}); // Mettre à jour l'état pour afficher le documentId
    print('Document ID: $documentId');
    print('Teacher Location ${address}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Creating QR code',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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

      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BarcodeWidget(
            data: documentId,
            barcode: Barcode.qrCode(),
            color: Theme.of(context).primaryColor,
            height: 250,
            width: 250,
          ),

          SizedBox(
            width: MediaQuery.of(context).size.width,
          )
        ],
      ),
    );
  }
}
