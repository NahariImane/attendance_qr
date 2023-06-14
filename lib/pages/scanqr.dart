
/*import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

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
  String selectedFiliere='';
  String selectedNiveau='';
  String emailprof='';

  @override
  void initState() {
    super.initState();
    date= '${time.day}/${time.month}/${time.year}';
    heure = '${time.hour}:${time.minute}';
    dataList = [date,heure,];
    col = FirebaseFirestore.instance.collection('qrcode');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    generateDocument(); // Call the method here
  }

  String qrstr = '';

  Future<String> addDocument() async {
    DocumentReference docRef = await col.add({
      'date': date,
      'filiere': selectedFiliere,
      'niveau': selectedNiveau,
      'prof': emailprof,
    });
    return docRef.id;
  }


  void generateDocument() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;
    final emailprof = user?.email;

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final selectedFiliere = args?['selectedFiliere'];
    final selectedNiveau = args?['selectedNiveau'];

    final String data = '${selectedFiliere ?? ''},${selectedNiveau ?? ''},${userId ?? ''},${emailprof ?? ''},${dataList.join(',')}';
    qrstr = 'Présence enregistrée';

    print(data);

    documentId = await addDocument(); // Appeler addDocument pour récupérer le documentId
    setState(() {}); // Mettre à jour l'état pour afficher le documentId
    print('Document ID: $documentId');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;
    final emailprof =user?.email;



   /* final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final selectedFiliere = args?['selectedFiliere'];
    final selectedNiveau = args?['selectedNiveau'];

    final String data = '${selectedFiliere ?? ''},${selectedNiveau ?? ''},${userId ?? ''},${emailprof ?? ''},${dataList.join(',')}';
    final String qrstr= 'Présence enregistré';

    print(data);*/


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



         /* ElevatedButton(
            onPressed:() async {
          documentId = await addDocument(); // Appeler addDocument pour récupérer le documentId
          setState(() {}); // Mettre à jour l'état pour afficher le documentId
          print('Document ID: $documentId');
          },
            child: Text('Confirmer'),
          ),*/

          SizedBox(
            width: MediaQuery.of(context).size.width,
          )
        ],


      ),
    );
  }

}
*/
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

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

  String qrstr = '';

  Future<String> addDocument() async {
    DocumentReference docRef = await col.add({
      'date': date,
      'filiere': selectedFiliere,
      'niveau': selectedNiveau,
      'prof': emailprof,
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

    final String data = '${selectedFiliere},${selectedNiveau},${userId ?? ''},${emailprof},${dataList.join(',')}';
    qrstr = 'Présence enregistrée';

    print(data);

    documentId = await addDocument(); // Appeler addDocument pour récupérer le documentId
    setState(() {}); // Mettre à jour l'état pour afficher le documentId
    print('Document ID: $documentId');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;
    emailprof = user!.email!; // Assign the value to the class variable

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
