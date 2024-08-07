import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:slim_web/components/pallete.dart';

class CustomDatePiker extends StatefulWidget {
  const CustomDatePiker(
      {super.key,
      required this.controller,
      required this.label,
      required this.hint,
      required this.widthLineR,
      required this.colorIcon,
      this.colored = false});

  final TextEditingController controller;
  final String label;
  final String hint;

  final double widthLineR;
  final Color colorIcon;
  final bool colored;

  @override
  State<CustomDatePiker> createState() => _CustomDatePikerState();
}

class _CustomDatePikerState extends State<CustomDatePiker> {
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.controller.text.isNotEmpty) {
      selectedDate = DateFormat('yyyy-MM-dd').parse(widget.controller.text);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        widget.controller.text = DateFormat('yyyy-MM-dd').format(selectedDate!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        filled: true,
       fillColor: Pallete.pink.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(fontSize: 14),
        prefixIcon: Icon(
          Icons.calendar_month_outlined,
          color: widget.colorIcon,
        ),
        hintText: widget.hint,
        labelText: widget.label,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: widget.colored
                ? Theme.of(context).primaryColor
                : Colors.grey.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Colors.blue,
        ),
      ),
      ),
      readOnly: true,
      onTap: () {
        _selectDate(context);
      },
    );
  }
}