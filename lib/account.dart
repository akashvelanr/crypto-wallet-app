class Account {
  String name;
  String rpcUrl;
  String privateKey;
  String chainId;

  Account(
      {required this.name,
      required this.rpcUrl,
      required this.privateKey,
      required this.chainId});
}

List<Account> accounts = [
  Account(
      name: 'demo acc',
      rpcUrl: "https://rpc-sepolia.rockx.com",
      privateKey:
          "0xfdfdc37d029121d110df1ea7d40242e1b73e26dfc16582b94529af7fb6fb6cf7",
      chainId: '11155111')
];

Account? currentAccount = accounts.first;
