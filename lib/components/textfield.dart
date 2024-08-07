// ignore_for_file: prefer_const_constructors, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:slim_web/components/pallete.dart';
import 'package:intl/intl.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final bool obscureText;
  final bool isEnabled;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;
  final bool isDateField;
  final IconData? icon;

  const MyTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    required this.isEnabled,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.isDateField = false,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 400,
      ),
      child: isDateField
          ? _buildDateField(context)
          : TextFormField(
              controller: controller,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(27),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isEnabled ? Pallete.pink : Colors.grey,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    width: 3,
                    color: Pallete.pink,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: hintText,
                labelText: labelText,
                labelStyle: const TextStyle(
                  color: Colors.black,
                ),
                prefixIcon: icon != null ? Icon(icon) : null,
              ),
              obscureText: obscureText,
              enabled: isEnabled,
              keyboardType: keyboardType,
              validator: validator,
            ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: isEnabled,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(27),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isEnabled ? Pallete.pink : Colors.grey,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            width: 3,
            color: Colors.blue,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        hintText: hintText,
        labelText: labelText,
        labelStyle: const TextStyle(
          color: Colors.black,
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: isEnabled
              ? () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );

                  if (pickedDate != null && pickedDate != controller.text) {
                    controller.text = DateFormat('dd-MM-yyyy').format(pickedDate);
                  }
                }
              : null,
        ),
      ),
      keyboardType: TextInputType.datetime,
      validator: validator,
    );
  }
}
