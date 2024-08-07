// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';

class DateRange extends StatefulWidget {
  @override
  _DateRangeState createState() => _DateRangeState();
}

class _DateRangeState extends State<DateRange> {
  DateTime? _primeraFecha;
  DateTime? _ultimaFecha;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          onPressed: () {
            _seleccionarRangoDeFechas(context);
          },
          child: Text('Seleccionar rango de fechas'),
        ),
        SizedBox(height: 20),
        if (_primeraFecha != null && _ultimaFecha != null)
          Text('Desde: $_primeraFecha hasta: $_ultimaFecha'),
      ],
    );
  }

  Future<void> _seleccionarRangoDeFechas(BuildContext context) async {
    final DateTime? primeraFechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.pink, // Cambia el color del seleccionador
            colorScheme: ColorScheme.light(primary: Colors.pink),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (primeraFechaSeleccionada != null) {
      final DateTime? ultimaFechaSeleccionada = await showDatePicker(
        context: context,
        initialDate: primeraFechaSeleccionada,
        firstDate: primeraFechaSeleccionada,
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              primaryColor: Colors.pink, // Cambia el color del seleccionador
              colorScheme: ColorScheme.light(primary: Colors.pink),
              buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
            ),
            child: child!,
          );
        },
      );

      if (ultimaFechaSeleccionada != null) {
        setState(() {
          _primeraFecha = primeraFechaSeleccionada;
          _ultimaFecha = ultimaFechaSeleccionada;
        });
      }
    }
  }
}
