import 'package:flutter/material.dart';
import 'package:crypto_wallet/wallet_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';

class ReceiveScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: SafeArea(
            child: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: 78,
          title: Text('Receive'),
        )),
      ),
      backgroundColor: Colors.blueGrey[50],
      body: Container(
        padding: EdgeInsets.all(30),
        child: Consumer<WalletProvider>(
          builder: (context, walletProvider, child) {
            final address = walletProvider.address.hex;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: QrImageView(
                    data: address,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                ),
                SizedBox(height: 20),
                Text(address, style: TextStyle(fontSize: 16)),
              ],
            );
          },
        ),
      ),
    );
  }
}
