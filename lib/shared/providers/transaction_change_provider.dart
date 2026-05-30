import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final transactionChangeProvider = StateProvider<int>((ref) => 0);

void notifyTransactionChanged(BuildContext context) {
  final container = ProviderScope.containerOf(context, listen: false);
  final notifier = container.read(transactionChangeProvider.notifier);
  notifier.state++;
}
