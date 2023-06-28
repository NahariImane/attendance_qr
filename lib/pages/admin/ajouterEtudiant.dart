import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../header_widget.dart';
import '../theme_helper.dart';

class Etudiant extends  StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _EtudiantState();
  }
}

class _EtudiantState extends State<Etudiant>{

  final _formKey = GlobalKey<FormState>();
  final _cneController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _errorMessage = '';
  String selectedfiliere = "0";
  String selectedniveau = "0";

  @override
  void dispose() {
    _cneController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        UserCredential userCredential = await  FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        DocumentSnapshot filiereSnapshot = await FirebaseFirestore.instance.collection('filiere').doc(selectedfiliere).get();
        String filiereNom = filiereSnapshot.get('name');
        DocumentSnapshot niveauSnapshot = await FirebaseFirestore.instance.collection('niveau').doc(selectedniveau).get();
        String niveauNom = niveauSnapshot.get('name');
        await FirebaseFirestore.instance.collection("users").doc(userCredential.user!.uid).set(
            {
              'cne': _cneController.text,
              'nom':_nomController.text,
              'prenom':_prenomController.text,
              'email':_emailController.text,
              'password':_passwordController.text,
              'filiere': filiereNom,
              'niveau' : niveauNom,
              'role': "student",
            });
        Navigator.pop(context);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inscription réussie !'),
              duration: Duration(seconds: 2),
            ),
          );
        });
        _formKey.currentState!.reset();

      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = e.message!;
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Une erreur s\'est produite';
        });
      }
    }
  }
//================================================
  get selectedValue => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Ajouter Filière',
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: 150,
              child: HeaderWidget(150, false, Icons.person_add_alt_1_rounded),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(25, 50, 25, 10),
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        GestureDetector(
                          child: Stack(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                      width: 5, color: Colors.white),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 20,
                                      offset: const Offset(5, 5),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.grey.shade300,
                                  size: 80.0,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(80, 80, 0, 0),
                                child: Icon(
                                  Icons.add_circle,
                                  color: Colors.grey.shade700,
                                  size: 25.0,
                                ),
                              ),
                            ],
                          ),
                        ),
