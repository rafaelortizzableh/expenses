import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with TickerProviderStateMixin<MyHomePage> {
  late AnimationController _hideFabAnimation;

  @override
  initState() {
    super.initState();
    _hideFabAnimation =
        AnimationController(vsync: this, duration: kThemeAnimationDuration)
          ..forward();
  }

  @override
  void dispose() {
    _hideFabAnimation.dispose();
    super.dispose();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0) {
      if (notification is UserScrollNotification) {
        final UserScrollNotification userScroll = notification;
        switch (userScroll.direction) {
          case ScrollDirection.forward:
            if (userScroll.metrics.maxScrollExtent !=
                userScroll.metrics.minScrollExtent) {
              _hideFabAnimation.forward();
            }
            break;
          case ScrollDirection.reverse:
            if (userScroll.metrics.maxScrollExtent !=
                userScroll.metrics.minScrollExtent) {
              _hideFabAnimation.reverse();
            }
            break;
          case ScrollDirection.idle:
            break;
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Scaffold(
        appBar: AppBar(title: Text('Personal Expenses'), actions: [
          Consumer(builder: (context, ref, _) {
            return IconButton(
                icon: Icon(Icons.add),
                onPressed: () => _startAddNewTransaction(context, ref));
          })
        ]),
        body: Consumer(builder: (context, ref, _) {
          return FutureBuilder<void>(
              future: ref
                  .watch(transactionsProvider.notifier)
                  .loadInitialTransactions(),
              builder: (context, snapshot) {
                return TransactionsBody();
              });
        }),
        floatingActionButton: Consumer(builder: (context, ref, _) {
          var _transactions = ref.watch(transactionsProvider);
          return _transactions is TransactionsLoaded
              ? ScaleTransition(
                  scale: _hideFabAnimation,
                  child: FloatingActionButton(
                    child: Icon(Icons.add),
                    onPressed: () => _startAddNewTransaction(context, ref),
                  ),
                )
              : SizedBox();
        }),
      ),
    );
  }
}

class TransactionsBody extends ConsumerWidget {
  const TransactionsBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var _transactions = ref.watch(transactionsProvider);

    if (_transactions is TransactionsError) {
      return Center(child: Text(_transactions.error));
    } else if (_transactions is TransactionsLoaded) {
      List<Widget> _widgets = [
        Container(
          height: MediaQuery.of(context).size.height * 0.33,
          child: ListView.separated(
            physics: PageScrollPhysics(),
            itemBuilder: (context, index) {
              List<Widget> _widgets = [
                Chart(_transactions.recentTransactions),
                HistoricCard(typeOfDate: MonthOrYear.month),
                HistoricCard(typeOfDate: MonthOrYear.year),
              ];
              return _widgets[index];
            },
            padding: EdgeInsets.symmetric(
                vertical: 16,
                horizontal: MediaQuery.of(context).size.width * 0.05),
            separatorBuilder: (context, index) => SizedBox(
                width: index == 0
                    ? MediaQuery.of(context).size.width * 0.1
                    : MediaQuery.of(context).size.width * 0.05),
            itemCount: 3,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
          ),
        ),
        TransactionList(),
      ];
      return ListView.builder(
          itemCount: _widgets.length,
          itemBuilder: (context, index) {
            return _widgets[index];
          });
    } else {
      return Center(child: CircularProgressIndicator.adaptive());
    }
  }
}

void _startAddNewTransaction(BuildContext context, WidgetRef ref) async {
  final newTransaction = await showModalBottomSheet(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15.0),
    ),
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    context: context,
    builder: (_) {
      return GestureDetector(
        onTap: () {},
        child: NewTransaction(),
        behavior: HitTestBehavior.opaque,
      );
    },
  );
  if (newTransaction is Transaction) {
    ref.read(transactionsProvider.notifier).addTransaction(newTransaction);
  }
}
