import '../models/card_data.dart';

class PaymentException implements Exception {
  const PaymentException(this.message);
  final String message;
}

class PaymentResult {
  const PaymentResult(this.reference);
  final String reference;
}

/// Simulación propia de una pasarela de pagos.
/// - Cualquier tarjeta válida (Luhn) se aprueba.
/// - Las que terminan en 0002 se rechazan, para probar el flujo de error.
class PaymentSimulator {
  PaymentSimulator._();

  static Future<PaymentResult> charge({
    required CardData card,
    required double amount,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 2));

    if (card.digits.endsWith('0002')) {
      throw const PaymentException('Tarjeta rechazada. Intenta con otra.');
    }
    return PaymentResult('SIM-${DateTime.now().millisecondsSinceEpoch}');
  }
}