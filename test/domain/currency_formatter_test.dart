import 'package:flutter_test/flutter_test.dart';
import 'package:tracker/shared/utils/currency_formatter.dart';
import 'package:tracker/shared/utils/date_formatter.dart';

void main() {
  group('parseAmountToCents', () {
    test('convierte enteros y decimales a centavos', () {
      expect(parseAmountToCents('125.50'), 12550);
      expect(parseAmountToCents('10'), 1000);
      expect(parseAmountToCents('0.07'), 7);
      expect(parseAmountToCents('0.1'), 10);
    });

    test('acepta coma decimal y espacios alrededor', () {
      expect(parseAmountToCents('125,5'), 12550);
      expect(parseAmountToCents('  42  '), 4200);
    });

    test('rechaza texto inválido', () {
      expect(parseAmountToCents(''), isNull);
      expect(parseAmountToCents('abc'), isNull);
      expect(parseAmountToCents('-5'), isNull);
      expect(parseAmountToCents('1.234'), isNull); // más de 2 decimales
      expect(parseAmountToCents('1.2.3'), isNull);
    });

    test('0 se parsea como 0 (la regla "mayor a 0" la aplica el dominio)', () {
      expect(parseAmountToCents('0'), 0);
    });
  });

  group('centsToInput / formatCents', () {
    test('centsToInput es el inverso de parseAmountToCents', () {
      expect(centsToInput(12550), '125.50');
      expect(centsToInput(7), '0.07');
      expect(centsToInput(1000), '10.00');
      expect(parseAmountToCents(centsToInput(98765)), 98765);
    });

    test('formatCents muestra pesos con dos decimales', () {
      expect(formatCents(12550), contains('125.50'));
      expect(formatCents(12550), startsWith(r'$'));
    });
  });

  group('fechas', () {
    test('toIsoDate y fromIsoDate se corresponden y ordenan como texto', () {
      final date = DateTime(2026, 3, 5, 18, 45);
      expect(toIsoDate(date), '2026-03-05');
      expect(fromIsoDate('2026-03-05'), DateTime(2026, 3, 5));
      expect(
        toIsoDate(DateTime(2026, 3, 5)).compareTo(toIsoDate(DateTime(2026, 11, 2))),
        lessThan(0),
      );
    });

    test('dateOnly quita la hora', () {
      expect(dateOnly(DateTime(2026, 11, 22, 23, 59)), DateTime(2026, 11, 22));
    });
  });
}
