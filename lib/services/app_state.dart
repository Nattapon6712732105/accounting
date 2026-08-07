import 'package:flutter/foundation.dart';

class AppState {
  static final ValueNotifier<int> transactionsChanged = ValueNotifier(0);

  static void notifyTransactionsChanged() {
    transactionsChanged.value++;
  }
}
