// ignore_for_file: prefer_const_constructors, depend_on_referenced_packages, unused_import, library_private_types_in_public_api, use_key_in_widget_constructors, prefer_final_fields, deprecated_member_use, use_build_context_synchronously, avoid_print, prefer_const_literals_to_create_immutables

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:slim_web/components/Menu.dart';
import 'package:slim_web/components/button.dart';
import 'package:slim_web/components/pallete.dart';
import 'package:slim_web/components/textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:slim_web/pages/dashboard.dart';
import 'package:slim_web/pages/perfil.dart';
import 'package:slim_web/pages/reportsupervisor.dart';
import 'package:slim_web/pages/supervisor.dart';

class SupervisorUpdate extends StatefulWidget {
  final String documentId;
  final String fullname;
  final String email;
  final String ci;
  final String phone;
  SupervisorUpdate(
      {required this.documentId,
      required this.fullname,
      required this.ci,
      required this.phone,
      required this.email});
  @override
  _SupervisorUpdateState createState() => _SupervisorUpdateState();
}

class _SupervisorUpdateState extends State<SupervisorUpdate> {
  TextEditingController nombreController = TextEditingController();
  TextEditingController ciController = TextEditingController();
  TextEditingController telefonoController = TextEditingController();
  TextEditingController correoController = TextEditingController();
  TextEditingController contraseniaController = TextEditingController();

  final CollectionReference _items =
      FirebaseFirestore.instance.collection('users');
  void updateSupervisor(String documentId, String newName, String newEmail,
      String newCI, String newPhone) async {
    try {
      // Obtener una referencia al documento
      DocumentReference documentReference = _items.doc(documentId);

      // Actualizar el campo 'nombre' con el nuevo valor

      if (!newName.isEmpty) {
        await documentReference.update({
          'fullname': newName,
        });
      }
      if (!newEmail.isEmpty) {
        await documentReference.update({
          'email': newEmail,
        });
      }
      if (!newCI.isEmpty) {
        await documentReference.update({
          'ci': newCI,
        });
      }
      if (!newPhone.isEmpty) {
        await documentReference.update({
          'phone': newPhone,
        });
      }
      print('Dato actualizado correctamente.');
    } catch (error) {
      print('Error al actualizar el dato: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    nombreController.text = widget.fullname;
    ciController.text = widget.ci;
    telefonoController.text = widget.phone;
    correoController.text = widget.email;
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Amiga'),
        backgroundColor: Pallete.pink,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                'Modificar Supervisores',
                style: TextStyle(
                  color: Pallete.pink,
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 110),
                    child: MyTextField(
                      controller: nombreController,
                      hintText: 'Nombre Completo',
                      labelText: 'Nombre Completo',
                      obscureText: false,
                      isEnabled: true,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      left: 110,
                      right: 10,
                    ),
                    child: MyTextField(
                      controller: ciController,
                      hintText: 'CI',
                      labelText: 'CI',
                      obscureText: false,
                      isEnabled: true,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      left: 10,
                      right: 110,
                    ),
                    child: MyTextField(
                      controller: telefonoController,
                      hintText: 'Telefono',
                      labelText: 'Telefono',
                      obscureText: false,
                      isEnabled: true,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 110),
                    child: MyTextField(
                      controller: correoController,
                      hintText: 'Correo',
                      labelText: 'Correo',
                      obscureText: false,
                      isEnabled: true,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              margin: EdgeInsets.only(top: 20),
              width: 800,
              child: Button(
                text: 'Guardar',
                onPressed: () {
                  updateSupervisor(
                      widget.documentId,
                      nombreController.text,
                      correoController.text,
                      ciController.text,
                      telefonoController.text);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ReportSupervisor(),
                    ),
                  );
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
