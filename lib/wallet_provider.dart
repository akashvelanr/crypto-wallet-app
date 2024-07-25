import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import 'wallet_service.dart';

class WalletProvider with ChangeNotifier {
  final WalletService _walletService = WalletService();

  EtherAmount _balance = EtherAmount.zero();
  EtherAmount get balance => _balance;

  EthereumAddress get address => _walletService.myAddress;

  Future<void> updateBalance() async {
    _balance = await _walletService.getBalance();
    print("Updated Balance: ${_balance.getValueInUnit(EtherUnit.ether)}");
    notifyListeners();
  }

  Future<EtherAmount> getBalance() async {
    _balance = await _walletService.getBalance();
    print("Updated Balance: ${_balance.getValueInUnit(EtherUnit.ether)}");
    notifyListeners();
    return _balance;
  }

  Future<void> sendTransaction(String receiverAddress, double amount) async {
    final receiver = EthereumAddress.fromHex(receiverAddress);
    await _walletService.sendTransaction(receiver, amount);
    updateBalance();
  }
}
