import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../features.dart';

final transactionsProvider =
    StateNotifierProvider<TransactionsController, TransactionsState>(
  (_) => TransactionsController(),
);

class TransactionsController extends StateNotifier<TransactionsState> {
  TransactionsController() : super(TransactionsLoading());

  Future<void> loadInitialTransactions() async {
    try {
      final _transactionsBox = await Hive.openBox<Transaction>('transactions');
      final _transactions = _transactionsBox.values.toList();
      state = TransactionsLoaded(transactions: _transactions);
      await Hive.close();
    } catch (error) {
      state = TransactionsError(error: error.toString());
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    var _transactionsBox = await Hive.openBox<Transaction>('transactions');
    await _transactionsBox.add(transaction);
    final _transactions = _transactionsBox.values.toList();
    state = TransactionsLoaded(transactions: _transactions);
    await Hive.close();
  }

  Future<void> deleteTransaction(Transaction transaction) async {
    var _transactionsBox = await Hive.openBox<Transaction>('transactions');
    var _transactions = _transactionsBox.values.toList();
    final _transactionToDelete =
        _transactions.firstWhere((element) => element.id == transaction.id);
    await _transactionsBox.delete(_transactionToDelete.key);

    state = TransactionsLoaded(transactions: _transactionsBox.values.toList());
    await Hive.close();
  }
}
