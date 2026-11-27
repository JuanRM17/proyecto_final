class Validators {
  Validators._();

  static final _emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? required(String? v, String field) {
    if (v == null || v.trim().isEmpty) return '$field es obligatorio';
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
    if (!_emailRegExp.hasMatch(v.trim())) return 'Correo no válido';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
    if (v.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

    static String? cardHolder(String? v) {
    if (v == null || v.trim().length < 3) {
      return 'Escribe el nombre como aparece en la tarjeta';
    }
    return null;
  }

  static String? cardNumber(String? v) {
    final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length < 13 || digits.length > 19) {
      return 'Número de tarjeta incompleto';
    }
    if (!_luhn(digits)) return 'Número de tarjeta no válido';
    return null;
  }

  static bool _luhn(String digits) {
    var sum = 0;
    var alternate = false;
    for (var i = digits.length - 1; i >= 0; i--) {
      var n = int.parse(digits[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  static String? expiry(String? v) {
    final m = RegExp(r'^(\d{2})/(\d{2})$').firstMatch(v ?? '');
    if (m == null) return 'Usa el formato MM/AA';
    final month = int.parse(m.group(1)!);
    final year = 2000 + int.parse(m.group(2)!);
    if (month < 1 || month > 12) return 'Mes no válido';
    // Vigente hasta el último día del mes indicado.
    if (!DateTime.now().isBefore(DateTime(year, month + 1))) {
      return 'Tarjeta vencida';
    }
    return null;
  }

  static String? cvv(String? v) {
    if (!RegExp(r'^\d{3,4}$').hasMatch((v ?? '').trim())) {
      return 'CVV de 3 o 4 dígitos';
    }
    return null;
  }
}