import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../features.dart';

class NewTransaction extends StatefulWidget {
  const NewTransaction();

  @override
  _NewTransactionState createState() => _NewTransactionState();
}

class _NewTransactionState extends State<NewTransaction> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;

  void _submitData() {
    final enteredTitle = _titleController.text;

    final enteredAmount =
        double.parse(_amountController.text.replaceAll(',', '.'));

    if (enteredAmount <= 0 || _selectedDate == null) {
      return;
    }

    Navigator.of(context).pop(Transaction(
      amount: enteredAmount,
      title: enteredTitle,
      date: _selectedDate!,
      id: DateTime.now().toString(),
    ));
  }

  void _presentDatePicker() {
    final currentDate = DateTime.now();
    showDatePicker(
        context: context,
        initialDate: currentDate,
        firstDate: DateTime(1990),
        lastDate: currentDate,
        selectableDayPredicate: (DateTime day) {
          if (day == DateTime.now()) {
            return false;
          } else {
            return true;
          }
        }).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AnimatedContainer(
        margin: const EdgeInsets.only(bottom: 32),
        duration: const Duration(milliseconds: 250),
        padding: MediaQuery.of(context).viewInsets,
        child: Card(
          elevation: 5,
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'New Transaction',
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Title'),
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _submitData(),
                  onChanged: (text) => setState(() {}),
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Amount'),
                  controller: _amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (text) => setState(() {}),
                  onSubmitted: (_) => _submitData(),
                ),
                Container(
                  height: 70,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          _selectedDate == null
                              ? 'Pick a date'
                              : 'Picked Date: ${DateFormat.yMd().format(_selectedDate!)}',
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(),
                        child: Text(
                          'Choose Date',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor),
                        ),
                        onPressed: _presentDatePicker,
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  child: Text('Add Transaction'),
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                  ),
                  onPressed: _amountController.text.isEmpty ||
                          _titleController.text.isEmpty ||
                          _selectedDate == null
                      ? null
                      : _submitData,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
