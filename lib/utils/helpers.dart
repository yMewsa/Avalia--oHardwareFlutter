import 'package:intl/intl.dart';

String formatDateTime(DateTime dateTime) {
  return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
}

String formatDistance(double meters) {
  return '${meters.toStringAsFixed(1)} m';
}
