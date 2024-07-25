// ignore_for_file: unused_import, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:crypto_wallet/account.dart';
import 'package:crypto_wallet/main.dart';
import 'package:crypto_wallet/ui/screen/recievescreen.dart';
import 'package:crypto_wallet/ui/screen/sendscreen.dart';
import 'package:crypto_wallet/wallet_provider.dart';
import 'package:crypto_wallet/wallet_service.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';
import '/ui/component/card.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List transactions = [];
  double usdValue = 0.0;
  double balance = 0;
  double ethusd = 0;

  @override
  void initState() {
    super.initState();
    _updateBalanceAndUsdValue();
    tranx();
  }

  Future<void> _updateBalanceAndUsdValue() async {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    await walletProvider.updateBalance();
    final balance = walletProvider.balance.getValueInUnit(EtherUnit.ether);
    print('Fetched Balance: $balance');
    final usdValue = await get_usd(balance);
    setState(() {
      this.usdValue = usdValue;
      this.balance = balance;
    });
    print('Updated USD Value: $usdValue');
  }

  Future<double> get_usd(double balance) async {
    String apiUrl = 'https://api-sepolia.etherscan.io/api'
        '?module=stats'
        '&action=ethprice'
        '&apikey=$etherscanApiKey';
    print('Balance: $balance');

    try {
      http.Response response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        double ethusd = double.parse(data['result']['ethusd']);
        setState(() {
          this.ethusd = ethusd;
        });
        double usdValue = balance * ethusd;
        print('USD Value: $usdValue');
        return usdValue;
      } else {
        print('Error fetching USD value: ${response.statusCode}');
        return 0.0;
      }
    } catch (e) {
      print('Error: $e');
      return 0.0;
    }
  }

  Future<void> tranx() async {
    client = Web3Client(rpcUrl, http.Client());
    credentials = EthPrivateKey.fromHex(privateKey);
    myAddress = await credentials.address;
    print("Wallet Address: ${myAddress.hex}");

    // Fetch transactions using Etherscan API
    String apiUrl =
        'https://api-sepolia.etherscan.io/api' //for other networks replace sepolia with other mainnet or other testnet
        '?module=account'
        '&action=txlist'
        '&address=${myAddress.hex}'
        '&startblock=0'
        '&endblock=99999999'
        '&sort=desc'
        '&apikey=$etherscanApiKey';

    http.Response response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      if (data['status'] == '1') {
        List _transactions = data['result'];
        _transactions.forEach((tx) {
          print(
              'From: ${tx['from']}, To: ${tx['to']}, Value: ${tx['value']}, Hash: ${tx['hash']}');
        });
        transactions = _transactions;
      } else {
        print('Error fetching transactions: ${data['message']}');
        showErrorDialog(
            context, 'Error fetching transactions: ${data['message']}');
        transactions = List.empty();
      }
    } else {
      print('Error fetching transactions: ${response.statusCode}');
      showErrorDialog(
          context, 'Error fetching transactions: ${response.statusCode}');

      transactions = List.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 25,
          ),
          GestureDetector(
            // onTap: () {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (context) => DetailWalletScreen()),
            //   );
            //},
            child: _cardWalletBalance(context),
          ),
          SizedBox(
            height: 15,
          ),
          Text('Past transactions', style: TextStyle(color: Colors.black45)),
          SizedBox(
            height: 15,
          ),
          Expanded(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: transactions.isNotEmpty
                    ? ListView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount: transactions.length,
                        itemBuilder: (BuildContext context, int index) {
                          return _transactionsList(
                              transaction: transactions[index]);
                        })
                    : Container(
                        alignment: Alignment.center,
                        child: Column(children: [
                          SizedBox(
                            height: 40,
                          ),
                          Text(
                            'No transactions',
                            textScaler: TextScaler.linear(1.5), //decor
                          ),
                        ]))),
          )
        ],
      ),
    );
  }

  Widget _cardWalletBalance(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child:
            Consumer<WalletProvider>(builder: (context, walletProvider, child) {
          return card(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ClipOval(
                      child: Material(
                        color: Colors.black87,
                        child: InkWell(
                          splashColor: Colors.red, // inkwell color
                          child: const SizedBox(
                              width: 56,
                              height: 56,
                              child: Icon(
                                Icons.account_balance_wallet,
                                color: Colors.white,
                                size: 25.0,
                              )),
                          onTap: () {},
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Expanded(
                      child: Text('Wallet Balance',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                SizedBox(height: 25),
                Text(
                  '${balance.toStringAsFixed(4)} ETH',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 35,
                      color: Colors.black87),
                ),
                const SizedBox(height: 10),
                Text(
                  '\$${usdValue.toStringAsFixed(2)} USD',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.black38),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      //margin: EdgeInsets.all(8.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SendScreen()));
                        },
                        icon: Icon(Icons.arrow_outward, color: Colors.white),
                        label: Text(
                          '  Send   ',
                          textScaler: TextScaler.linear(1.3),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          foregroundColor: Colors.white,
                          backgroundColor: Color.fromARGB(255, 22, 22, 22),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      //margin: EdgeInsets.all(8.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ReceiveScreen()));
                        },
                        icon: Icon(
                          Icons.arrow_downward,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Receive ',
                          textScaler: TextScaler.linear(1.3),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          foregroundColor: Colors.white,
                          backgroundColor: Color.fromARGB(255, 22, 22, 22),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }));
  }

  Widget _transactionsList({required transaction}) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: GestureDetector(
          onTap: () {},
          child: card(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'From: ${transaction['from'].substring(0, 10)}...',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: Colors.black54),
                      ),
                      Text(
                        transaction['to'] != ''
                            ? 'To: ${transaction['to'].substring(0, 10)}...'
                            : 'To: Other',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(int.parse(transaction['value']) / pow(10, 18)).toStringAsFixed(4)} ETH',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      '\$ ${((int.parse(transaction['value']) / pow(10, 18)) * ethusd).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: const Color.fromRGBO(76, 175, 80, 1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}

class Noacc extends StatefulWidget {
  @override
  _NoaccState createState() => _NoaccState();
}

class _NoaccState extends State<Noacc> {
  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Add account',
            textScaler: TextScaler.linear(2),
            textAlign: TextAlign.center,
          )
        ]);
  }
}

void showErrorDialog(BuildContext context, String errorMessage) {
  final snackBar = SnackBar(
    content: Text(errorMessage),
    backgroundColor: Colors.red,
    duration: Duration(seconds: 3),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
