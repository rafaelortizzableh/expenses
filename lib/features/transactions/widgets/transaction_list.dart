import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../features.dart';

class TransactionList extends ConsumerWidget {
  TransactionList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      child: (ref.watch(transactionsProvider) as TransactionsLoaded)
              .transactions
              .isEmpty
          ? Column(
              children: <Widget>[
                Text(
                  'No transactions added yet!',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                SizedBox(height: 24.0),
                Container(
                  height: 200,
                  child: Image.asset(
                    'assets/images/waiting.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.01),
              itemBuilder: (context, index) {
                final transaction =
                    (ref.watch(transactionsProvider) as TransactionsLoaded)
                        .transactions[index];
                return TransactionCard(transaction: transaction);
              },
              itemCount: (ref.watch(transactionsProvider) as TransactionsLoaded)
                  .transactions
                  .length,
            ),
    );
  }
}

class TransactionCard extends ConsumerWidget {
  const TransactionCard({
    required this.transaction,
    Key? key,
  }) : super(key: key);
  final Transaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 5,
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          child: Padding(
            padding: EdgeInsets.all(6),
            child: FittedBox(
              child: Text('\$${transaction.amount}'),
            ),
          ),
        ),
        title: Text(
          transaction.title,
          style: Theme.of(context).textTheme.subtitle1,
        ),
        subtitle: Text(
          DateFormat.yMMMd().format(transaction.date),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          color: Theme.of(context).errorColor,
          onPressed: () async => await ref
              .read(transactionsProvider.notifier)
              .deleteTransaction(transaction),
        ),
      ),
    );
  }
}
