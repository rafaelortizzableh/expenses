import '../../features.dart';

abstract class TransactionsState {}

class TransactionsLoading extends TransactionsState {}

class TransactionsError extends TransactionsState {
  String error;
  TransactionsError({required this.error});
}

class TransactionsLoaded extends TransactionsState {
  final List<Transaction> transactions;
  TransactionsLoaded({this.transactions = const []});

  List<Transaction> get recentTransactions {
    return transactions.where((tx) {
      return tx.date.isBefore(DateTime.now()) &&
          tx.date.isAfter(DateTime.now().subtract(Duration(days: 7)));
    }).toList();
  }

  List<Transaction> get monthTransactions {
    return transactions.where((tx) {
      return tx.date.isBefore(DateTime.now()) &&
          tx.date.isAfter(DateTime.now().subtract(Duration(days: 30)));
    }).toList();
  }

  List<Transaction> get yearTransactions {
    return transactions.where((tx) {
      return tx.date.isBefore(DateTime.now()) &&
          tx.date.isAfter(DateTime.now().subtract(Duration(days: 365)));
    }).toList();
  }

  num get yearTotal {
    num total = 0;
    List<double> transactionAmounts =
        yearTransactions.map((trans) => trans.amount).toList();
    transactionAmounts.forEach((element) => total += element);
    return total;
  }

  num get monthTotal {
    num total = 0;
    List<double> transactionAmounts =
        monthTransactions.map((trans) => trans.amount).toList();
    transactionAmounts.forEach((element) => total += element);
    return total;
  }
}
