
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

  @override
  void initState() {
    super.initState();
    date= '${time.day}/${time.month}/${time.year}';
    heure = '${time.hour}:${time.minute}';
    dataList = [date,heure,];
  }
  String qrstr = '';


  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;
    final emailprof =user?.email;

    String documentId;


    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final selectedFiliere = args?['selectedFiliere'];
    final selectedNiveau = args?['selectedNiveau'];

    final String data = '${selectedFiliere ?? ''},${selectedNiveau ?? ''},${userId ?? ''},${emailprof ?? ''},${dataList.join(',')}';
    final String qrstr= 'Présence enregistré';

    print(data);


    return Scaffold(
      appBar: AppBar(
        title: Text('Creating QR code'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BarcodeWidget(
            data: qrstr,
            barcode: Barcode.qrCode(),
            color: Colors.blue,
            height: 250,
            width: 250,
          ),

          ElevatedButton(
            onPressed:() async{
              CollectionReference col = FirebaseFirestore.instance.collection('qrcode');
              DocumentReference docRef = await col.add({
              'date':date,
              'filiere':selectedFiliere,
              'niveau':selectedNiveau,
              'prof':emailprof,
              });
              documentId = docRef.id;
              print('Document ID: $documentId');},
            child: Text('Confirmer'),
          ),

          SizedBox(
            width: MediaQuery.of(context).size.width,
          )
        ],


      ),
    );
  }

}
