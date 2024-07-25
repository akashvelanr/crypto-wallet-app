import 'package:flutter/material.dart';
import 'package:crypto_wallet/wallet_provider.dart';
import 'package:provider/provider.dart';
import 'ui/screen/home.dart';
import 'account.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

const String etherscanApiKey =
    "YOUR API KEY"; // Replace with your Etherscan API key

const String etherscannetwork = "https://api-sepolia.etherscan.io/api";

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => WalletProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallet Cryptocurrency',
      home: MainApp(),
      debugShowCheckedModeBanner: false,
    );
  }
}

enum TabItem { home, explore, notification, setting }

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    currentAccount = accounts.isEmpty ? null : accounts.first;
    checkNetworkConnectivity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: SafeArea(
            child: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: 78,
          title: Text(
            'Wallet',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [_accountSwitcher()],
        )),
      ),
      // appBar: PreferredSize(
      //   preferredSize: Size.fromHeight(80.0),
      //   child: SafeArea(
      //     child: appBar(title: 'Selopia Wallets', right: _accountSwitcher()),
      //   ),
      // ),
      body: currentAccount != null ? HomeScreen() : Noacc(),
    );
  }

  Widget _accountSwitcher() {
    return Container(
        child: PopupMenuButton<Account>(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          currentAccount == null ? 'No account' : currentAccount!.name,
          style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
        ),
      ),
      onSelected: (Account account) {
        setState(() {
          currentAccount = account;
        });
      },
      itemBuilder: (BuildContext context) {
        return [
          ...accounts.map((Account account) {
            return PopupMenuItem<Account>(
                value: account,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Text(account.name),
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              accounts.remove(account);
                              currentAccount =
                                  accounts.isNotEmpty ? accounts.first : null;
                            });
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.delete_outline))
                    ]));
          }).toList(),
          PopupMenuItem<Account>(
            value: currentAccount,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Add Account'),
                Icon(Icons.add, color: Colors.blue),
              ],
            ),
            onTap: () {
              Future.delayed(
                Duration.zero,
                () => _showAddAccountDialog(context),
              );
            },
          ),
        ];
      },
    ));
  }

  void _showAddAccountDialog(BuildContext context) {
    final TextEditingController _accountname = TextEditingController();
    final TextEditingController _rpcurl = TextEditingController();
    final TextEditingController _privatekey = TextEditingController();
    final TextEditingController _chainid = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Expanded(
          child: AlertDialog(
            title: Text('Add New Account'),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _accountname,
                  decoration: InputDecoration(hintText: 'Enter account name'),
                ),
                TextField(
                  controller: _rpcurl,
                  decoration: InputDecoration(hintText: 'Enter RPC Url'),
                ),
                TextField(
                  controller: _privatekey,
                  decoration:
                      InputDecoration(hintText: 'Enter your private key'),
                ),
                TextField(
                  controller: _chainid,
                  decoration: InputDecoration(hintText: 'Enter Chain ID'),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: Text('Add'),
                onPressed: () {
                  setState(() {
                    accounts.add(Account(
                        name: _accountname.text,
                        rpcUrl: _rpcurl.text,
                        privateKey: _privatekey.text,
                        chainId: _chainid.text));
                  });
                  currentAccount = accounts.last;
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> checkNetworkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _showNetworkErrorDialog();
    }
  }

  void _showNetworkErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("No Internet Connection"),
          content: Text("Please check your network connection and try again."),
          actions: <Widget>[
            TextButton(
              child: Text("Retry"),
              onPressed: () async {
                Navigator.of(context).pop();
                await checkNetworkConnectivity();
              },
            ),
          ],
        );
      },
    );
  }

  // Widget _bottomNavigationBar() {
  //   return BottomNavigationBar(
  //     type: BottomNavigationBarType.fixed,
  //     items: _bottomTabs
  //         .map((tabItem) => _bottomNavigationBarItem(_icon(tabItem), tabItem))
  //         .toList(),
  //     onTap: _onSelectTab,
  //     showSelectedLabels: false,
  //     showUnselectedLabels: false,
  //   );
  // }

  // BottomNavigationBarItem _bottomNavigationBarItem(
  //     IconData icon, TabItem tabItem) {
  //   final Color color =
  //       _currentItem == tabItem ? Colors.black54 : Colors.black26;

  //   return BottomNavigationBarItem(icon: Icon(icon, color: color), label: '');
  // }

  // void _onSelectTab(int index) {
  //   TabItem selectedTabItem = _bottomTabs[index];

  //   setState(() {
  //     _currentItem = selectedTabItem;
  //   });
  // }

  // IconData _icon(TabItem item) {
  //   switch (item) {
  //     case TabItem.home:
  //       return Icons.account_balance_wallet;
  //     case TabItem.explore:
  //       return Icons.explore;
  //     case TabItem.notification:
  //       return Icons.notifications;
  //     case TabItem.setting:
  //       return Icons.settings;
  //     default:
  //       throw 'Unknown $item';
  //   }
}

  // Widget _buildScreen() {
  //   switch (_currentItem) {
  //     case TabItem.home:
  //       return HomeScreen();
  //     case TabItem.explore:
  //     // return HomeScreen();
  //     case TabItem.notification:
  //     // return HomeScreen()
  //     case TabItem.setting:
  //     // return HomeScreen()
  //     default:
  //       return HomeScreen();
  //   }
  // }
//}