//*************************************************************************************************

                        const SizedBox(height: 10,),
                        Container(
                          //decoration: ThemeHelper().inputBoxDecorationShaddow(),
                          child: TextFormField(
                            decoration:  InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.grey)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.grey.shade400)),
                              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.red, width: 2.0)),
                              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.red, width: 2.0)),
                              hintText: 'Entrez le CNE',
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            controller: _cneController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Champ requis';
                              }
                              return null;
                            },
                          ),
                        ),


                        const SizedBox(height: 5,),


                        Container(
                          child: TextFormField(
                            decoration:  InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.grey)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.grey.shade400)),
                              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.red, width: 2.0)),
                              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.red, width: 2.0)),
                              hintText: 'Entrez votre nom',
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            controller: _nomController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Champ requis';
                              }
                              return null;
                            },
                          ),
                        ),


                        const SizedBox(height: 5.0),


                        Container(
                          //decoration: ThemeHelper().inputBoxDecorationShaddow(),
                          child: TextFormField(
                            decoration:  InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.grey)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.grey.shade400)),
                              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.red, width: 2.0)),
                              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.red, width: 2.0)),
                              hintText: 'Entrez le prénom',
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            controller: _prenomController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Champ requis';
                              }
                              return null;
                            },
                          ),
                        ),


                        const SizedBox(height: 5.0),


                        Container(
                          //decoration: ThemeHelper().inputBoxDecorationShaddow(),
                          child: TextFormField(
                            decoration:  InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.grey)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.grey.shade400)),
                              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.red, width: 2.0)),
                              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.red, width: 2.0)),
                              hintText: 'Entrez le Email',
                              hintStyle: TextStyle(color: Colors.grey),
                            ),                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Champ requis';
                              }
                              if (!EmailValidator.validate(value)) {
                                return 'Adresse email invalide';
                              }
                              return null;
                            },
                          ),
                        ),


                        const SizedBox(height: 5.0),


                        //+++++++++++++++++++++++++++++++++++++++++++++++++++
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('filiere').snapshots(),
                          builder: (context, snapshot) {
                            List<DropdownMenuItem<String>> filiereItems = [];
                            if (!snapshot.hasData) {
                              return  CircularProgressIndicator();
                            } else {
                              final filieres = snapshot.data?.docs.reversed.toList();
                              filiereItems.add( const DropdownMenuItem<String>(
                                value: "0",
                                child: Text(
                                  "Choisir une filière",
                                  style: TextStyle(
                                    color: Colors.grey, // Couleur du texte
                                  ),
                                ),
                              ));
                              for (var filiere in filieres!) {
                                filiereItems.add(DropdownMenuItem<String>(
                                  value: filiere.id,
                                  child: Text(filiere['name']),
                                ));
                              }
                            }
                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(100.0),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  items: filiereItems,
                                  onChanged: (String? filiereValue) {
                                    setState(() {
                                      selectedfiliere = filiereValue!;
                                    });
                                  },
                                  value: selectedfiliere,
                                  isExpanded: true,
                                  icon: Icon(Icons.arrow_drop_down), // Flèche vers le bas à droite
                                  padding: EdgeInsets.fromLTRB(20, 0, 10, 0), // Ajoutez cette ligne
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 5.0),
                        //+++++++++++++++++++++++++++++++++++++++++++++++++++
                        StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance.collection('niveau').snapshots(),
                            builder: (context,snapshot){
                              List<DropdownMenuItem> niveauItems = [];
                              if(!snapshot.hasData){
                                const CircularProgressIndicator();
                              }
                              else{
                                final niveaux = snapshot.data?.docs.reversed.toList();
                                niveauItems.add(const DropdownMenuItem<String>(
                                  value: "0",
                                  child: Text(
                                    "Choisir un niveau",
                                    style: TextStyle(
                                      color: Colors.grey, // Couleur du texte
                                    ),
                                  ),
                                )
                                );
                                for(var niveau in niveaux!){
                                  niveauItems.add(DropdownMenuItem<String>(
                                    value: niveau.id,
                                    child: Text(niveau['name']),
                                  ),
                                  );
                                }
                              }

                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(100.0),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    items: niveauItems.cast<DropdownMenuItem<String>>(),
                                    onChanged: (String? niveauValue) {
                                      setState(() {
                                        selectedniveau = niveauValue!;
                                      });
                                    },
                                    value: selectedniveau,
                                    isExpanded: true,
                                    padding: EdgeInsets.fromLTRB(20, 0, 10, 0), // Ajoutez cette ligne
                                  ),
                                ),
                              );
                            }
                        ),

                        //+++++++++++++++++++++++++++++++++++++++++++++++++
                        const SizedBox(height: 5.0),
                        Container(
                          //decoration: ThemeHelper().inputBoxDecorationShaddow(),
                          child: TextFormField(
                            obscureText: true,
                            decoration:  InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.grey)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.grey.shade400)),
                              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.red, width: 2.0)),
                              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.red, width: 2.0)),
                              hintText: 'Entrez le mot de passe',
                              hintStyle: TextStyle(color: Colors.grey),
                            ),                            controller: _passwordController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Champ requis';
                              }
                              if (value.length < 6) {
                                return 'Le mot de passe doit contenir au moins 6 caractères';
                              }
                              return null;
                            },
                          ),
                        ),


                        const SizedBox(height: 5.0),


                        Container(
                          //decoration: ThemeHelper().inputBoxDecorationShaddow(),
                          child: TextFormField(
                            obscureText: true,
                            decoration:  InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.grey)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.grey.shade400)),
                              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.red, width: 2.0)),
                              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.red, width: 2.0)),
                              hintText: 'Confirmez le mot de passe',
                              hintStyle: TextStyle(color: Colors.grey),
                            ),                            controller: _confirmPasswordController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Champ requis';
                              }
                              if (value != _passwordController.text) {
                                return 'Les mots de passe ne correspondent pas';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 20.0),


                        Container(
                          decoration: ThemeHelper().buttonBoxDecoration(context),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                              minimumSize: MaterialStateProperty.all(Size(50, 50)),
                              backgroundColor: MaterialStateProperty.all(Colors.transparent),
                              shadowColor: MaterialStateProperty.all(Colors.transparent),
                            ),

                            onPressed: _submitForm,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                              child: Text(
                                "Ajouter".toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if(_errorMessage.isNotEmpty)
                          Text(
                            _errorMessage,
                            style: TextStyle(color: Colors.red),
                          ),
                      ],
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

}
