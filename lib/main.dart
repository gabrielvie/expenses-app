import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:expenses_app/models/transaction.dart';
import 'package:expenses_app/widgets/chart.dart';
import 'package:expenses_app/widgets/transaction_form.dart';
import 'package:expenses_app/widgets/transaction_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String title = 'Personal Expenses';
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: this.title,
      theme: ThemeData(
        accentColor: Colors.amber,
        primarySwatch: Colors.green,
        fontFamily: 'MesloLGS NF',
        textTheme: ThemeData.light().textTheme.copyWith(
              headline6: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
              subtitle1: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: this.title),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({@required this.title});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _showChart = false;

  final List<Transaction> _userTransactions = [];

  List<Transaction> get _recentTransactions {
    return _userTransactions
        .where(
          (transaction) => transaction.dateTime.isAfter(
            DateTime.now().subtract(Duration(days: 7)),
          ),
        )
        .toList();
  }

  void _addNewTransaction(
    String transactionTitle,
    double transactionAmound,
    DateTime transactionDateTime,
  ) {
    var uuid = Uuid();
    final newTransaction = Transaction(
      uuid: uuid.v4(),
      title: transactionTitle,
      amount: transactionAmound,
      dateTime: transactionDateTime,
    );

    setState(() {
      _userTransactions.add(newTransaction);
    });
  }

  void _deleteTransaction(String transactionUuid) {
    setState(() {
      _userTransactions
          .removeWhere((transaction) => transaction.uuid == transactionUuid);
    });
  }

  void _showTransactionForm(BuildContext buildContext) {
    showModalBottomSheet(
      context: buildContext,
      builder: (_) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: TransactionForm(_addNewTransaction),
          onTap: () {},
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppBar appBar = AppBar(title: Text(widget.title));
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double devicePaddingTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: appBar,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text('Show Chart!'),
                Switch(
                    value: _showChart,
                    onChanged: (val) {
                      setState(() {
                        _showChart = val;
                      });
                    })
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
            _showChart
                ? Container(
                    child: Chart(_recentTransactions),
                    height: (deviceHeight -
                            appBar.preferredSize.height -
                            devicePaddingTop) *
                        (_showChart ? 0.7 : 0.3),
                  )
                : Container(
                    child:
                        TransactionList(_userTransactions, _deleteTransaction),
                    height: (deviceHeight -
                            appBar.preferredSize.height -
                            devicePaddingTop) *
                        0.7,
                  )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showTransactionForm(context),
      ),
    );
  }
}
