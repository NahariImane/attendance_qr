import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Etudiant extends StatefulWidget {
  const Etudiant({Key? key}) : super(key: key);

  @override
  State<Etudiant> createState() => _EtudiantState();
}

class _EtudiantState extends State<Etudiant> {

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

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Ajouter Etudiant'),
          backgroundColor: Colors.teal[300],
        ),
        body:  Padding(
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    labelText: 'CNE',
                  ),
                  controller: _cneController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Champ requis';
                    }
                    return null;
                  },
                ),
                 TextFormField(
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    labelText: 'Nom',
                  ),
                  controller: _nomController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Champ requis';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 5.0),
                 TextFormField(
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    labelText: 'Prénom',
                  ),
                   controller: _prenomController,
                   validator: (value) {
                     if (value!.isEmpty) {
                       return 'Champ requis';
                     }
                     return null;
                   },
                 ),
                SizedBox(height: 5.0),
                 TextFormField(
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    labelText: 'Email',
                  ),
                   controller: _emailController,
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
                SizedBox(height: 5.0),
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('filiere').snapshots(),
                    builder: (context,snapshot){
                      List<DropdownMenuItem> filiereItems = [];
                      if(!snapshot.hasData){
                        const CircularProgressIndicator();
                      }
                      else{
                        final filieres = snapshot.data?.docs.reversed.toList();
                        filiereItems.add(const DropdownMenuItem(
                          value: "0",
                          child: Text("Choisir une filiére"),
                        )
                        );
                        for(var filiere in filieres!){
                          filiereItems.add(DropdownMenuItem(
                            value: filiere.id,
                            child: Text(filiere['name']),
                          ),
                          );
                        }
                      }
                      return DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          items: filiereItems.cast<DropdownMenuItem<String>>(),
                          onChanged: (String? filiereValue) {
                            setState(() {
                              selectedfiliere = filiereValue!;
                            });
                          },
                          value: selectedfiliere,
                          isExpanded: true,
                        ),
                      );


                    }
                ),
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('niveau').snapshots(),
                    builder: (context,snapshot){
                      List<DropdownMenuItem> niveauItems = [];
                      if(!snapshot.hasData){
                        const CircularProgressIndicator();
                      }
                      else{
                        final niveaux = snapshot.data?.docs.reversed.toList();
                        niveauItems.add(const DropdownMenuItem(
                          value: "0",
                          child: Text("Choisir le niveau"),
                        )
                        );
                        for(var niveau in niveaux!){
                          niveauItems.add(DropdownMenuItem(
                            value: niveau.id,
                            child: Text(niveau['name']),
                          ),
                          );
                        }
                      }

                      return DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          items: niveauItems.cast<DropdownMenuItem<String>>(),
                          onChanged: (String? niveauValue) {
                            setState(() {
                              selectedniveau = niveauValue!;
                            });
                          },
                          value: selectedniveau,
                          isExpanded: true,
                        ),
                      );
                    }
                ),
                SizedBox(height: 5.0),
                 TextFormField(
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    labelText: 'Mot de passe',
                  ),
                  controller: _passwordController,
                  obscureText: true,
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
                SizedBox(height: 5.0),
                 TextFormField(
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    labelText: 'Confirmez le mot de passe',
                  ),
                  controller: _confirmPasswordController,
                  obscureText: true,
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

                const SizedBox(height: 40.0),

                Container(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.teal[300], // Background color
                    ),
                    child:  Text('Ajouter'),
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
        ));
  }
}
