/// Datos de tarjeta solo en memoria durante el pago. Nunca se guardan.
class CardData {
  const CardData({
    required this.holder,
    required this.number,
    required this.expiry,
    required this.cvv,
  });

  final String holder;
  final String number;
  final String expiry;
  final String cvv;

  String get digits => number.replaceAll(RegExp(r'\D'), '');

  String get last4 =>
      digits.length >= 4 ? digits.substring(digits.length - 4) : digits;

  String get brand {
    if (digits.startsWith('4')) return 'Visa';
    if (RegExp(r'^(5[1-5]|2[2-7])').hasMatch(digits)) return 'Mastercard';
    if (RegExp(r'^3[47]').hasMatch(digits)) return 'Amex';
    return 'Tarjeta';
  }
}