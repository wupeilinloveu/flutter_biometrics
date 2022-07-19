import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> hasBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("hasBiometrics: $e");
      }
      return false;
    }
  }

  Future<List<BiometricType>> getBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("getBiometrics: $e");
      }
      return <BiometricType>[];
    }
  }

  Future<bool> authenticate() async {
    final isAvailable = await hasBiometrics();
    if (!isAvailable) return false;
    try {
      return await _auth.authenticateWithBiometrics(
          localizedReason: '请进行指纹识别', useErrorDialogs: true, stickyAuth: true);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("authenticate: $e");
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('生物识别'),
      ),
      body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    final isAvailable = await hasBiometrics();
                    final biometrics = await getBiometrics();
                    final hasFingerprint =
                        biometrics.contains(BiometricType.fingerprint);
                    final hasFace = biometrics.contains(BiometricType.face);
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: const Text('是否支持生物识别'),
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  buildText("生物识别", isAvailable),
                                  buildText("指纹识别", hasFingerprint),
                                  buildText("脸部识别", hasFace),
                                ],
                              ),
                            ));
                  },
                  child: const Text('检查生物识别'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final isAuthenticated = await authenticate();
                    if (isAuthenticated) {
                      if (kDebugMode) {
                        print("验证通过");
                      }
                    }
                  },
                  child: const Text('权限验证'),
                )
              ])),
    ));
  }

  Widget buildText(String text, bool checked) => Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            checked
                ? const Icon(Icons.check, color: Colors.green, size: 24)
                : const Icon(Icons.close, color: Colors.red, size: 24),
            const SizedBox(width: 12),
            Text(text, style: const TextStyle(fontSize: 24))
          ],
        ),
      );
}
