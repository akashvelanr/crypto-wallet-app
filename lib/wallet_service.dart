import 'dart:async';

import 'package:crypto_wallet/account.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

final String rpcUrl = currentAccount!.rpcUrl;
final String privateKey = currentAccount!.privateKey;

final int chainid = int.parse(currentAccount!.chainId);

late Web3Client client;
late Credentials credentials;
late EthereumAddress myAddress;

class WalletService {
  final String rpcUrl =
      "https://eth-sepolia.g.alchemy.com/v2/wgaDZuQ4s6Nn8eqBekDW--bITuF4e-Kp";
  final String privateKey =
      "0xfdfdc37d029121d110df1ea7d40242e1b73e26dfc16582b94529af7fb6fb6cf7";

  late Web3Client client;
  late Credentials credentials;
  late EthereumAddress myAddress;

  WalletService() {
    client = Web3Client(rpcUrl, http.Client());
    credentials = EthPrivateKey.fromHex(privateKey);
    myAddress = credentials.address;
    print("Wallet Address: $myAddress");
  }

  Future<EtherAmount> getBalance() async {
    try {
      EtherAmount balance = await client.getBalance(myAddress);
      print("Fetched Balance: ${balance.getValueInUnit(EtherUnit.ether)}");
      return balance;
    } catch (e) {
      print("Error fetching balance: $e");
      return EtherAmount.zero();
    }
  }

  Future<String> sendTransaction(
      EthereumAddress receiver, double amount) async {
    try {
      BigInt amtInWei = BigInt.from(amount * 1e18);
      print(amtInWei);
      print(receiver);
      print(chainid);

      final transaction = Transaction(
        to: receiver,
        value: EtherAmount.fromBigInt(EtherUnit.wei, amtInWei),
        maxGas: 21000,
      );
      String txHash = await client.sendTransaction(credentials, transaction,
          chainId: chainid); // Adjust chainId as needed
      print("Transaction Hash: $txHash");
      return txHash;
    } catch (e) {
      print("Error sending transaction: $e");
      return "";
    }
  }
}
