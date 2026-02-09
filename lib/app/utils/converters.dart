import 'package:intl/intl.dart';

/// Parses [value] to a valid [int] that represents the value in BRL (multiplied by 100 for precision)
/// Ex: if [value] is 'R$ 123.45', the function returns the int 12345
/// For displaying, it will be necessary to divide the int by 100 
int parseInputToBrazilianCurrency(String value) {
  if (value.isEmpty) return 0;

  return (double.parse(
            value
                .replaceAll('R\$', '')
                .replaceAll(' ', '')
                .replaceAll('.', '')
                .replaceAll(',', '.'),
          ) *
          100)
      .toInt();
}

String parseIntToBrazilianCurrentFormat(int value) {
  final format = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  return format.format(value / 100);
}

String datetimeToBrString(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}