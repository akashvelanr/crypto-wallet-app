import 'package:flutter/material.dart';
import 'package:crypto_wallet/ui/component/card.dart';
import 'package:crypto_wallet/ui/screen/home.dart';
import 'package:crypto_wallet/wallet_provider.dart';
import 'package:provider/provider.dart';

class SendScreen extends StatelessWidget {
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: SafeArea(
            child: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: 78,
          title: Text('Send'),
        )),
      ),
      backgroundColor: Colors.blueGrey[50],
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: "Receiver Address",
                    )),
                TextField(
                  controller: _amountController,
                  decoration: InputDecoration(labelText: "Amount in ETH"),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    try {
                      final address = _addressController.text;
                      final amount = double.parse(_amountController.text);
                      Provider.of<WalletProvider>(context, listen: false)
                          .sendTransaction(address, amount);
                    } catch (e) {
                      print(e);
                      showErrorDialog(context, e.toString());
                    }
                  },
                  child: Text(
                    "Send",
                    textScaler: TextScaler.linear(1.4),
                  ),
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
        )
      ]),
    );
  }
}
