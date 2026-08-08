String formatAmount(double value) {
  final isNegative = value < 0;
  final abs = value.abs().toStringAsFixed(2);
  final parts = abs.split('.');
  final whole = parts[0];
  final buf = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) buf.write(',');
    buf.write(whole[i]);
  }
  return '${isNegative ? '-' : ''}$buf.${parts[1]}';
}

String formatDate(DateTime date) {
  final day = '${date.day}'.padLeft(2, '0');
  final month = '${date.month}'.padLeft(2, '0');
  return '$day/$month/${date.year}';
}

String formatDateLong(DateTime date) {
  const months = [
    'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
    'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year + 543}';
}
