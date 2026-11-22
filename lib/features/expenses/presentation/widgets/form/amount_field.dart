import 'package:flutter/material.dart';
import 'package:tracker/shared/utils/currency_formatter.dart';

class AmountField extends StatelessWidget {
  const AmountField({super.key, required this.controller, required this.color});

  final TextEditingController controller;

  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    const noBorder = InputBorder.none;

    final style = theme.textTheme.displayMedium?.copyWith(
      color: color,
      fontWeight: FontWeight.w700,
      letterSpacing: -2,
    );

    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      style: style,
      cursorColor: color,
      decoration: InputDecoration(
        labelText: 'Monto',
        labelStyle: TextStyle(color: color.withValues(alpha: 0.7)),
        floatingLabelStyle: TextStyle(color: color.withValues(alpha: 0.7)),
        prefixText: r'$ ',
        prefixStyle: style?.copyWith(
          color: color.withValues(alpha: 0.6),
          fontWeight: FontWeight.w500,
        ),
        errorStyle: TextStyle(
          color: scheme.brightness == Brightness.light
              ? scheme.error
              : const Color(0xFFFFA39C),
        ),
        filled: false,
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        border: noBorder,
        enabledBorder: noBorder,
        focusedBorder: noBorder,
        errorBorder: noBorder,
        focusedErrorBorder: noBorder,
      ),
      validator: (value) {
        final cents = parseAmountToCents(value ?? '');
        if (cents == null) return 'Escribe un monto válido (ej. 125.50).';
        if (cents <= 0) return 'El monto debe ser mayor a 0.';
        return null;
      },
    );
  }
}
