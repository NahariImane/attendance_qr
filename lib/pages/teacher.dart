import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocode/geocode.dart';
import 'package:location/location.dart';
import 'package:pfa_gestion_absence_qrcode/pages/scanqr.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'login.dart';

class Teacher extends StatefulWidget {
  const Teacher({Key? key}) : super(key: key);

  @override
  State<Teacher> createState() => _TeacherState();
}

class _TeacherState extends State<Teacher> {

   List<String>  items_filiere =[];
   List<String>  items_niveau =[];
   final Stream<QuerySnapshot> stream = FirebaseFirestore.instance.collection('filiere').snapshots();
   final Stream<QuerySnapshot> stream_niveau = FirebaseFirestore.instance.collection('niveau').snapshots();

   String? value_filiere;
   String? value_niveau;


   LocationData? currentLocation;
   String address = "";

   @override
   void initState() {
     super.initState();
     // _startLocationService();
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

   //*********************************************

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


 


  @override
  Widget build(BuildContext context) {
    var time = DateTime.now();
    String? selectedFiliere = value_filiere ?? '';
    String? selectedNiveau = value_niveau ?? '';

    return Scaffold(
      appBar: AppBar(
        //title: Text("Teacher"),
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
                color: Colors.teal[300],
                child:  Column(
                  children: [
                    SizedBox(height: 50.0),
                    const Text(
                      'Professeur',
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
                  'Veuillez spécifier les informations suivantes puis générez le code QR et le diffusez aux étudiants ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.0,
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
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                        ),
                      ),

                    child:StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('filiere').snapshots(),
                      builder: (context,snapshot){
                        List<DropdownMenuItem<String>> filiereItemsString=[];
                        if(!snapshot.hasData)
                        {
                           CircularProgressIndicator();
                        }
                        else{
                          final filieres = snapshot.data?.docs.reversed.toList();
                          for(var filiere in filieres!){
                            filiereItemsString.add(DropdownMenuItem<String>(
                                value: filiere['name'],
                                child: Text(filiere['name'])));
                          }
                        }
                        return DropdownButton<String>(
                            items:filiereItemsString  ,
                            hint: const Text('Filière'),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                            ),
                            value: value_filiere,
                            underline: Container(),
                            onChanged: (value){
                              setState(() =>value_filiere=value);
                            }
                        );
                      }

                  ),
                  ),
                  Container(
                      height: 40,
                      width: 130,
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          )
                      ),

                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('niveau').snapshots(),
                      builder: (context,snapshot){
                        List<DropdownMenuItem<String>> niveauItemsString=[];
                        if(!snapshot.hasData)
                        {
                           CircularProgressIndicator();
                        }
                        else{
                          final niveaux = snapshot.data?.docs.reversed.toList();
                          for(var niveau in niveaux!){
                            niveauItemsString.add(DropdownMenuItem<String>(
                                value: niveau['name'],
                                child: Text(niveau['name'])
                            )
                            );
                          }
                        }
                        return DropdownButton<String>(
                            items:niveauItemsString  ,
                            hint: const Text('Niveau'),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                            ),
                            value: value_niveau,
                            underline: Container(),
                            onChanged: (value){
                              setState(() =>value_niveau=value);
                            }
                        );
                      }
                  ),
                  ),
                ]),

              const SizedBox(height: 25.0),

              SizedBox(height: 40.0),
              Container(
                width: 180,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/scanPage',
                      arguments: {
                        'selectedFiliere': selectedFiliere,
                        'selectedNiveau': selectedNiveau,
                        'currentLocation': currentLocation,
                        'address': address,
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.teal[300], // Background color
                  ),
                  child: Text('Générer QR code'),
                ),
              ),
              SizedBox(height: 20.0),
              Container(
                width: 180,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.teal[300], // Background color
                  ),
                  child: Text('Récupérer le rapport'),
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
}

