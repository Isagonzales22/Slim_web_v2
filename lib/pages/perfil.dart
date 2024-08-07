// ignore_for_file: prefer_const_constructors, depend_on_referenced_packages, unused_import, library_private_types_in_public_api, use_key_in_widget_constructors, prefer_final_fields, deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:slim_web/components/menu.dart';
import 'package:slim_web/components/button.dart';
import 'package:slim_web/components/pallete.dart';
import 'package:slim_web/components/textfield.dart';
import 'package:slim_web/pages/director.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:slim_web/pages/widgets/custom_app_bar.dart';

class Perfil extends StatefulWidget {
  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<Perfil> {
  File? _image;

  TextEditingController nombreController = TextEditingController();
  TextEditingController ciController = TextEditingController();
  TextEditingController telefonoController = TextEditingController();
  TextEditingController correoController = TextEditingController();
  String url = '';

  Future getImage() async {
    // Código para obtener la imagen...
  }

  void sig(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Director(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    try {
      final storage = FlutterSecureStorage();
      final uid = await storage.read(key: 'user');

      final query = await FirebaseFirestore.instance
          .collection('directores')
          .doc(uid)
          .get();

      final data = query.data();

      if (data != null) {
        setState(() {
          nombreController.text = data['nombre'] ?? '' ;
          ciController.text = data['ci'] ?? '';
          telefonoController.text = data['telefono'] ?? '';
          correoController.text = data['correo'] ?? '';
          url = data['photo'] ?? '';
        });
      }
    } on Exception catch (e) {
      print("Error al cargar los datos: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: getImage,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 110),
                      child: CircleAvatar(
                        radius: 80,
                        backgroundColor: Pallete.pink,
                        child: ClipOval(
                          child: SizedBox(
                            width: 160,
                            height: 160,
                            child: url.isNotEmpty
                                ? Image.network(
                                    url,
                                    width: 160,
                                    height: 160,
                                    fit: BoxFit.cover,
                                  )
                                : Icon(Icons.person, size: 160, color: Colors.white,)
                          ),
                        ),
                      ),
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
                      controller: nombreController,
                      hintText: 'Nombre ',
                      labelText: 'Nombre',
                      obscureText: false,
                      isEnabled: false,
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
                      isEnabled: false,
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
                      isEnabled: false,
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
                      isEnabled: false,
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
                text: 'Nuevo Director',
                onPressed: () {
                  sig(context);
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
