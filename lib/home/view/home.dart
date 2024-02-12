import 'package:flutter/material.dart';
import 'package:flutter_solana_twitter_clone/home/src/api.dart';
import 'package:solana/base58.dart';
import 'package:solana/solana.dart';
import 'package:solana_mobile_client/solana_mobile_client.dart';

Workspace workspace = Workspace();

class SolanaTwitterHomeView extends StatefulWidget {
  const SolanaTwitterHomeView({super.key});

  @override
  State<SolanaTwitterHomeView> createState() => _SolanaTwitterHomeViewState();
}

class _SolanaTwitterHomeViewState extends State<SolanaTwitterHomeView> {
  late AuthorizationResult? _result;
  int _accountBalance = 0;
  late MobileWalletAdapterClient client;
  final solanaClient = SolanaClient(
    rpcUrl: Uri.parse('https://api.devnet.solana.com'),
    websocketUrl: Uri.parse('wss://api.devnet.solana.com'),
  );
  final int lamportsPerSol = 1000000000;

  @override
  void initState() {
    super.initState();
    (() async {
      _result = null;
      if (!await LocalAssociationScenario.isAvailable()) {
        debugPrint('No MWA Compatible wallet available; please install a wallet');
      } else {
        debugPrint('FOUND MWA WALLET');
        await authorizeUser();
        await getSOLBalance();
      }
    })();
  }

  Future<void> authorizeUser() async {
    /// step 1
    final localScenario = await LocalAssociationScenario.create();
    try {
      /// step 2
      localScenario.startActivityForResult(null).ignore();

      /// step 3
      client = await localScenario.start();

      /// step 4
      final result = await client.authorize(
        identityUri: Uri.parse('https://solana-twitter-clone.example.com'),
        iconUri: Uri.parse('favicon.ico'),
        identityName: 'Flutter Solana Twitter Clone',
        cluster: 'devnet',
      );

      /// step 5
      // await localScenario.close();

      setState(() {
        _result = result;
      });

      await getSOLBalance();
    } on Exception catch (e) {
      debugPrint(e.toString());
    } finally {
      await localScenario.close();
    }
  }

  Future<void> deauthorizeUser() async {
    try {
      await client.deauthorize(authToken: _result!.authToken);

      setState(() {
        _result = null;
        _accountBalance = 0;
      });
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> requestAirDrop() async {
    try {
      await solanaClient.requestAirdrop(
        /// Ed25519HDPublicKey is the main class that represents public
        /// key in the solana dart library
        address: Ed25519HDPublicKey(
          _result!.publicKey.toList(),
        ),
        lamports: 1 * lamportsPerSol,
      );
      await getSOLBalance();
    } catch (e) {
      debugPrint('$e');
    }
  }

  Future<void> getSOLBalance() async {
    try {
      debugPrint('get balance');
      final balance = await solanaClient.rpcClient.getBalance(
        base58encode(_result!.publicKey),
      );
      debugPrint('balance${balance.value}');
      setState(() {
        _accountBalance = balance.value;
      });
    } catch (e) {
      debugPrint('$e');
    }
  }

  Future<void> getTweetsFromWorkspace() async {
    try {
      await workspace.getTweet(solanaClient, _result!);
    } catch (e) {
      debugPrint('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Solana Twitter Clone'),
          centerTitle: true,
          actions: [
            ElevatedButton(
              onPressed: (_result == null) ? authorizeUser : deauthorizeUser,
              child: Text((_result == null) ? 'Sign in' : 'Sign out'),
            ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Table(
                columnWidths: {0: FixedColumnWidth(screenSize.width * 0.3), 1: FixedColumnWidth(screenSize.width * 0.6)},
                children: [
                  TableRow(
                    children: [
                      const TableCell(child: Text('Public Key')),
                      TableCell(child: Text((_result != null) ? base58encode(_result!.publicKey) : '')),
                    ],
                  ),
                  TableRow(
                    children: [
                      const TableCell(child: Text('Account Label')),
                      TableCell(child: Text((_result != null) ? _result!.accountLabel! : '')),
                    ],
                  ),
                  TableRow(
                    children: [
                      const TableCell(child: Text('Sol Balance')),
                      TableCell(
                        child: Text(
                          (_accountBalance / lamportsPerSol).toStringAsPrecision(8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: screenSize.width * 0.02,
              children: [
                ElevatedButton(
                  onPressed: requestAirDrop,
                  child: const Text('Request Airdrop'),
                ),
                ElevatedButton(
                  onPressed: getSOLBalance,
                  child: const Text('Request Balance'),
                ),
                ElevatedButton(
                  onPressed: getTweetsFromWorkspace,
                  child: const Text('Get Tweets'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
