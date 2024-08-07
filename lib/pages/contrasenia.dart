// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors, non_constant_identifier_names, unused_import, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:slim_web/components/menu.dart';
import 'package:slim_web/components/button.dart';
import 'package:slim_web/components/pallete.dart';
import 'package:slim_web/components/textfield.dart';
import 'package:slim_web/pages/perfil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:slim_web/pages/widgets/custom_app_bar.dart';

class Contrasenia extends StatelessWidget {
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController repeatPasswordController =
      TextEditingController();

  void _changePassword(BuildContext context) async {
    String currentPassword = currentPasswordController.text.trim();
    String newPassword = newPasswordController.text.trim();
    String repeatPassword = repeatPasswordController.text.trim();

    // Verificar que las contraseñas nuevas sean iguales
    if (newPassword != repeatPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Las contraseñas nuevas no coinciden')),
      );
      return;
    }

    // Obtener el usuario actual
    User? user = FirebaseAuth.instance.currentUser;

    // Verificar que el usuario haya iniciado sesión
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El usuario no ha iniciado sesión')),
      );
      return;
    }

    // Verificar la contraseña actual
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: user.email!,
        password: currentPassword,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('La contraseña actual es incorrecta')),
      );
      return;
    }

    // Cambiar la contraseña
    try {
      await user.updatePassword(newPassword);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contraseña cambiada con éxito')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cambiar la contraseña')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Text(
              'Cambiar Contraseña',
              style: TextStyle(
                color: Pallete.pink,
                fontWeight: FontWeight.bold,
                fontSize: 40,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Una contraseña segura contribuye a prevenir el acceso no autorizado a la cuenta',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            SizedBox(height: 16),
            MyTextField(
              controller: currentPasswordController,
              hintText: 'Contraseña Actual',
              labelText: 'Contraseña actual',
              obscureText: true,
              isEnabled: true,
            ),
            SizedBox(height: 16),
            MyTextField(
              controller: newPasswordController,
              hintText: 'Nueva Contraseña',
              labelText: 'Nueva contraseña',
              obscureText: true,
              isEnabled: true,
            ),
            SizedBox(height: 16),
            MyTextField(
              controller: repeatPasswordController,
              hintText: 'Repetir Nueva Contraseña',
              labelText: 'Repetir nueva contraseña',
              obscureText: true,
              isEnabled: true,
            ),
            SizedBox(height: 16),
            Container(
              margin: EdgeInsets.only(top: 20),
              width: 800,
              child: Button(
                text: 'Guardar',
                onPressed: () {
                  _changePassword(context);
                },
              ),
            ),
          ],
        ),
      ),
      drawer: MenuWidget(),
    );
  }
}
