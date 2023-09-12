// ignore_for_file: avoid_print

import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:web3auth_flutter/enums.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:web3auth_flutter/output.dart';
import 'package:hex/hex.dart';
import 'dart:async';

import 'package:web3auth_flutter/web3auth_flutter.dart';

// ignore: depend_on_referenced_packages
import 'package:dartez/dartez.dart';
import 'package:dartez/helper/generateKeys.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

// ignore: use_key_in_widget_constructors
class MyApp extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _result = '';
  bool logoutVisible = false;
  String rpcUrl = 'https://rpc.ghostnet.teztnets.xyz'; // for testnet
  // String rpcUrl = 'https://rpc.tzbeta.net/'; // for mainnet

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
    initDartez();
  }

  Future<void> initDartez() async {
    await Dartez().init();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    final themeMap = HashMap<String, String>();
    themeMap['primary'] = "#229954";

    Uri redirectUrl;
    if (Platform.isAndroid) {
      redirectUrl = Uri.parse('w3a://com.boooooooooom.app/auth');
    } else if (Platform.isIOS) {
      redirectUrl = Uri.parse('com.boooooooooom.app://openlogin');
    } else {
      throw UnKnownException('Unknown platform');
    }

    await Web3AuthFlutter.init(Web3AuthOptions(
        clientId:
            'BIkRzP2cDe0WI1PDQwtH4X7SqUfR0E3Tlt07h3dgLiv0Y5z-S4JbByXk1V8hYdeD8iL0pxZzmDK6X2RVY3ETFvI',
        network: Network.testnet,
        redirectUrl: redirectUrl,
        whiteLabel: WhiteLabelData(
            dark: true, name: "Boom Flutter App", theme: themeMap)));
  }

  @override
  Widget build(BuildContext context) {
    // Map<String, dynamic> user = jsonDecode(_result);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Boom x Tezos Example'),
        ),
        body: SingleChildScrollView(
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
              ),
              Visibility(
                visible: !logoutVisible,
                child: Column(
                  children: [
                    const Icon(
                      Icons.flutter_dash,
                      size: 80,
                      color: Color(0xFF1389fd),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    const Text(
                      'Web3Auth',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 36,
                          color: Color(0xFF0364ff)),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Welcome to Boom x Tezos Demo',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Login with',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        onPressed: _login(_withGoogle),
                        child: const Text('Google')),
                    ElevatedButton(
                        onPressed: _login(_withFacebook),
                        child: const Text('Facebook')),
                    ElevatedButton(
                        onPressed: _login(_withEmailPasswordless),
                        child: const Text('Email Passwordless')),
                    ElevatedButton(
                        onPressed: _login(_withDiscord),
                        child: const Text('Discord')),
                  ],
                ),
              ),
              Visibility(
                // ignore: sort_child_properties_last
                child: Column(
                  children: [
                    Center(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.red[600] // This is what you need!
                              ),
                          onPressed: _logout(),
                          child: const Column(
                            children: [
                              Text('Logout'),
                            ],
                          )),
                    ),
                    const Text(
                      'Blockchain calls',
                      style: TextStyle(fontSize: 20),
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                                255, 195, 47, 233) // This is what you need!
                            ),
                        onPressed: _getAddress,
                        child: const Text('Get Address')),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                                255, 195, 47, 233) // This is what you need!
                            ),
                        onPressed: _getBalance,
                        child: const Text('Get Balance')),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                                255, 195, 47, 233) // This is what you need!
                            ),
                        onPressed: _sendTransaction,
                        child: const Text('Send Transaction')),
                  ],
                ),
                visible: logoutVisible,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_result),
              )
            ],
          )),
        ),
      ),
    );
  }

  VoidCallback _login(Future<Web3AuthResponse> Function() method) {
    return () async {
      try {
        final Web3AuthResponse response = await method();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('privateKey', response.privKey.toString());
        setState(() {
          _result = response.toString();
          logoutVisible = true;
        });
      } on UserCancelledException {
        print("User cancelled.");
      } on UnKnownException {
        print("Unknown exception occurred");
      }
    };
  }

  VoidCallback _logout() {
    return () async {
      try {
        setState(() {
          _result = '';
          logoutVisible = false;
        });
        await Web3AuthFlutter.logout();
      } on UserCancelledException {
        print("User cancelled.");
      } on UnKnownException {
        print("Unknown exception occurred");
      }
    };
  }

  Future<Web3AuthResponse> _withGoogle() {
    return Web3AuthFlutter.login(LoginParams(
      loginProvider: Provider.google,
      mfaLevel: MFALevel.DEFAULT,
    ));
  }

  Future<Web3AuthResponse> _withFacebook() {
    return Web3AuthFlutter.login(LoginParams(loginProvider: Provider.facebook));
  }

  Future<Web3AuthResponse> _withEmailPasswordless() {
    return Web3AuthFlutter.login(LoginParams(
        loginProvider: Provider.email_passwordless,
        extraLoginOptions:
            ExtraLoginOptions(login_hint: "hello+flutterdemo@tor.us")));
  }

  Future<Web3AuthResponse> _withDiscord() {
    return Web3AuthFlutter.login(LoginParams(loginProvider: Provider.discord));
  }

  Future<String> _getAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final privateKey = prefs.getString('privateKey')!;
    final tezosPrivateKey = GenerateKeys.readKeysWithHint(
        Uint8List.fromList(HEX.decoder.convert(privateKey)),
        GenerateKeys.keyPrefixes[PrefixEnum.spsk]!);
    KeyStoreModel tezosKeys = Dartez.getKeysFromSecretKey(tezosPrivateKey);
    final address = tezosKeys.publicKeyHash;
    debugPrint("Account, $address");
    setState(() {
      _result = address;
    });
    return address;
  }

  Future<String> _getBalance() async {
    final prefs = await SharedPreferences.getInstance();
    final privateKey = prefs.getString('privateKey')!;
    final tezosPrivateKey = GenerateKeys.readKeysWithHint(
        Uint8List.fromList(HEX.decoder.convert(privateKey)),
        GenerateKeys.keyPrefixes[PrefixEnum.spsk]!);
    KeyStoreModel tezosKeys = Dartez.getKeysFromSecretKey(tezosPrivateKey);
    final balance = await Dartez.getBalance(tezosKeys.publicKeyHash, rpcUrl);
    debugPrint(balance);
    setState(() {
      _result = balance;
    });
    return balance;
  }

  Future<String> _sendTransaction() async {
    final prefs = await SharedPreferences.getInstance();
    final privateKey = prefs.getString('privateKey')!;
    final tezosPrivateKey = GenerateKeys.readKeysWithHint(
        Uint8List.fromList(HEX.decoder.convert(privateKey)),
        GenerateKeys.keyPrefixes[PrefixEnum.spsk]!);
    KeyStoreModel tezosKeyStore = Dartez.getKeysFromSecretKey(tezosPrivateKey);
    final signer = Dartez.createSigner(tezosPrivateKey);

    try {
      final receipt = await Dartez.sendTransactionOperation(
        rpcUrl,
        signer,
        tezosKeyStore,
        'tz1Us2tdTrvuvMoECavB8ZFadi9QVhrZDzBq',
        1, // 1e-6 tez
      );
      debugPrint(receipt.toString());
      setState(() {
        _result = receipt.toString();
      });
      return receipt.toString();
    } catch (e) {
      setState(() {
        _result = e.toString();
      });
      return e.toString();
    }
  }
}
