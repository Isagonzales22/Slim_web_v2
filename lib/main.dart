import 'package:flutter/material.dart';
import 'package:slim_web/components/pallete.dart';
import 'package:slim_web/pages/Users.dart';
import 'package:slim_web/pages/cases.dart';
import 'package:slim_web/pages/contrasenia.dart';
import 'package:slim_web/pages/dashboard.dart';
import 'package:slim_web/pages/login.dart';
import 'package:slim_web/pages/perfil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:slim_web/pages/report_cases.dart';
import 'package:slim_web/pages/reportsupervisor.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyAKI2QyqDrxXsMy77P1ExagP59uuNMMMEM",
          authDomain: "authprueba-e040e.firebaseapp.com",
          projectId: "authprueba-e040e",
          storageBucket: "authprueba-e040e.appspot.com",
          messagingSenderId: "1024496648729",
          appId: "1:1024496648729:web:b91fcc6137447a35baa088"));
  runApp(const Slim());
}

class Slim extends StatefulWidget {
  const Slim({super.key});

  @override
  State<Slim> createState() => _SlimState();
}

class _SlimState extends State<Slim> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Slim',
      theme: ThemeData(
        primaryColor: Pallete.pink,
        fontFamily: GoogleFonts.lato().fontFamily,
        primarySwatch: Colors.pink,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Ruta inicial de la aplicación
      routes: {
        '/': (context) => LoginScreen(), // Página principal (Dashboard)
        '/perfil': (context) => Perfil(),
        '/dashboard': (context) => Dashboard(), // Página de perfil
        '/contrasenia': (context) => Contrasenia(), // Página de contraseña
        '/supervisores': (context) =>
            ReportSupervisor(), // Página de supervisores
        '/reporte': (context) => Reports(), // Página de reporte
        '/usuarios': (context) => Users(),
        '/casos': (context) => Cases(),
        /*'/casos': (context) => Casos(),       // Página de casos
  
  '/usuarios': (context) => Usuarios(), // Página de usuarios
  '/cerrar_sesion': (context) => CerrarSesion(), // Página de cierre de sesión*/
      },
    );
  }
}
