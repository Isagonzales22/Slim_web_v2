// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors, non_constant_identifier_names, must_be_immutable, library_private_types_in_public_api, prefer_const_constructors_in_immutables, avoid_print

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:slim_web/components/button.dart';
import 'package:slim_web/components/pallete.dart';
import 'package:slim_web/components/textfield.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:slim_web/pages/page_images.dart';
import 'package:slim_web/pages/report_cases.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:slim_web/pages/widgets/custom_app_bar.dart';
import 'package:slim_web/pages/widgets/custom_text_area.dart';
import 'dart:html' as html;
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;
/*import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';*/

class ReportCase extends StatefulWidget {
  final Case caseData;

  ReportCase({required this.caseData});
  @override
  _ReportCaseState createState() => _ReportCaseState();
}

class _ReportCaseState extends State<ReportCase> {
  TextEditingController nombreController = TextEditingController();
  TextEditingController correoController = TextEditingController();
  TextEditingController ciController = TextEditingController();
  TextEditingController telefonoController = TextEditingController();
  TextEditingController descripcionController = TextEditingController();
  TextEditingController supervisorController = TextEditingController();
  TextEditingController estadoController = TextEditingController();
  TextEditingController fechaController = TextEditingController();
  TextEditingController descripcionFinalController = TextEditingController();

  List<String> images = [];

