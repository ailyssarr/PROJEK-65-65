import 'package:intl/intl.dart';

enum AppTimeZone { wib, wita, wit, london }

String timeZoneLabel(AppTimeZone tz) {
  switch (tz) {
    case AppTimeZone.wib:
      return 'WIB (UTC+7)';
    case AppTimeZone.wita:
      return 'WITA (UTC+8)';
    case AppTimeZone.wit:
      return 'WIT (UTC+9)';
    case AppTimeZone.london:
      return 'London (UTC+0)';
  }
}

/// baseTime dianggap WIB
DateTime convertFromWib(DateTime baseTime, AppTimeZone target) {
  final utc = baseTime.toUtc().subtract(const Duration(hours: 7));
  int offset = 0;
  switch (target) {
    case AppTimeZone.wib:
      offset = 7;
      break;
    case AppTimeZone.wita:
      offset = 8;
      break;
    case AppTimeZone.wit:
      offset = 9;
      break;
    case AppTimeZone.london:
      offset = 0;
      break;
  }
  return utc.add(Duration(hours: offset));
}

String formatDateTime(DateTime dt) {
  return DateFormat('dd MMM yyyy HH:mm').format(dt);
}

// ==== CURRENCY ====
enum Currency { idr, usd, eur, jpy }

String currencyLabel(Currency c) {
  switch (c) {
    case Currency.idr:
      return 'IDR';
    case Currency.usd:
      return 'USD';
    case Currency.eur:
      return 'EUR';
    case Currency.jpy:
      return 'JPY';
  }
}

String currencySymbol(Currency c) {
  switch (c) {
    case Currency.idr:
      return 'Rp';
    case Currency.usd:
      return '\$';
    case Currency.eur:
      return '€';
    case Currency.jpy:
      return '¥';
  }
}

double convertFromIdr(double amount, Currency target) {
  const idrToUsd = 1 / 16000;
  const idrToEur = 1 / 17500;
  const idrToJpy = 1 / 110;

  switch (target) {
    case Currency.idr:
      return amount;
    case Currency.usd:
      return amount * idrToUsd;
    case Currency.eur:
      return amount * idrToEur;
    case Currency.jpy:
      return amount * idrToJpy;
  }
}

String formatCurrency(double amount, Currency c) {
  return '${currencySymbol(c)} ${amount.toStringAsFixed(2)}';
}
