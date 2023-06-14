
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

  static List<String> dataList = [];
  late CollectionReference col;
  String documentId = '';
  String selectedFiliere = '';
  String selectedNiveau = '';
  String emailprof = '';

  LocationData? currentLocation;
  String address = "";

  @override
  void initState() {
    super.initState();
    date = '${time.day}/${time.month}/${time.year}';
    heure = '${time.hour}:${time.minute}';
    dataList = [date, heure];
    col = FirebaseFirestore.instance.collection('qrcode');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    generateDocument(); // Call the method here
  }

  Future<String> addDocument() async {
    DocumentReference docRef = await col.add({
      'date': date,
      'filiere': selectedFiliere,
      'niveau': selectedNiveau,
      'prof': emailprof,
      'location': address,
    });
    return docRef.id;
  }

  void generateDocument() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;
    emailprof = user!.email!; // Assign the value to the class variable

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    selectedFiliere = args?['selectedFiliere'] ?? ''; // Assign the value to the class variable
    selectedNiveau = args?['selectedNiveau'] ?? ''; // Assign the value to the class variable
    currentLocation =  args?['currentLocation'] ?? LocationData;
    address = args?['address']?? '';

    documentId = await addDocument(); // Appeler addDocument pour récupérer le documentId
    setState(() {}); // Mettre à jour l'état pour afficher le documentId
    print('Document ID: $documentId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Creating QR code'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BarcodeWidget(
            data: documentId,
            barcode: Barcode.qrCode(),
            color: Colors.blue,
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
