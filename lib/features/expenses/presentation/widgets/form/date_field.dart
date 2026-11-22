import 'package:flutter/material.dart';
import 'package:tracker/shared/utils/date_formatter.dart';

class DateField extends StatelessWidget {
  const DateField({super.key, required this.date, required this.onTap});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Fecha',
          prefixIcon: Icon(Icons.event_outlined),
        ),
        child: Text(formatDate(date)),
      ),
    );
  }
}
