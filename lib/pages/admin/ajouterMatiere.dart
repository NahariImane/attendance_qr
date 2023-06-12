import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
class Matiere extends StatefulWidget {
  const Matiere({Key? key}) : super(key: key);

  @override
  State<Matiere> createState() => _MatiereState();
}

class _MatiereState extends State<Matiere> {
  final _formKey = GlobalKey<FormState>();
  final _matiereController = TextEditingController();
  String _errorMessage = '';

  void dispose() {
    _matiereController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await FirebaseFirestore.instance.collection("matiere").add(
            {
              'name':_matiereController.text,
            });
        Navigator.pop(context);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ajout réussi !'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Ajouter Matière'),
          backgroundColor: Colors.teal[300],
        ),
        body:  Padding(
          padding: EdgeInsets.all(10),
          child: Form(
            key: _formKey,
            child: Column(
                children: [
                   TextFormField(
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                      labelText: 'Nom de la Matière',
                    ),
                    controller: _matiereController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Champ requis';
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
