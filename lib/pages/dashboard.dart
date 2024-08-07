// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:slim_web/components/button_dashboard.dart';
import 'package:slim_web/components/menu.dart';
import 'package:slim_web/components/pallete.dart';
import 'package:slim_web/pages/Users.dart';
import 'package:slim_web/pages/cases.dart';
import 'package:slim_web/pages/id.dart';
import 'package:slim_web/pages/reportsupervisor.dart';
import 'package:slim_web/services/firebase_service.dart';

class Dashboard extends StatefulWidget {
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final CaseCountController = TextEditingController();
  final UserCountController = TextEditingController();
  final SupervisorCountController = TextEditingController();

  void UsersButton() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Users(),
      ),
    );
  }

  void SupervisorButton() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReportSupervisor(),
      ),
    );
  }

  void CasesButton() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Cases(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CollectionReference _items =
        FirebaseFirestore.instance.collection('directores');

    UserSingleton userSingleton = UserSingleton();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        elevation: 0,
        backgroundColor: Pallete.pink,
        title: Image.asset(
          'lib/images/logo_appbar.png',
          fit: BoxFit.contain,
          height: 40,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 16,
            ),
            Text(
              'Dashboard',
              style: TextStyle(
                color: Color(0xFFD15A7C),
                fontWeight: FontWeight.bold,
                fontSize: 40,
              ),
            ),
            SizedBox(
                height: 20), // Espacio entre el título y el cuadro de usuario
            Container(
              decoration: BoxDecoration(
                  color: Color(0xFF8661A8),
                  borderRadius: BorderRadius.circular(20)),

              padding: EdgeInsets.symmetric(horizontal: 240, vertical: 150),
              // Ajustar el margen izquierdo, derecho y la altura
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<DocumentSnapshot>(
                    future: _items.doc(userSingleton.userId).get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || !snapshot.data!.exists) {
                        return Text('Usuario no encontrado.');
                      } else {
                        Map<String, dynamic> userData =
                            snapshot.data!.data() as Map<String, dynamic>;
                        String userName =
                            userData['nombre'] ?? 'Nombre no encontrado';

                        return Column(children: [
                          Text(
                            'Hola $userName',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 35,
                                fontWeight: FontWeight.bold),
                          ),
                        ]);
                      }
                    },
                  ),

                  SizedBox(
                      height:
                          20), // Aumentar la separación entre el nombre y la cita
                  Text(
                    '"Nunca es demasiado tarde para ser lo que podrías haber sido"',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
                height: 20), // Espacio entre el cuadro de usuario y los botones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FutureBuilder(
                    future: getCasosCount(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        CaseCountController.text = '${snapshot.data}';
                        return DashboardButton(
                            ontap: CasesButton,
                            icon: Icons.folder,
                            label: 'Casos ${snapshot.data}');
                      }
                    }),
                FutureBuilder(
                    future: getSupervisorCount(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        SupervisorCountController.text = '${snapshot.data}';
                        return DashboardButton(
                            ontap: SupervisorButton,
                            icon: Icons.supervised_user_circle,
                            label: 'Supervisores ${snapshot.data}');
                      }
                    }),
                FutureBuilder(
                    future: getUsersCount(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        UserCountController.text = '${snapshot.data}';
                        return DashboardButton(
                          ontap: UsersButton,
                          icon: Icons.people,
                          label: 'Usuarios ${snapshot.data}',
                        );
                      }
                    }),
              ],
            ),
          ],
        ),
      ),
      drawer: MenuWidget(), // Usa el widget MenuWidget
    );
  }
}
