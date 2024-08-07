// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, use_key_in_widget_constructors, use_build_context_synchronously, avoid_print, unused_element, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:slim_web/components/pallete.dart';

import 'package:slim_web/pages/dashboard.dart';
import 'package:slim_web/pages/id.dart';
import 'package:slim_web/pages/widgets/custom_button.dart';
import 'package:slim_web/pages/widgets/custom_text_field.dart';
import 'package:slim_web/pages/widgets/custom_text_password.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum Estado {
  inicial,
  loading,
  loaded,
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Estado estado = Estado.inicial;

  Future<void> signInWithEmailAndPassword() async {
    UserSingleton userSingleton = UserSingleton();
    if (formKey.currentState!.validate()) {
      setState(() {
        estado = Estado.loading;
      });

      try {
        final userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        userSingleton.email = emailController.text;

        final user = FirebaseAuth.instance.currentUser!.uid;
        userSingleton.userId = user.toString();

        final query = await FirebaseFirestore.instance
            .collection('directores')
            .doc(user)
            .get();

        final data = query.data();

        if (data != null) {
          final storage = FlutterSecureStorage();
          await storage.write(
            key: 'user',
            value: userCredential.user!.uid,
          );
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Dashboard(),
            ),
          );
          setState(() {
            estado = Estado.loaded;
          });
          return;
        }

        showSnackBar(
          'No tienes permisos para acceder',
        );
        FirebaseAuth.instance.signOut();
        setState(() {
          estado = Estado.inicial;
        });
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          showSnackBar('Usuario no encontrado');
        } else if (e.code == 'wrong-password') {
          showSnackBar('Contraseña incorrecta');
        }
        setState(() {
          estado = Estado.inicial;
        });
      }
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Stack(
        children: [
          Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 60),
                        Container(
                          width: 100,
                          height: 100,
                          child: Image.asset('lib/images/logo.png'),
                        ),
                        Text(
                          'MiAmiga',
                          style: TextStyle(
                            color: Pallete.pink,
                            fontWeight: FontWeight.bold,
                            fontSize: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3,
                    child: CustomTextField(
                      label: 'Correo Electrónico',
                      controller: emailController,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !value.contains('@')) {
                          return 'Ingresa un correo electrónico válido';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3,
                    child: CustomTextPassword(
                      label: 'Contraseña',
                      controller: passwordController,
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3,
                    child: CustomButton(
                      onPressed: () {
                        signInWithEmailAndPassword();
                      },
                      label: 'Iniciar Sesión',
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (estado == Estado.loading)
            Container(
              color: Colors.black.withOpacity(0.5),
              width: double.infinity,
              height: double.infinity,
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
