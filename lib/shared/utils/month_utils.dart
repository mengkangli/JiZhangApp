bool isCurrentOrFutureMonth(DateTime month) {
  final now = DateTime.now();
  final current = DateTime(now.year, now.month);
  final normalized = DateTime(month.year, month.month);
  return !normalized.isBefore(current);
}

DateTime clampToCurrentMonth(DateTime month) {
  final now = DateTime.now();
  final current = DateTime(now.year, now.month);
  final normalized = DateTime(month.year, month.month);
  return normalized.isAfter(current) ? current : normalized;
}
