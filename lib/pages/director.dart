// ignore_for_file: prefer_const_constructors, depend_on_referenced_packages, unused_import, library_private_types_in_public_api, use_key_in_widget_constructors, prefer_final_fields, deprecated_member_use, use_build_context_synchronously, avoid_print, prefer_const_literals_to_create_immutables

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:slim_web/components/Menu.dart';
import 'package:slim_web/components/button.dart';
import 'package:slim_web/components/pallete.dart';
import 'package:slim_web/components/textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:slim_web/pages/perfil.dart';
import 'package:slim_web/pages/widgets/custom_app_bar.dart';
import 'package:universal_html/html.dart' as html;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class Director extends StatefulWidget {
  @override
  _DirectorState createState() => _DirectorState();
}

class _DirectorState extends State<Director> {
  File? _image;
  Uint8List? _imageBytes;
  final formKey = GlobalKey<FormState>();
  final nombreController = TextEditingController();
  final ciController = TextEditingController();
  final telefonoController = TextEditingController();
  final correoController = TextEditingController();
  final contraseniaController = TextEditingController();

  Future getImage() async {
    //save _image file
    final imagePicker = ImagePicker();
    final XFile? pickedFile =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final html.File file =
          html.File([await pickedFile.readAsBytes()], pickedFile.path);
      final html.FileReader reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((event) {
        final List<int> bytes = reader.result as List<int>;
        setState(() {
          _image = File(pickedFile.path);
          print('_image!.path: ${_image!.path}');
          _imageBytes = Uint8List.fromList(bytes);
          print(_imageBytes!.lengthInBytes);
        });
      });
    }
  }

  Future<String> uploadImage(Uint8List imageFile, String supervisorId) async {
    try {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('PerfilDirectores')
          .child('$supervisorId.jpg');

      firebase_storage.UploadTask uploadTask = ref.putData(imageFile);

      firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;

      String url = await taskSnapshot.ref.getDownloadURL();

      return url;
    } on Exception {
      throw Exception('Error al subir la imagen');
    }
  }

  Future<void> registrarDirectorEnFirebase() async {
    // Leer los datos de los campos de texto
    String nombre = nombreController.text;
    String ci = ciController.text;
    String telefono = telefonoController.text;
    String correo = correoController.text;
    String contrasenia = contraseniaController.text;

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: correo,
        password: contrasenia,
      );

      String userId = userCredential.user!.uid;
      String url = '';

      if (_imageBytes != null) {
        url = await uploadImage(_imageBytes!, userId);
      }

      Map<String, dynamic> userData = {
        'nombre': nombre,
        'ci': ci,
        'telefono': telefono,
        'correo': correo,
        'contrasenia': contrasenia,
        'photo': url,
      };
      print('userData: $userData');

      await FirebaseFirestore.instance
          .collection('directores')
          .doc(userId)
          .set(userData);

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Perfil()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print('El correo electrónico ya está en uso');
      }
    } catch (error) {
      print("Error al registrar el director: $error");
    }
  }

  // Método para validar el password
  String? validatePassword(String? value) {
    // Al menos 8 caracteres, al menos una letra mayúscula y al menos un número
    final RegExp passwordExp = RegExp(r'^(?=.*?[A-Z])(?=.*?[0-9]).{8,}$');

    if (value == null || value.isEmpty || !passwordExp.hasMatch(value)) {
      return 'La contraseña debe tener al menos 8 caracteres, al menos una letra mayúscula y al menos un número.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        'Nuevo Director',
                        style: TextStyle(
                          color: Color(0xFFD15A7C),
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                      height:
                          20), // Espacio entre el título y los campos de texto
                ],
              ),
              const SizedBox(height: 16),
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
                              child: _imageBytes != null
                                  ? Image.memory(
                                      _imageBytes!,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 60,
                                    ),
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
                        hintText: 'Nombre Completo',
                        labelText: 'Nombre Completo',
                        obscureText: false,
                        isEnabled: true,
                        validator: (value) {
                          final RegExp nameExp = RegExp(r"^[A-Za-z ]+$");
                          if (value == null ||
                              value.isEmpty ||
                              !nameExp.hasMatch(value)) {
                            return 'Ingresa un nombre válido';
                          }
                          return null;
                        },
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
                        validator: (value) {
                          final RegExp ciExp = RegExp(r"^[0-9]+$");
                          if (value == null ||
                              value.isEmpty ||
                              !ciExp.hasMatch(value)) {
                            return 'Ingresa un CI válido';
                          }
                          return null;
                        },
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
                        validator: (value) {
                          final RegExp ciExp = RegExp(r"^[0-9]{8}$");
                          if (value == null ||
                              value.isEmpty ||
                              !ciExp.hasMatch(value)) {
                            return 'Ingresa un número válido de 8 dígitos';
                          }
                          return null;
                        },
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
                        validator: (value) {
                          // Expresión regular para validar un correo electrónico
                          final RegExp emailExp = RegExp(
                              r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

                          if (value == null ||
                              value.isEmpty ||
                              !emailExp.hasMatch(value)) {
                            return 'Ingresa un correo electrónico válido';
                          }

                          return null;
                        },
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
                        controller: contraseniaController,
                        hintText: 'Contraseña',
                        labelText: 'Contraseña',
                        obscureText: true,
                        isEnabled: true,
                        validator: validatePassword,
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
                    
                    if (formKey.currentState!.validate()) {

                      if (_imageBytes == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Selecciona una imagen'),
                          ),
                        );
                        return;
                      }
                      
                      registrarDirectorEnFirebase();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
