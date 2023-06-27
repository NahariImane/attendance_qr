
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  var qrstr = "let's Scan it";
  var height,width;

  @override
  Widget build(BuildContext context) {

    height = MediaQuery
        .of(context)
        .size
        .height;
    width = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanning QR code'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(qrstr,style: TextStyle( color: Theme.of(context).primaryColor,fontSize: 30),),
            ElevatedButton(onPressed: scanQr, child:
            Text(('Scanner'))),
            SizedBox(height: width,)
          ],
        ),
      ),
    );
  }


  Future <void>scanQr()async{
    try{
      FlutterBarcodeScanner.scanBarcode('${Theme.of(context).hintColor},', 'cancel', true, ScanMode.QR).then((value){
        setState(() {
          // Ajouter a la base de donnees id de l'etudiant , prof , seance , date...
          //autoriser l'application à utiliser l'heure et la date du device
          qrstr = 'présence avec succes';
        });
      });
    }catch(e){
      setState(() {
        qrstr='unable to read this';
      });
    }
  }
}
