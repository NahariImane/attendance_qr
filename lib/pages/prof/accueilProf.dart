import 'package:flutter/material.dart';

class AccueilProf extends StatefulWidget {
  const AccueilProf({Key? key}) : super(key: key);

  @override
  State<AccueilProf> createState() => _AccueilProfState();
}

class _AccueilProfState extends State<AccueilProf> {
  String? value_filiere;
  String? value_niveau;
  String? value_matiere;
  String? value_salle;
  @override
  Widget build(BuildContext context) {
    var time = DateTime.now();
    final items_filiere = ['GI', 'ITIRC','GINDUS', 'GE'];
    final items_niveau = ['1', '2', '3'];
    final items_matiere = ['matiere1', 'matiere2', 'matiere3', 'matiere4'];
    final items_salle = ['DR1', 'DR2', 'DE2'];

    DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
        value: item,
        child: Text(
          item,
          style: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 16,
          ),
        )
    );

    return Scaffold(
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
                  //margin: EdgeInsets.all(16),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: const Text('Filiére'),
                      value: value_filiere,
                      items: items_filiere.map(buildMenuItem).toList(),
                      onChanged: (value) => setState(() => value_filiere = value),
                    ),
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
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: Text('Niveau'),
                      value: value_niveau,
                      items: items_niveau.map(buildMenuItem).toList(),
                      onChanged: (value) => setState(() => value_niveau = value),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
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
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: Text('Matiére'),
                      value: value_matiere,
                      items: items_matiere.map(buildMenuItem).toList(),
                      onChanged: (value) => setState(() => value_matiere = value),
                    ),
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
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: Text('Salle'),
                      value: value_salle,
                      items: items_salle.map(buildMenuItem).toList(),
                      onChanged: (value) => setState(() => value_salle = value),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40.0),
            Container(
              width: 180,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
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
            Positioned(
              top: 0.7,
              left: 0.5,

              child: FractionallySizedBox(
                child: Image.asset(
                  'assets/circle.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
        ),
    );

  }
}
