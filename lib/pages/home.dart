import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pfa_gestion_absence_qrcode/pages/login.dart';

import '../utils.dart';

class home extends StatelessWidget {
  const home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Container(alignment: Alignment.topLeft,child: Image.asset('assets/images/circle.png'),),
              Container(
                margin: EdgeInsets.fromLTRB(39*fem, 0*fem, 39*fem, 0*fem),
                width: double.infinity,
                decoration: BoxDecoration (
                  borderRadius: BorderRadius.circular(13*fem),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(1.65*fem, 10*fem, 0*fem, 49*fem),
                      width: 200*fem,
                      height: 225*fem,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13*fem),
                        child: Image.asset(
                          'assets/images/home.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      // title
                      margin: EdgeInsets.fromLTRB(0*fem, 30*fem, 0*fem, 0*fem),
                      width: double.infinity,
                      height: 33*fem,
                      child: Text(
                        'QrAttendance',
                        style: SafeGoogleFont (
                          'Nunito',
                          fontSize: 30*ffem,
                          fontWeight: FontWeight.w700,
                          height: 0.6666666667*ffem/fem,
                          letterSpacing: 1.8*fem,
                          color: Color(0xff178ca4),
                        ),
                      ),
                    ),
                    const Divider(
                      color: Color(0xff178ca4),
                      height: 5,
                      thickness: 1.3,
                      indent: 5,
                      endIndent: 5,
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0*fem, 30*fem, 14*fem, 0*fem),
                      constraints: BoxConstraints (
                        maxWidth: 281*fem,
                      ),
                      child: Text(
                        'Application de détection des absences\nen utilisant un code qr.',
                        style: SafeGoogleFont (
                          'Nunito',
                          fontSize: 14*ffem,
                          fontWeight: FontWeight.w700,
                          height: 1.4285714286*ffem/fem,
                          letterSpacing: 0.84*fem,
                          color: const Color(0xff178ca4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: SizedBox(
                    height: 90,
                    width: 90,
                    child: ElevatedButton(
                        style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                            backgroundColor: MaterialStateProperty.all<Color>(Color(0xff178ca4)),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(topLeft:Radius.circular(100)),
                                    side: BorderSide( color: Color(0xff178ca4))
                                )
                            ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()),
                          );
                        },
                        child: const Icon(
                          Icons.navigate_next_rounded,
                          size: 70,
                        )
                    ),
                  ),
                ),
              )
            ],
          ),

        ),
      ),
    );
  }
}
