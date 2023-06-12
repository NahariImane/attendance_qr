import 'package:flutter/material.dart';

class Accueil extends StatefulWidget {
  const Accueil({Key? key}) : super(key: key);

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  @override
  Widget build(BuildContext context) {

    var time = DateTime.now();

    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 250,
            width: double.infinity,
            color: Colors.teal[300],
            child:  Column(
              children: [
                SizedBox(height: 50.0),
                const Text(
                  'Administrateur',
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

          const Text(
              'Ajouter',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
          ),
          const SizedBox(height: 25.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 100,
                height: 100,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/filiere');
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.teal[300], // Background color
                  ),
                  child: Text('Filiere'),
                ),
              ),
              Container(
                width: 100,
                height: 100,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/matiere');
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.teal[300], // Background color
                  ),
                  child: Text('Matiere'),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 100,
                height: 100,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/professeur');
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.teal[300], // Background color
                  ),
                  child: Text('Professeur'),
                ),
              ),
              Container(
                width: 100,
                height: 100,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/etudiant');
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.teal[300], // Background color
                  ),
                  child: Text('Etudiant'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