  void mostrarImagenes(BuildContext context, List<String> images) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height / 3,
          child: ListView.builder(
            itemCount: images.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Pallete.pink.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Image.network(
                        images[index],
                        height: 300,
                        width: 300,
                      ),
                      SizedBox(height: 16),
                    ],
                  ));
            },
          ),
        );
      },
    );
    // Lógica para mostrar imágenes
  }

  void reproducirAudio(String url) {
    final audioElement = html.AudioElement(url);
    audioElement.controls = true;
    audioElement.play();
  }

  void abrirPDF(BuildContext context) {
    // Lógica para abrir un archivo PDF
  }

  void Next(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Reports(),
      ),
    );
  }

  Future<void> _printPdfCase(Case caseData) async {
    try {
      final pdf = pw.Document();

      final DateTime now = DateTime.now();
      final String formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(now);

      pdf.addPage(
        pw.MultiPage(
          build: (context) {
            List<pw.Widget> content = [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Reporte de Caso',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 24),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Fecha de impresión: $formattedDate',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Información del Caso:',
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18),
              ),
              pw.Divider(thickness: 1, color: PdfColors.grey),
              pw.SizedBox(height: 10),
              _buildCaseInfo('Nombre Completo', caseData.denunciante.fullname),
              _buildCaseInfo('Correo', caseData.supervisor.email),
              _buildCaseInfo('Ci', caseData.supervisor.ci.toString()),
              _buildCaseInfo('Telefono', caseData.supervisor.phone.toString()),
              _buildCaseInfo('Descripcion del caso',
                  caseData.incidente.descriptionIncidente),
              _buildCaseInfo('Supervisor', caseData.supervisor.fullname),
              _buildCaseInfo('Estado', caseData.estado),
              _buildCaseInfo(
                  'Fecha y hora de inicio', caseData.fecha.toString()),
              _buildCaseInfo(
                  'Descripcion final', descripcionFinalController.text),
              pw.SizedBox(height: 20),
              pw.Divider(thickness: 1, color: PdfColors.grey),
              pw.SizedBox(height: 10),
              pw.Text(
                'Recursos:',
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18),
              ),
              pw.SizedBox(height: 10),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Imagenes:',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 16),
                  ),
                  pw.SizedBox(height: 10),
                  for (var image in caseData.incidente.imageUrl)
                    pw.Container(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.UrlLink(child: pw.Text(image), destination: image),
                          pw.SizedBox(height: 10),
                        ],
                      ),
                    ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Audio:',
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.UrlLink(
                        child: pw.Text(caseData.incidente.audioUrl),
                        destination: caseData.incidente.audioUrl),
                    pw.SizedBox(height: 10),
                  ],
                ),
              ),
            ];
            return content;
          },
        ),
      );

      await Printing.sharePdf(
          bytes: await pdf.save(), filename: 'InformacionDeCaso.pdf');
    } on Exception {
      rethrow;
    }
  }

  pw.Widget _buildCaseInfo(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '$label:',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(value),
        pw.SizedBox(height: 10),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    // Call the function to obtain data when the widget initializes
    obtenerDatosFirebase(widget.caseData);
  }

  Future<void> obtenerDatosFirebase(Case data) async {
    setState(() {
      nombreController.text = data.denunciante.fullname;
      correoController.text = data.supervisor.email;
      ciController.text = data.supervisor.ci.toString();
      telefonoController.text = data.supervisor.phone.toString();
      descripcionController.text = data.incidente.descriptionIncidente;
      supervisorController.text = data.supervisor.fullname;
      estadoController.text = data.estado;
      fechaController.text = data.fecha.toString() ?? '';
      descripcionFinalController.text = data.evidence.isEmpty
          ? 'No hay una descripcion disponible'
          : data.evidence.first.description;
      images = data.incidente.imageUrl.isEmpty
          ? [
              'lib/images/google.png',
              'lib/images/logo.png',
              'lib/images/profiles.png',
            ]
          : data.incidente.imageUrl;
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              'Caso',
              style: TextStyle(
                color: Color(0xFFD15A7C),
                fontWeight: FontWeight.bold,
                fontSize: 40,
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width / 1.5,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 110),
                      child: MyTextField(
                        hintText: 'Nombre Completo',
                        labelText: 'Nombre Completo',
                        obscureText: false,
                        isEnabled: false,
                        controller: nombreController,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: MediaQuery.of(context).size.width / 1.5,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 110),
                      child: MyTextField(
                        hintText: 'Correo',
                        labelText: 'Correo',
                        obscureText: false,
                        isEnabled: false,
                        controller: correoController,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: MediaQuery.of(context).size.width / 1.5,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 110, right: 10),
                      child: MyTextField(
                        hintText: 'Ci',
                        labelText: 'Ci',
                        obscureText: false,
                        isEnabled: false,
                        controller: ciController,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 10, right: 110),
                      child: MyTextField(
                        hintText: 'Telefono',
                        labelText: 'Telefono',
                        obscureText: false,
                        isEnabled: false,
                        controller: telefonoController,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: MediaQuery.of(context).size.width / 1.5,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 110),
                      child: MyTextField(
                        hintText: 'Descripcion del caso',
                        labelText: 'Descripcion del caso',
                        obscureText: false,
                        isEnabled: false,
                        controller: descripcionController,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 110, right: 10),
                    child: MyTextField(
                      hintText: 'Supervisor',
                      labelText: 'Supervisor',
                      obscureText: false,
                      isEnabled: false,
                      controller: supervisorController,
                    ),
                  ),
                  SizedBox(width: 16),
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 110),
                    child: MyTextField(
                      hintText: 'Estado',
                      labelText: 'Estado',
                      obscureText: false,
                      isEnabled: false,
                      controller: estadoController,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            SizedBox(
              width: MediaQuery.of(context).size.width / 1.5,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 110),
                      child: MyTextField(
                        hintText: 'Fecha y hora de inicio',
                        isEnabled: false,
                        labelText: 'Fecha y hora de inicio',
                        isDateField: true,
                        obscureText: false,
                        controller: fechaController,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
                width: MediaQuery.of(context).size.width / 1.9,
                child: MyTextField(
                    controller: descripcionFinalController,
                    hintText: 'Descripcion final',
                    labelText: 'Descripcion final',
                    isEnabled: false)),
            SizedBox(height: 16),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: Column(
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 300,
                      enlargeCenterPage: true,
                      autoPlay: true,
                      viewportFraction: 1.0,
                    ),
                    items: images.map((image) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  offset: Offset(0, 2),
                                  blurRadius: 6.0,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                image,
                                height: 300,
                                width: 300,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: MediaQuery.of(context).size.width / 1.5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Button(
                    text: 'Imagenes',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PageImages(images: images),
                        ),
                      );
                    },
                  ),
                  Button(
                    text: 'Audio',
                    onPressed: () {
                      reproducirAudio(widget.caseData.incidente.audioUrl);
                    },
                  ),
                  Button(
                    text: 'PDF',
                    onPressed: () {
                      if (descripcionFinalController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                                'Debe llenar el campo de descripcion final'),
                          ),
                        );
                        return;
                      }
                      _printPdfCase(widget.caseData);
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: MediaQuery.of(context).size.width / 1.5,
              child: Button(
                text: 'Imprimir',
                onPressed: () {
                  if (descripcionFinalController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red,
                        content:
                            Text('Debe llenar el campo de descripcion final'),
                      ),
                    );
                    return;
                  }
                  _printPdfCase(widget.caseData);
                },
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
